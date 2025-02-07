import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/data/dto/RegisterUser.dto.dart';
import 'package:quickchat_ui/features/authentication/usecase/register_user.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late RegisterUserUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = RegisterUserUsecase(authBloc: mockAuthBloc);
  });

  test('should call registerUser event', () {
    const RegisterUserDto dto = RegisterUserDto(
      name: 'tName',
      username: 'tUsername',
      password: 'tPassword',
    );
    // act
    usecase.execute(dto);

    // assert
    verify(
        mockAuthBloc.add(const AuthEvent.registerUser(registerUserDto: dto)));
  });
}
