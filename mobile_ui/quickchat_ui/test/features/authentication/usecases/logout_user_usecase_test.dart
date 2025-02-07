import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/usecase/logout_user.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late LogoutUserUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = LogoutUserUsecase(authBloc: mockAuthBloc);
  });

  test('should call logoutUser event', () {
    // act
    usecase.execute();

    // assert
    verify(mockAuthBloc.add(const AuthEvent.logoutUser()));
  });
}
