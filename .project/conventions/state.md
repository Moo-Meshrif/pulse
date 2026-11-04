# State
Covers: state holders, state shape, Cubit rules
Does not cover: navigation from state (navigation.md), failures (errors.md)
Rule: local UI state setState/ValueNotifier; feature state flutter_bloc Cubit extending `BaseCubit` (lib/core/state: emit-after-close guard + `run(action, {loading, onSuccess, onFailure})` returning the state to emit, null = emit nothing). `@freezed abstract class` single-class state when data must survive (`SignInState`, nullable fields reset via `copyWith(x: null)`); simple states hand-written Equatable (`SplashState`). Run build_runner after @freezed/@injectable changes.
Screen provides its Cubit: `BlocProvider(create: (_) => getIt<…>())`; Cubits `@injectable` (transient).
Never: Bloc, Cubit into Cubit, context in Cubit.
Example: lib/features/auth/presentation/cubit/sign_in_cubit.dart
Exceptions: OnboardingCubit is a plain Cubit<T>.
