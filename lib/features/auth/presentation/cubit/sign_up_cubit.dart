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
import '../../../follow/data/enums/suggestion_tab.dart';
import '../../../follow/data/model/suggested_profile_model.dart';
import '../../../profile/domain/use_case/clear_local_profile_use_case.dart';
import '../../../profile/domain/use_case/complete_signup_use_case.dart';
import '../../../profile/domain/use_case/get_interests_use_case.dart';
import '../../../profile/domain/use_case/get_signup_draft_use_case.dart';
import '../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../../../follow/domain/use_case/follow_all_use_case.dart';
import '../../../follow/domain/use_case/get_suggested_profiles_use_case.dart';
import '../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../profile/domain/use_case/save_about_you_use_case.dart';
import '../../../profile/domain/use_case/save_interests_use_case.dart';
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
    this._toggleFollow,
    this._followAll,
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
  final ToggleFollowUseCase _toggleFollow;
  final FollowAllUseCase _followAll;

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
    await run(
      _getSignupDraft.call,
      onFailure: (_) => state.copyWith(resuming: false),
      onSuccess: (draft) => state.copyWith(
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
    await run(
      prevent: !state.canSubmitAccount,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.signUp(email: state.email.trim(), password: state.password),
      onSuccess: (_) {
        _startCooldown();
        return state.copyWith(
          step: verifyStep,
          email: state.email.trim(),
          code: '',
          loading: false,
        );
      },
      onFailure: (failure) async {
        if (failure case AuthFailure(reason: AuthFailureReason.emailTaken)) {
          await _resumeExistingAccount(failure);
          return;
        }
        emit(state.copyWith(loading: false, failure: failure));
      },
    );
  }

  /// The email already has an account: when the same email and password sign in, the person is
  /// resuming an unfinished sign-up, so continue at the step still to do (Home when none). Any other
  /// outcome is the original [taken] failure.
  Future<void> _resumeExistingAccount(Failure taken) async {
    final email = state.email.trim();
    await run(
      () => _auth.signIn(identifier: email, password: state.password),
      onSuccess: (_) => _continueSignedIn(),
      onFailure: (failure) async {
        if (failure case AuthFailure(
          reason: AuthFailureReason.emailNotConfirmed,
        )) {
          // Never verified: a fresh code, then the Verify email step.
          try {
            await _auth.resendSignUpCode(email);
          } on Failure {
            // The Verify email step has "Resend code".
          }
          _startCooldown();
          return state.copyWith(step: verifyStep, code: '', loading: false);
        }
        return state.copyWith(loading: false, failure: taken);
      },
    );
  }

  Future<void> _continueSignedIn() async {
    await run(
      _getSignupStep.call,
      onSuccess: (next) {
        if (next == SignupStep.complete) {
          _go(AppRoutes.home);
          return;
        }
        emit(state.copyWith(loading: false));
        open(step: next.number);
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
    );
  }

  void codeChanged(String value) => emit(
    state.copyWith(
      code: value,
      failure: state.wrongCode ? null : state.failure,
    ),
  );

  Future<void> verify() async {
    await run(
      prevent: !state.canVerify,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.verifySignUpCode(email: state.email, code: state.code),
      onSuccess: (_) {
        _countdown.cancel();
        return state.copyWith(
          step: aboutYouStep,
          loading: false,
          resendIn: null,
        );
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
    );
  }

  /// "Resend code"; ignored during the cooldown.
  Future<void> resend() async {
    await run(
      prevent: !state.canResend,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.resendSignUpCode(state.email),
      onSuccess: (_) {
        emit(state.copyWith(loading: false, code: ''));
        _startCooldown();
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
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
    await run(
      prevent: !state.canSubmitAbout,
      loading: state.copyWith(loading: true, failure: null),
      () => _saveAboutYou(
        fullName: state.fullName,
        username: state.username,
        birthday: state.birthday!,
        gender: state.gender,
      ),
      onSuccess: (_) => state.copyWith(step: profileStep, loading: false),
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
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
    await run(
      loading: state.copyWith(loading: true, failure: null),
      () => _saveProfileDetails(
        photo: photo?.bytes,
        photoContentType: photo?.contentType,
        bio: bio,
        city: city,
        phone: phone,
        removeAvatar: removeAvatar,
      ),
      onSuccess: (_) async {
        await _loadInterests();
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
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
    await run(
      loading: state.copyWith(interestsStatus: LoadStatus.loading),
      _getInterests.call,
      onSuccess: (interests) async {
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
      onFailure: (_) => state.copyWith(
        step: interestsStep,
        interestsStatus: LoadStatus.failed,
        loading: false,
      ),
    );
  }

  Future<void> _continueFromInterests(List<int> ids) async {
    await run(
      loading: state.copyWith(loading: true, failure: null),
      () => _saveInterests(ids),
      onSuccess: (_) async {
        await _loadPeople();
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
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
      for (final tab in SuggestionTab.values) _tryPeople(tab),
    ].wait;
    final status = <SuggestionTab, LoadStatus>{};
    final people = <SuggestionTab, List<SuggestedProfileModel>>{};
    for (final (index, tab) in SuggestionTab.values.indexed) {
      final list = results[index];
      if (list == null) {
        status[tab] = LoadStatus.failed;
      } else {
        status[tab] = LoadStatus.loaded;
        people[tab] = list;
      }
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

  /// One tab's people, or null when it could not be loaded (that tab shows its own retry).
  Future<List<SuggestedProfileModel>?> _tryPeople(SuggestionTab tab) async {
    try {
      return await _getSuggestedProfiles(tab);
    } on Failure {
      return null;
    }
  }

  void tabSelected(FollowTab tab) {
    emit(state.copyWith(followTab: tab));
  }

  /// "Retry" on a Follow tab that failed to load.
  Future<void> retryPeople() async {
    final tab = state.followTab.source;
    if (tab == null) return;
    await run(
      loading: state.copyWith(
        peopleStatus: {...state.peopleStatus, tab: LoadStatus.loading},
      ),
      () => _getSuggestedProfiles(tab),
      onSuccess: (list) => state.copyWith(
        peopleStatus: {...state.peopleStatus, tab: LoadStatus.loaded},
        people: {...state.people, tab: list},
      ),
      onFailure: (_) => state.copyWith(
        peopleStatus: {...state.peopleStatus, tab: LoadStatus.failed},
      ),
    );
  }

  /// Follow or unfollow right away; a failed request puts the button back and reports it. A private
  /// profile shows "Requested" (the backend's answer replaces the guess). Taps on a person whose request
  /// is still running are ignored, so they cannot race each other.
  Future<void> followToggled(String id) async {
    if (!_followInFlight.add(id)) return;
    final before = state.follows[id];
    final follow = before == null;
    _setLocalFollows({id: follow ? _expectedStatus(id) : null});
    await run(
      loading: state.copyWith(failure: null),
      () => _toggleFollow(id, follow: follow),
      onSuccess: (status) {
        _followInFlight.remove(id);
        if (follow) _setLocalFollows({id: status});
        return null;
      },
      onFailure: (failure) {
        _followInFlight.remove(id);
        _setLocalFollows({id: before});
        return state.copyWith(failure: failure);
      },
    );
  }

  /// "Follow all" on the visible tab.
  Future<void> followAll() async {
    final ids = [
      for (final person in state.visiblePeople)
        if (person.id != null &&
            !state.follows.containsKey(person.id) &&
            !_followInFlight.contains(person.id))
          person.id!,
    ];
    if (ids.isEmpty) return;
    _setLocalFollows({for (final id in ids) id: _expectedStatus(id)});
    await run(
      loading: state.copyWith(failure: null),
      () => _followAll(ids),
      onSuccess: (_) => null,
      onFailure: (failure) {
        _setLocalFollows({for (final id in ids) id: null});
        return state.copyWith(failure: failure);
      },
    );
  }

  /// What the backend will answer for [id]: a request for a private profile, else a follow.
  FollowStatus _expectedStatus(String id) {
    final person = [for (final list in state.people.values) ...list]
        .where((person) => person.id == id)
        .firstOrNull;
    return person?.isPrivate == true
        ? FollowStatus.pending
        : FollowStatus.accepted;
  }

  /// Sets (or, for `null`, removes) the follow state of each person.
  void _setLocalFollows(Map<String, FollowStatus?> changes) {
    final follows = {...state.follows};
    for (final MapEntry(:key, :value) in changes.entries) {
      value == null || value == FollowStatus.none
          ? follows.remove(key)
          : follows[key] = value;
    }
    emit(state.copyWith(follows: follows));
  }

  /// "Continue" and "Skip" on Follow: sign-up is finished, on to Home.
  Future<void> finishFollow() => _finish();

  Future<void> _finish() async {
    await run(
      prevent: state.loading && state.step == followStep,
      loading: state.copyWith(loading: true, failure: null),
      _completeSignup.call,
      onSuccess: (_) {
        _go(AppRoutes.home);
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
    );
  }

  /// "Leave" in the leave dialog. Progress is already saved, so only the session ends; the session is
  /// dropped on this device even when the server cannot be reached.
  Future<void> leave() async {
    emit(state.copyWith(loading: true));
    await _clearLocalProfile();
    try {
      await _auth.signOut();
    } on Failure {
      // Dropped on this device regardless.
    }
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
