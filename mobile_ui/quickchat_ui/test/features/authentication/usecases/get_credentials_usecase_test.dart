import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/usecase/get_credentials.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late GetCredentialsUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = GetCredentialsUsecase(authBloc: mockAuthBloc);
  });

  test('should call getCredentials event', () {
    // act
    usecase.execute();

    // assert
    verify(mockAuthBloc.add(const AuthEvent.getCredentials()));
  });
}
