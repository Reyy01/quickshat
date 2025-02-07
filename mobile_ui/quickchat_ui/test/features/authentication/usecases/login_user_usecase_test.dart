import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/data/dto/LoginUser.dto.dart';
import 'package:quickchat_ui/features/authentication/usecase/login_user.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late LoginUserUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = LoginUserUsecase(authBloc: mockAuthBloc);
  });

  test('should call loginUser event', () {
    final LoginUserDto dto = LoginUserDto(
      username: 'tUsername',
      password: 'tPassword',
    );

    // act
    usecase.execute(dto);

    // assert
    verify(mockAuthBloc.add(AuthEvent.loginUser(loginUserDto: dto)));
  });
}
