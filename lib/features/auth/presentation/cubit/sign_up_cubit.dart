import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/enums/photo_source.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../profile/data/enums/gender.dart';
import '../../../profile/data/enums/signup_step.dart';
import '../../../profile/data/enums/suggestion_tab.dart';
import '../../../profile/data/model/suggested_profile_model.dart';
import '../../../profile/domain/use_case/clear_local_profile_use_case.dart';
import '../../../profile/domain/use_case/complete_signup_use_case.dart';
import '../../../profile/domain/use_case/get_interests_use_case.dart';
import '../../../profile/domain/use_case/get_signup_draft_use_case.dart';
import '../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../../../profile/domain/use_case/get_suggested_profiles_use_case.dart';
import '../../../profile/domain/use_case/save_about_you_use_case.dart';
import '../../../profile/domain/use_case/save_interests_use_case.dart';
import '../../../profile/domain/use_case/set_following_use_case.dart';
import '../../../profile/domain/use_case/save_profile_details_use_case.dart';
import '../../data/datasource/auth_datasource.dart';
import '../utils/countdown.dart';
import '../utils/enums/follow_tab.dart';
import '../utils/enums/load_status.dart';
import 'sign_up_state.dart';

/// The sign-up flow (docs/specs/auth/screens/s3-signup-account.md, s4-signup-verify-email.md): Account,
/// Verify email, About you, Profile, Interests and Follow, and leaving the flow.
@injectable
class SignUpCubit extends BaseCubit<SignUpState> {
  SignUpCubit(
    this._auth,
    this._saveAboutYou,
    this._saveProfileDetails,
    this._photos,
    this._getInterests,
    this._saveInterests,
    this._getSuggestedProfiles,
    this._setFollowing,
    this._completeSignup,
    this._clearLocalProfile,
    this._getSignupStep,
    this._getSignupDraft,
  ) : super(const SignUpState());

  static const resendCooldown = Duration(seconds: 30);
  static const firstStep = 1;
  static const verifyStep = 2;
  static const aboutYouStep = 3;
  static const profileStep = 4;
  static const interestsStep = 5;
  static const followStep = 6;
  static const lastStep = 6;

  final AuthDatasource _auth;
  final SaveAboutYouUseCase _saveAboutYou;
  final SaveProfileDetailsUseCase _saveProfileDetails;
  final PhotoPickerService _photos;
  final GetInterestsUseCase _getInterests;
  final SaveInterestsUseCase _saveInterests;
  final GetSuggestedProfilesUseCase _getSuggestedProfiles;
  final SetFollowingUseCase _setFollowing;

  /// People whose follow / unfollow request is running (no UI: it only ignores repeat taps).
  final _followInFlight = <String>{};
  final CompleteSignupUseCase _completeSignup;
  final ClearLocalProfileUseCase _clearLocalProfile;
  final GetSignupStepUseCase _getSignupStep;
  final GetSignupDraftUseCase _getSignupDraft;

  final _countdown = Countdown();

  /// Opens the flow at [step] (a resumed sign-up, or Sign in finding an unverified [email]). Verify
  /// email needs an address, so without one the flow starts at the Account step.
  void open({int step = firstStep, String? email}) {
    final clamped = step.clamp(firstStep, lastStep);
    if (clamped == verifyStep) {
      if (email == null || email.isEmpty) return;
      // Sign in has just sent a fresh code, so the resend cooldown is already running.
      emit(state.copyWith(step: verifyStep, email: email));
      _startCooldown();
      return;
    }
    // A resumed sign-up (after Verify email) first brings back what was entered before.
    final resume = clamped > verifyStep;
    emit(state.copyWith(step: clamped, resuming: resume));
    if (resume) unawaited(_restoreDraft());
    // A resumed sign-up loads what its step shows.
    if (clamped == interestsStep) unawaited(_loadInterests());
    if (clamped == followStep) unawaited(_loadPeople());
  }

  /// Fills About you and Profile from the saved profile, so going back shows what was entered. Only
  /// empty fields are filled; a failure just leaves them empty.
  Future<void> _restoreDraft() async {
    final result = await _getSignupDraft();
    result.fold((_) => emit(state.copyWith(resuming: false)), (draft) {
      emit(
        state.copyWith(
          resuming: false,
          fullName: state.fullName.isEmpty
              ? draft.fullName ?? ''
              : state.fullName,
          username: state.username.isEmpty
              ? draft.username ?? ''
              : state.username,
          birthday: state.birthday ?? draft.birthday,
          gender: state.gender ?? draft.gender,
          bio: state.bio.isEmpty ? draft.bio ?? '' : state.bio,
          city: state.city.isEmpty ? draft.city ?? '' : state.city,
          phone: state.phone.isEmpty ? draft.phone ?? '' : state.phone,
          avatarUrl: state.avatarUrl ?? draft.avatarUrl,
        ),
      );
    });
  }

