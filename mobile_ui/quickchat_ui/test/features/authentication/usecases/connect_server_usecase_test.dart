import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/auth_bloc.dart';
import 'package:quickchat_ui/features/authentication/usecase/connect_server.usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late ConnectServerUsecase usecase;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    usecase = ConnectServerUsecase(authBloc: mockAuthBloc);
  });

  test('should call connnectServer event', () {
    // act
    usecase.execute();

    // assert
    verify(mockAuthBloc.add(const AuthEvent.connnectServer()));
  });
}
