import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/core/logic/cache_exeption.dart';
import 'package:quickchat_ui/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginUser.dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_local_datasource_test.mocks.dart';

@GenerateMocks(<Type>[
  FlutterSecureStorage,
  SharedPreferences,
])
void main() {
  late MockFlutterSecureStorage mockFlutterSecureStorage;
  late MockSharedPreferences mockSharedPreferences;
  late AuthLocalDatasource authLocalDatasource;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    mockSharedPreferences = MockSharedPreferences();
    authLocalDatasource = AuthLocalDatasourceImpl(
      flutterSecureStorage: mockFlutterSecureStorage,
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('saveToken', () {
    test('should throw CacheException when saving token fails', () {
      // arrange
      when(mockSharedPreferences.setString(any, any)).thenThrow('error');

      // act
      final call = authLocalDatasource.saveToken;

      // assert
      expect(() => call('token'), throwsA(isA<CacheException>()));
    });
    test('should save token', () {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      final Unit result = authLocalDatasource.saveToken('token');

      // assert
      expect(result, unit);
    });
  });

  group('saveCredentials', () {
    test('should throw CacheException when saving credentials fails', () {
      // arrange
      when(mockFlutterSecureStorage.write(
              key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow('error');

      // act
      final call = authLocalDatasource.saveCredentials;

      // assert
      expect(
          () => call(LoginUserDto(
                username: 'username',
                password: 'password',
              )),
          throwsA(isA<CacheException>()));
    });
    test('should save credentials', () async {
      // arrange
      when(mockFlutterSecureStorage.write(
              key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => true);

      // act
      final Unit result = await authLocalDatasource.saveCredentials(
          LoginUserDto(username: 'username', password: 'password'));

      // assert
      expect(result, unit);
    });
  });

  group('saveUser', () {
    test('should throw CacheException when saving user fails', () {
      // arrange
      when(mockSharedPreferences.setString(any, any)).thenThrow('error');

      // act
      final call = authLocalDatasource.saveUser;

      // assert
      expect(() => call('userId'), throwsA(isA<CacheException>()));
    });
    test('should save user', () {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);

      // act
      final Unit result = authLocalDatasource.saveUser('userId');

      // assert
      expect(result, unit);
    });
  });

  group('getCredentials', () {
    test('should throw CacheException when getting credentials fails', () {
      // arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenThrow('error');

      // act
      final call = authLocalDatasource.getCredentials;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
    test('should get credentials', () async {
      // arrange
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'username');

      // act
      final LoginUserDto result = await authLocalDatasource.getCredentials();

      // assert
      expect(result, isA<LoginUserDto>());
    });
  });

  group('deleteCredetialsAndTokens', () {
    test(
        'should throw CacheException when deleting credentials and tokens fails',
        () {
      // arrange
      when(mockFlutterSecureStorage.delete(key: anyNamed('key')))
          .thenThrow('error');
      when(mockSharedPreferences.remove(any)).thenThrow('error');

      // act
      final call = authLocalDatasource.deleteCredetialsAndTokens;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
    test('should delete credentials and tokens', () {
      // arrange
      when(mockFlutterSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => true);

      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

      // act
      final Unit result = authLocalDatasource.deleteCredetialsAndTokens();

      // assert
      expect(result, unit);
    });
  });
}
