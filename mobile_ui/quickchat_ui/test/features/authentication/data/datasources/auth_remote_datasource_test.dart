import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/config.dart';
import 'package:quickchat_ui/core/logic/server_exeption.dart';
import 'package:quickchat_ui/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginData.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginUser.dto.dart';
import 'package:quickchat_ui/features/authentication/data/dto/RegisterUser.dto.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks(<Type>[
  Dio,
  Config,
])
void main() {
  late MockDio mockDio;
  late MockConfig mockConfig;
  late AuthRemoteDatasource authRemoteDatasource;

  setUp(() {
    mockDio = MockDio();
    mockConfig = MockConfig();
    authRemoteDatasource = AuthRemoteDatasourceImpl(
      dio: mockDio,
      config: mockConfig,
    );

    when(mockConfig.quickChatService).thenAnswer((_) => 'test');
  });

  group('connectServer', () {
    test('should throw ServerException when error is DioException fails',
        () async {
      // arrange
      when(mockDio.head(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      // act
      final call = authRemoteDatasource.connectServer;

      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });

    test('should connect to server', () async {
      // arrange
      when(mockDio.head(any)).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      // act
      final Unit result = await authRemoteDatasource.connectServer();

      // assert
      expect(result, unit);
    });
  });

  group('loginUser', () {
    final String tLoginData200 =
        fixture('authentication', 'get.login.data.json');
    test('should throw ServerException when error is DioException fails',
        () async {
      // arrange
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      // act
      final call = authRemoteDatasource.loginUser;

      // assert
      expect(() => call(LoginUserDto(username: '', password: '')),
          throwsA(isA<ServerException>()));
    });

    test('should login user', () async {
      // arrange
      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response<dynamic>(
                requestOptions: RequestOptions(path: ''),
                data: json.decode(tLoginData200),
                statusCode: 200,
              ));

      // act
      final LoginDatasDto result = await authRemoteDatasource.loginUser(
        LoginUserDto(
          username: 'tUserName',
          password: 'tPassword',
        ),
      );

      // assert
      expect(
          result, LoginDatasDto.fromJson(json.decode(tLoginData200)['data']));
    });
  });

  group('registerUser', () {
    const RegisterUserDto tRegisterData = RegisterUserDto(
      name: 'tName',
      username: 'tUserName',
      password: 'tPassword',
    );
    test('should throw ServerException when error is DioException fails',
        () async {
      // arrange
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      ));

      // act
      final call = authRemoteDatasource.registerUser;

      // assert
      expect(() => call(tRegisterData), throwsA(isA<ServerException>()));
    });

    test('should register user', () async {
      // arrange
      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 201,
              ));

      // act
      final Unit result =
          await authRemoteDatasource.registerUser(tRegisterData);

      // assert
      expect(result, unit);
    });
  });
}
