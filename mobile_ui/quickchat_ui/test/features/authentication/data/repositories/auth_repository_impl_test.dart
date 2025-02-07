import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/core/logic/cache_exeption.dart';
import 'package:quickchat_ui/core/logic/error_messages.dart';
import 'package:quickchat_ui/core/logic/result.dart';
import 'package:quickchat_ui/core/logic/server_exeption.dart';
import 'package:quickchat_ui/core/network/network_info.dart';
import 'package:quickchat_ui/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:quickchat_ui/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginData.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginUser.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/RegisterUser.dto.dart';
import 'package:quickchat_ui/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:quickchat_ui/features/authentication/domain/repositories/auth_repository.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks(<Type>[
  NetworkInfo,
  AuthRemoteDatasource,
  AuthLocalDatasource,
])
void main() {
  late MockNetworkInfo mockNetworkInfo;
  late MockAuthRemoteDatasource mockAuthRemoteDatasource;
  late MockAuthLocalDatasource mockAuthLocalDatasource;
  late AuthRepository authRepository;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockAuthRemoteDatasource = MockAuthRemoteDatasource();
    mockAuthLocalDatasource = MockAuthLocalDatasource();
    authRepository = AuthRepositoryImpl(
      networkInfo: mockNetworkInfo,
      authRemoteDatasource: mockAuthRemoteDatasource,
      authLocalDatasource: mockAuthLocalDatasource,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('connectServer', () {
    runTestsOnline(() {
      test(
          'should return unit when the call to remote data source is successful',
          () async {
        // arrange
        when(mockAuthRemoteDatasource.connectServer())
            .thenAnswer((_) async => unit);

        // act
        final Result<Unit> result = await authRepository.connectServer();

        // assert
        expect(result, const Result<Unit>.ok(data: unit));
      });
    });

    runTestsOffline(() {
      test('should return no internet connection when the device is offline',
          () async {
        // act
        final Result<Unit> result = await authRepository.connectServer();

        // assert
        expect(
            result, const Result<Unit>.fail(error: ERR_NO_INTERNET_CONNECTION));
      });
    });
  });

  group('loginUser', () {
    final LoginUserDto tLogin = LoginUserDto(
      username: 'tUsername',
      password: 'tPassword',
    );

    final String tLoginData200 =
        fixture('authentication', 'get.login.data.json');

    runTestsOnline(() {
      test(
          'should return server error message when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(mockAuthRemoteDatasource.loginUser(any)).thenThrow(
          ServerException(ERR_DEFAULT),
        );

        // act
        final Result<LoginDatasDto> result =
            await authRepository.loginUser(tLogin);

        // assert
        expect(
            result,
            const Result<LoginDatasDto>.fail(
              error: ERR_DEFAULT,
            ));
      });

      test(
          'should return login data when the call to remote data source is successful',
          () async {
        // arrange

        when(mockAuthRemoteDatasource.loginUser(any)).thenAnswer((_) async =>
            LoginDatasDto.fromJson(json.decode(tLoginData200)['data']));
        when(mockAuthLocalDatasource.saveToken(any)).thenAnswer((_) => unit);
        when(mockAuthLocalDatasource.saveCredentials(any))
            .thenAnswer((_) async => unit);

        // act
        final Result<LoginDatasDto> result =
            await authRepository.loginUser(tLogin);

        // assert
        expect(
            result,
            Result<LoginDatasDto>.ok(
              data: LoginDatasDto.fromJson(json.decode(tLoginData200)['data']),
            ));
      });
    });

    runTestsOffline(() {
      test('should return no internet connection when the device is offline',
          () async {
        // act
        final result = await authRepository.loginUser(tLogin);

        // assert
        expect(
            result,
            const Result<LoginDatasDto>.fail(
              error: ERR_NO_INTERNET_CONNECTION,
            ));
      });
    });
  });

  group('autoLoginUser', () {
    final LoginUserDto tLogin = LoginUserDto(
      username: 'tUsername',
      password: 'tPassword',
    );

    final String tLoginData200 =
        fixture('authentication', 'get.login.data.json');

    runTestsOnline(() {
      test(
          'should return server error message when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(mockAuthLocalDatasource.getCredentials())
            .thenAnswer((_) async => tLogin);
        when(mockAuthRemoteDatasource.loginUser(any)).thenThrow(
          ServerException(ERR_DEFAULT),
        );

        // act
        final Result<LoginDatasDto> result =
            await authRepository.autoLoginUser();

        // assert
        expect(
            result,
            const Result<LoginDatasDto>.fail(
              error: ERR_DEFAULT,
            ));
      });

      test(
          'should return login data when the call to remote data source is successful',
          () async {
        // arrange
        when(mockAuthLocalDatasource.getCredentials())
            .thenAnswer((_) async => tLogin);
        when(mockAuthRemoteDatasource.loginUser(any)).thenAnswer((_) async =>
            LoginDatasDto.fromJson(json.decode(tLoginData200)['data']));

        // act
        final Result<LoginDatasDto> result =
            await authRepository.autoLoginUser();

        // assert
        expect(
            result,
            Result<LoginDatasDto>.ok(
              data: LoginDatasDto.fromJson(json.decode(tLoginData200)['data']),
            ));
      });
    });

    runTestsOffline(() {
      test('should return no internet connection when the device is offline',
          () async {
        // act
        final result = await authRepository.autoLoginUser();

        // assert
        expect(
            result,
            const Result<LoginDatasDto>.fail(
              error: ERR_NO_INTERNET_CONNECTION,
            ));
      });
    });
  });

  group('logoutUser', () {
    test('should return unit when the call to local data source is successful',
        () async {
      // arrange
      when(mockAuthLocalDatasource.deleteCredetialsAndTokens())
          .thenAnswer((_) => unit);
      // act
      final Result<Unit> result = await authRepository.logoutUser();

      // assert
      expect(result, const Result<Unit>.ok(data: unit));
    });

    test(
        'should return server error message when the call to local data source is unsuccessful',
        () async {
      // arrange
      when(mockAuthLocalDatasource.deleteCredetialsAndTokens())
          .thenThrow(CacheException(ERR_DEFAULT));

      // act
      final Result<Unit> result = await authRepository.logoutUser();

      // assert
      expect(
          result,
          const Result<Unit>.fail(
            error: ERR_DEFAULT,
          ));
    });
  });

  group('registerUser', () {
    const RegisterUserDto tRegister = RegisterUserDto(
      name: 'tName',
      username: 'tUsername',
      password: 'tPassword',
    );

    runTestsOnline(() {
      test(
          'should return server error message when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(mockAuthRemoteDatasource.registerUser(any)).thenThrow(
          ServerException(ERR_DEFAULT),
        );

        // act
        final Result<Unit> result =
            await authRepository.registerUser(tRegister);

        // assert
        expect(
            result,
            const Result<Unit>.fail(
              error: ERR_DEFAULT,
            ));
      });

      test(
          'should return unit when the call to remote data source is successful',
          () async {
        // arrange
        when(mockAuthRemoteDatasource.registerUser(any))
            .thenAnswer((_) async => unit);
        when(mockAuthLocalDatasource.saveCredentials(any))
            .thenAnswer((_) async => unit);

        // act
        final Result<Unit> result =
            await authRepository.registerUser(tRegister);

        // assert
        expect(result, const Result<Unit>.ok(data: unit));
      });
    });

    runTestsOffline(() {
      test('should return no internet connection when the device is offline',
          () async {
        // act
        final result = await authRepository.registerUser(tRegister);

        // assert
        expect(
            result,
            const Result<Unit>.fail(
              error: ERR_NO_INTERNET_CONNECTION,
            ));
      });
    });
  });

  group('getCredentials', () {
    final LoginUserDto tLogin = LoginUserDto(
      username: 'tUsername',
      password: 'tPassword',
    );

    runTestsOnline(() {
      test(
          'should return server error message when the call to local data source is unsuccessful',
          () async {
        // arrange
        when(mockAuthLocalDatasource.getCredentials())
            .thenThrow(ServerException(ERR_GET_CREDENTIALS));

        // act
        final Result<LoginUserDto> result =
            await authRepository.getCredentials();

        // assert
        expect(
            result,
            const Result<LoginUserDto>.fail(
              error: ERR_GET_CREDENTIALS,
            ));
      });

      test(
          'should return login data when the call to local data source is successful',
          () async {
        // arrange
        when(mockAuthLocalDatasource.getCredentials())
            .thenAnswer((_) async => tLogin);

        // act
        final Result<LoginUserDto> result =
            await authRepository.getCredentials();

        // assert
        expect(
            result,
            Result<LoginUserDto>.ok(
              data: tLogin,
            ));
      });
    });

    runTestsOffline(() {
      test('should return no internet connection when the device is offline',
          () async {
        // act
        final result = await authRepository.getCredentials();

        // assert
        expect(
            result,
            const Result<LoginUserDto>.fail(
              error: ERR_NO_INTERNET_CONNECTION,
            ));
      });
    });
  });
}