  void emailChanged(String value) => emit(
    state.copyWith(
      email: value,
      failure: state.emailTaken ? null : state.failure,
    ),
  );

  void passwordChanged(String value) => emit(state.copyWith(password: value));

  void termsChanged(bool accepted) =>
      emit(state.copyWith(termsAccepted: accepted));

  void emailLeft() => emit(state.copyWith(emailTouched: true));

  void passwordLeft() => emit(state.copyWith(passwordTouched: true));

  Future<void> submitAccount() async {
    if (!state.canSubmitAccount) return;
    emit(state.copyWith(loading: true, failure: null));
    final result = await _auth.signUp(
      email: state.email.trim(),
      password: state.password,
    );
    await result.fold(
      (failure) async {
        if (failure case AuthFailure(reason: AuthFailureReason.emailTaken)) {
          await _resumeExistingAccount(failure);
          return;
        }
        emit(state.copyWith(loading: false, failure: failure));
      },
      (_) async {
        emit(
          state.copyWith(
            step: verifyStep,
            email: state.email.trim(),
            code: '',
            loading: false,
          ),
        );
        _startCooldown();
      },
    );
  }

  /// The email already has an account: when the same email and password sign in, the person is
  /// resuming an unfinished sign-up, so continue at the step still to do (Home when none). Any other
  /// outcome is the original [taken] failure.
  Future<void> _resumeExistingAccount(Failure taken) async {
    final email = state.email.trim();
    final signedIn = await _auth.signIn(
      identifier: email,
      password: state.password,
    );
    await signedIn.fold(
      (failure) async {
        if (failure case AuthFailure(
          reason: AuthFailureReason.emailNotConfirmed,
        )) {
          // Never verified: a fresh code, then the Verify email step.
          await _auth.resendSignUpCode(email);
          emit(state.copyWith(step: verifyStep, code: '', loading: false));
          _startCooldown();
          return;
        }
        emit(state.copyWith(loading: false, failure: taken));
      },
      (_) async {
        final step = await _getSignupStep();
        step.fold(
          (failure) => emit(state.copyWith(loading: false, failure: failure)),
          (next) {
            if (next == SignupStep.complete) {
              _go(AppRoutes.home);
              return;
            }
            emit(state.copyWith(loading: false));
            open(step: next.number);
          },
        );
      },
    );
  }

  void codeChanged(String value) => emit(
    state.copyWith(
      code: value,
      failure: state.wrongCode ? null : state.failure,
    ),
  );

  Future<void> verify() async {
    if (!state.canVerify) return;
    emit(state.copyWith(loading: true, failure: null));
    final result = await _auth.verifySignUpCode(
      email: state.email,
      code: state.code,
    );
    result.fold(
      (failure) => emit(state.copyWith(loading: false, failure: failure)),
      (_) {
        _countdown.cancel();
        emit(
          state.copyWith(step: aboutYouStep, loading: false, resendIn: null),
        );
      },
    );
  }

  /// "Resend code"; ignored during the cooldown.
  Future<void> resend() async {
    if (!state.canResend) return;
    emit(state.copyWith(loading: true, failure: null));
    final result = await _auth.resendSignUpCode(state.email);
    result.fold(
      (failure) => emit(state.copyWith(loading: false, failure: failure)),
      (_) {
        emit(state.copyWith(loading: false, code: ''));
        _startCooldown();
      },
    );
  }

  /// The back arrow and "Use a different email" on Verify email: the Account step, with what was typed.
  void backToAccount() {
    _countdown.cancel();
    emit(
      state.copyWith(
        step: firstStep,
        code: '',
        failure: null,
        resendIn: null,
        loading: false,
      ),
    );
  }

  void fullNameChanged(String value) => emit(state.copyWith(fullName: value));

  void usernameChanged(String value) => emit(
    state.copyWith(
      username: value,
      failure: state.usernameTaken ? null : state.failure,
    ),
  );

  void usernameLeft() => emit(state.copyWith(usernameTouched: true));

  void birthdayPicked(DateTime date) => emit(state.copyWith(birthday: date));

