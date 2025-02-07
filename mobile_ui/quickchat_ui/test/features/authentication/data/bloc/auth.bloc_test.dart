import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/core/logic/auth_status.dart';
import 'package:quickchat_ui/core/logic/navigate_page.dart';
import 'package:quickchat_ui/core/logic/result.dart';
import 'package:quickchat_ui/core/logic/state_status.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginData.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginUser.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/RegisterUser.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/UserData.dto.dart';
import 'package:quickchat_ui/features/authentication/domain/repositories/auth_repository.dart';
import 'package:mockito/annotations.dart';

import 'auth.bloc_test.mocks.dart';

@GenerateMocks(<Type>[AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  group('_ConnnectServer', () {
    test(
        'should emit [loadingState, loadedState, loginPage] when _ConnnectServer event is added',
        () {
      final AuthState state = AuthState.initial();
      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          navigatePage: NavigatePage.loginPage,
        ),
      ];

      // act
      authBloc.add(const AuthEvent.connnectServer());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });

  group('_GetCredentials', () {
    test(
        'should emit [loadingState, loadedState, loginUser] when _GetCredentials event is added',
        () {
      final AuthState state = AuthState.initial();

      final LoginUserDto tLoginData = LoginUserDto(
        username: 'testUserName',
        password: 'testPassword',
      );

      const LoginDatasDto tLogin = LoginDatasDto(
        token: 'testToken',
        user: UserDataDto(
          id: 'test',
          name: 'tName',
          userName: 'tUserName',
        ),
      );

      when(mockAuthRepository.getCredentials())
          .thenAnswer((_) async => Result<LoginUserDto>.ok(data: tLoginData));
      when(mockAuthRepository.loginUser(argThat(isA<LoginUserDto>())))
          .thenAnswer(
              (_) async => const Result<LoginDatasDto>.ok(data: tLogin));
      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          authStatus: AuthStatus.authenticated,
          loginDatas: tLogin,
          navigatePage: NavigatePage.homePage,
        ),
      ];

      // act
      authBloc.add(const AuthEvent.getCredentials());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });

  group('_RegisterUser', () {
    test(
        'should emit [loadingState, errorState, loadedState] when _RegisterUser event is failure',
        () {
      final AuthState state = AuthState.initial();

      const RegisterUserDto tRegisterData = RegisterUserDto(
        name: 'tName',
        username: 'tUserName',
        password: 'tPassword',
      );

      when(mockAuthRepository.registerUser(any))
          .thenAnswer((_) async => const Result<Unit>.fail(error: 'error'));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          errorMessage: 'error',
          stateStatus: StateStatus.errorState,
        ),
        state.copyWith(
          errorMessage: 'error',
          stateStatus: StateStatus.loadedState,
        ),
      ];

      // act
      authBloc
          .add(const AuthEvent.registerUser(registerUserDto: tRegisterData));

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });

    test(
        'should emit [loadingState, loadedState, defaultPage, hasRegisteredUser, loadedState] when _RegisterUser event is success',
        () {
      final AuthState state = AuthState.initial();

      const RegisterUserDto tRegisterData = RegisterUserDto(
        name: 'tName',
        username: 'tUserName',
        password: 'tPassword',
      );

      when(mockAuthRepository.registerUser(any))
          .thenAnswer((_) async => const Result<Unit>.ok(data: unit));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadingState,
          navigatePage: NavigatePage.defaultPage,
          hasRegisteredUser: true,
        ),
        state.copyWith(
          navigatePage: NavigatePage.defaultPage,
          hasRegisteredUser: false,
          stateStatus: StateStatus.loadedState,
        ),
      ];

      // act
      authBloc
          .add(const AuthEvent.registerUser(registerUserDto: tRegisterData));

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });

  group('_LoginUser', () {
    test(
        'should emit [loadingState, errorState, loadedState] when _LoginUser event is failure',
        () {
      final AuthState state = AuthState.initial();

      final LoginUserDto tLoginData = LoginUserDto(
        username: 'testUserName',
        password: 'testPassword',
      );

      when(mockAuthRepository.loginUser(any)).thenAnswer(
          (_) async => const Result<LoginDatasDto>.fail(error: 'error'));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.errorState,
          errorMessage: 'error',
        ),
        state.copyWith(
          errorMessage: 'error',
          stateStatus: StateStatus.loadedState,
        ),
      ];

      // act
      authBloc.add(AuthEvent.loginUser(loginUserDto: tLoginData));

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });

    test(
        'should emit [loadingState, errorState, loadedState] when _LoginUser event is success',
        () {
      final AuthState state = AuthState.initial();

      final LoginUserDto tLoginData = LoginUserDto(
        username: 'testUserName',
        password: 'testPassword',
      );

      const LoginDatasDto tLogin = LoginDatasDto(
        token: 'testToken',
        user: UserDataDto(
          id: 'test',
          name: 'tName',
          userName: 'tUserName',
        ),
      );

      when(mockAuthRepository.loginUser(any)).thenAnswer(
          (_) async => const Result<LoginDatasDto>.ok(data: tLogin));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          authStatus: AuthStatus.authenticated,
          loginDatas: tLogin,
          navigatePage: NavigatePage.homePage,
        ),
      ];

      // act
      authBloc.add(AuthEvent.loginUser(loginUserDto: tLoginData));

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });

  group('_AutoLoginUser', () {
    test(
        'should emit [loadingState, errorState, loadedState] when _AutoLoginUser event is failure',
        () {
      final AuthState state = AuthState.initial();

      when(mockAuthRepository.autoLoginUser()).thenAnswer(
          (_) async => const Result<LoginDatasDto>.fail(error: 'error'));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          errorMessage: 'error',
          stateStatus: StateStatus.errorState,
          authStatus: AuthStatus.unauthenticated,
        ),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          errorMessage: 'error',
          authStatus: AuthStatus.unauthenticated,
        ),
      ];

      // act
      authBloc.add(const AuthEvent.autoLoginUser());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });

    test(
        'should emit [loadingState, loadedState, homePage] when _AutoLoginUser event is success',
        () {
      final AuthState state = AuthState.initial();

      const LoginDatasDto tLogin = LoginDatasDto(
        token: 'testToken',
        user: UserDataDto(
          id: 'test',
          name: 'tName',
          userName: 'tUserName',
        ),
      );

      when(mockAuthRepository.autoLoginUser()).thenAnswer(
          (_) async => const Result<LoginDatasDto>.ok(data: tLogin));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          authStatus: AuthStatus.authenticated,
          loginDatas: tLogin,
          navigatePage: NavigatePage.homePage,
        ),
      ];

      // act
      authBloc.add(const AuthEvent.autoLoginUser());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });

  group('_LogoutUser', () {
    test(
        'should emit [loadingState, errorState, loadedState] when _LogoutUser event is failure',
        () {
      final AuthState state = AuthState.initial();

      when(mockAuthRepository.logoutUser())
          .thenAnswer((_) async => const Result<Unit>.fail(error: 'error'));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          errorMessage: 'error',
          stateStatus: StateStatus.errorState,
        ),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          errorMessage: 'error',
        ),
      ];

      // act
      authBloc.add(const AuthEvent.logoutUser());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });

    test(
        'should emit [loadingState, loadedState, unauthenticated] when _LogoutUser event is success',
        () {
      final AuthState state = AuthState.initial();

      when(mockAuthRepository.logoutUser())
          .thenAnswer((_) async => const Result<Unit>.ok(data: unit));

      // arrange
      final List<AuthState> expectedStates = <AuthState>[
        state.copyWith(stateStatus: StateStatus.loadingState),
        state.copyWith(
          stateStatus: StateStatus.loadedState,
          authStatus: AuthStatus.unauthenticated,
          loginDatas: null,
          navigatePage: NavigatePage.loginPage,
        ),
      ];

      // act
      authBloc.add(const AuthEvent.logoutUser());

      // assert
      expectLater(authBloc.stream, emitsInOrder(expectedStates));
    });
  });
}
