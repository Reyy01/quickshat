import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/usecase/auto_login.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late AutoLoginUserUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = AutoLoginUserUsecase(authBloc: mockAuthBloc);
  });

  test('should call autoLoginUser event', () {
    // act
    usecase.execute();

    // assert
    verify(mockAuthBloc.add(const AuthEvent.autoLoginUser()));
  });
}