  /// Tapping the chosen gender again clears it.
  void genderToggled(Gender gender) =>
      emit(state.copyWith(gender: state.gender == gender ? null : gender));

  Future<void> submitAbout() async {
    if (!state.canSubmitAbout) return;
    emit(state.copyWith(loading: true, failure: null));
    final result = await _saveAboutYou(
      fullName: state.fullName,
      username: state.username,
      birthday: state.birthday!,
      gender: state.gender,
    );
    result.fold(
      (failure) => emit(state.copyWith(loading: false, failure: failure)),
      (_) => emit(state.copyWith(step: profileStep, loading: false)),
    );
  }

  /// The photo sheet's "Take photo" and "Choose from gallery"; a cancelled pick changes nothing.
  Future<void> pickPhoto(PhotoSource source) async {
    final photo = await _photos.pick(source);
    if (photo != null) emit(state.copyWith(photo: photo));
  }

  void removePhoto() => emit(
    state.copyWith(
      photo: null,
      avatarUrl: null,
      avatarRemoved: state.avatarRemoved || state.avatarUrl != null,
    ),
  );

  void bioChanged(String value) => emit(state.copyWith(bio: value));

  void cityChanged(String value) => emit(state.copyWith(city: value));

  void phoneChanged(String value) => emit(state.copyWith(phone: value));

  void phoneLeft() => emit(state.copyWith(phoneTouched: true));

  Future<void> submitProfile() async {
    if (!state.canSubmitProfile) return;
    await _saveProfile(
      photo: state.photo,
      bio: state.bio,
      city: state.city,
      phone: state.phone,
      removeAvatar: state.avatarRemoved,
    );
  }

  /// "Skip" on Profile: saves nothing, only moves on.
  Future<void> skipProfile() async {
    if (state.loading) return;
    await _saveProfile();
  }

  Future<void> _saveProfile({
    PickedPhoto? photo,
    String? bio,
    String? city,
    String? phone,
    bool removeAvatar = false,
  }) async {
    emit(state.copyWith(loading: true, failure: null));
    final result = await _saveProfileDetails(
      photo: photo?.bytes,
      photoContentType: photo?.contentType,
      bio: bio,
      city: city,
      phone: phone,
      removeAvatar: removeAvatar,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(loading: false, failure: failure)),
      (_) => _loadInterests(),
    );
  }

  /// The step bar's arrow from step 4 on: the step before (Interests is passed over when it has no topics).
  void backOneStep() {
    if (state.step <= aboutYouStep) return;
    var target = state.step - 1;
    if (target == interestsStep) {
      if (state.interestsStatus == LoadStatus.idle) {
        emit(state.copyWith(step: interestsStep, failure: null));
        unawaited(_loadInterests(forward: false));
        return;
      }
      if (state.interests.isEmpty && !state.interestsStatus.isFailed) {
        target = profileStep;
      }
    }
    emit(state.copyWith(step: target, failure: null));
  }

  void interestToggled(int id) {
    final selected = {...state.selectedInterests};
    selected.remove(id) || selected.add(id);
    emit(state.copyWith(selectedInterests: selected));
  }

  Future<void> retryInterests() => _loadInterests();

  Future<void> submitInterests() =>
      _continueFromInterests(state.selectedInterests.toList());

  /// "Skip" on Interests: saves nothing, only moves on.
  Future<void> skipInterests() => _continueFromInterests(const []);

  /// Loads the topics; none to pick means the step is passed over (going forward) or back over (going back).
  Future<void> _loadInterests({bool forward = true}) async {
    emit(state.copyWith(interestsStatus: LoadStatus.loading));
    final result = await _getInterests();
    await result.fold(
      (_) async => emit(
        state.copyWith(
          step: interestsStep,
          interestsStatus: LoadStatus.failed,
          loading: false,
        ),
      ),
      (interests) async {
        emit(
          state.copyWith(
            interestsStatus: LoadStatus.loaded,
            interests: interests,
            loading: false,
          ),
        );
        if (interests.isNotEmpty) {
          emit(state.copyWith(step: interestsStep));
        } else if (forward) {
          await _continueFromInterests(const []);
        } else {
          emit(state.copyWith(step: profileStep));
        }
      },
    );
  }

  Future<void> _continueFromInterests(List<int> ids) async {
    emit(state.copyWith(loading: true, failure: null));
    final result = await _saveInterests(ids);
    await result.fold(
      (failure) async => emit(state.copyWith(loading: false, failure: failure)),
      (_) => _loadPeople(),
    );
  }

  /// Loads both lists the Follow step serves; when both are empty the step is passed over.
  Future<void> _loadPeople() async {
    emit(
      state.copyWith(
        peopleStatus: {
          for (final tab in SuggestionTab.values) tab: LoadStatus.loading,
        },
      ),
    );
    final results = await [
      for (final tab in SuggestionTab.values) _getSuggestedProfiles(tab),
    ].wait;
    final status = <SuggestionTab, LoadStatus>{};
    final people = <SuggestionTab, List<SuggestedProfileModel>>{};
    for (final (index, tab) in SuggestionTab.values.indexed) {
      results[index].fold((_) => status[tab] = LoadStatus.failed, (list) {
        status[tab] = LoadStatus.loaded;
        people[tab] = list;
      });
    }
    final allEmpty =
        status.values.every((s) => s == LoadStatus.loaded) &&
        people.values.every((list) => list.isEmpty);
    if (allEmpty) {
      await _finish();
      return;
    }
    emit(
      state.copyWith(
        step: followStep,
        peopleStatus: status,
        people: people,
        loading: false,
      ),
    );
  }

  void tabSelected(FollowTab tab) {
    emit(state.copyWith(followTab: tab));
  }

  /// "Retry" on a Follow tab that failed to load.
  Future<void> retryPeople() async {
    final tab = state.followTab.source;
    if (tab == null) return;
    emit(
      state.copyWith(
        peopleStatus: {...state.peopleStatus, tab: LoadStatus.loading},
      ),
    );
    final result = await _getSuggestedProfiles(tab);
    result.fold(
      (_) => emit(
        state.copyWith(
          peopleStatus: {...state.peopleStatus, tab: LoadStatus.failed},
        ),
      ),
      (list) => emit(
        state.copyWith(
          peopleStatus: {...state.peopleStatus, tab: LoadStatus.loaded},
          people: {...state.people, tab: list},
        ),
      ),
    );
  }

  /// Follow or unfollow right away; a failed request puts the button back and reports it. Taps on a
  /// person whose request is still running are ignored, so they cannot race each other.
  Future<void> followToggled(String id) async {
    if (!_followInFlight.add(id)) return;
    final following = !state.following.contains(id);
    _setLocalFollowing([id], following);
    emit(state.copyWith(failure: null));
    final result = await _setFollowing(id, following: following);
    _followInFlight.remove(id);
    result.fold((failure) {
      _setLocalFollowing([id], !following);
      emit(state.copyWith(failure: failure));
    }, (_) {});
  }

  /// "Follow all" on the visible tab.
  Future<void> followAll() async {
    final ids = [
      for (final person in state.visiblePeople)
        if (person.id != null &&
            !state.following.contains(person.id) &&
            !_followInFlight.contains(person.id))
          person.id!,
    ];
    if (ids.isEmpty) return;
    _setLocalFollowing(ids, true);
    emit(state.copyWith(failure: null));
    final result = await _setFollowing.all(ids);
    result.fold((failure) {
      _setLocalFollowing(ids, false);
      emit(state.copyWith(failure: failure));
    }, (_) {});
  }

  void _setLocalFollowing(List<String> ids, bool following) {
    final set = {...state.following};
    following ? set.addAll(ids) : set.removeAll(ids);
    emit(state.copyWith(following: set));
  }

  /// "Continue" and "Skip" on Follow: sign-up is finished, on to Home.
  Future<void> finishFollow() => _finish();

  Future<void> _finish() async {
    if (state.loading && state.step == followStep) return;
    emit(state.copyWith(loading: true, failure: null));
    final result = await _completeSignup();
    result.fold(
      (failure) => emit(state.copyWith(loading: false, failure: failure)),
      (_) => _go(AppRoutes.home),
    );
  }

  /// "Leave" in the leave dialog. Progress is already saved, so only the session ends; the session is
  /// dropped on this device even when the server cannot be reached.
  Future<void> leave() async {
    emit(state.copyWith(loading: true));
    await _clearLocalProfile();
    await _auth.signOut();
    _go(AppRoutes.signIn);
  }

  void _go(String route) {
    emit(state.copyWith(loading: false, route: route));
    emit(state.copyWith(route: null));
  }

  void _startCooldown() {
    emit(state.copyWith(resendIn: resendCooldown));
    _countdown.start(
      resendCooldown,
      (left) =>
          emit(state.copyWith(resendIn: left > Duration.zero ? left : null)),
    );
  }

  @override
  Future<void> close() {
    _countdown.cancel();
    return super.close();
  }
}
