import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/contact_us/bloc/contact_us_bloc.dart';
import 'package:skelter/presentation/contact_us/bloc/contact_us_event.dart';
import 'package:skelter/presentation/contact_us/bloc/contact_us_state.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late ContactUsBloc bloc;
  late MockAppLocalizations mockLocalizations;

  setUp(() {
    mockLocalizations = MockAppLocalizations();

    when(
      () => mockLocalizations.name_cannot_be_empty,
    ).thenReturn('Name cannot be empty');
    when(
      () => mockLocalizations.email_cant_be_empty,
    ).thenReturn('Email cannot be empty');
    when(() => mockLocalizations.invalid_email).thenReturn('Invalid email');
    when(
      () => mockLocalizations.message_cannot_be_empty,
    ).thenReturn('Message cannot be empty');
    when(
      () => mockLocalizations.messageTooLong(any()),
    ).thenReturn('Message too long');
    when(
      () => mockLocalizations.file_cannot_be_empty,
    ).thenReturn('File cannot be empty');
    when(
      () => mockLocalizations.pick_image_error,
    ).thenReturn('Error picking image');
    when(
      () => mockLocalizations.pick_pdf_error,
    ).thenReturn('Error picking PDF');

    bloc = ContactUsBloc(localizations: mockLocalizations);
  });

  tearDown(() {
    bloc.close();
  });

  group('ContactUsBloc', () {
    test('initial state should have empty fields', () {
      expect(bloc.state.name, isEmpty);
      expect(bloc.state.email, isEmpty);
      expect(bloc.state.description, isEmpty);
      expect(bloc.state.isSubmitting, isFalse);
    });

    group('NameChangedEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should update name',
        build: () => bloc,
        act: (bloc) => bloc.add(NameChangedEvent(name: 'John Doe')),
        expect: () => [
          isA<ContactUsState>().having((s) => s.name, 'name', 'John Doe'),
        ],
      );
    });

    group('EmailChangedEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should update email',
        build: () => bloc,
        act: (bloc) => bloc.add(EmailChangedEvent(email: 'john@test.com')),
        expect: () => [
          isA<ContactUsState>().having(
            (s) => s.email,
            'email',
            'john@test.com',
          ),
        ],
      );
    });

    group('DescriptionChangedEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should update description',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const DescriptionChangedEvent(message: 'Help needed')),
        expect: () => [
          isA<ContactUsState>().having(
            (s) => s.description,
            'description',
            'Help needed',
          ),
        ],
      );
    });

    group('EmailErrorEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should set email error',
        build: () => bloc,
        act: (bloc) => bloc.add(EmailErrorEvent(error: 'Invalid email')),
        expect: () => [
          isA<ContactUsState>().having(
            (s) => s.emailError,
            'emailError',
            'Invalid email',
          ),
        ],
      );
    });

    group('NameErrorEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should set name error',
        build: () => bloc,
        act: (bloc) => bloc.add(NameErrorEvent(error: 'Name required')),
        expect: () => [
          isA<ContactUsState>().having(
            (s) => s.nameError,
            'nameError',
            'Name required',
          ),
        ],
      );
    });

    group('DescriptionErrorEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should set description error',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const DescriptionErrorEvent(error: 'Description required'),
        ),
        expect: () => [
          isA<ContactUsState>().having(
            (s) => s.descriptionError,
            'descriptionError',
            'Description required',
          ),
        ],
      );
    });

    group('SubmitFormEvent', () {
      blocTest<ContactUsBloc, ContactUsState>(
        'should emit PickedFilesErrorState when all fields empty',
        build: () => bloc,
        act: (bloc) => bloc.add(SubmitFormEvent()),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<PickedFilesErrorState>(),
          isA<ContactUsState>().having(
            (s) => s.nameError,
            'nameError',
            'Name cannot be empty',
          ),
          isA<ContactUsState>().having(
            (s) => s.emailError,
            'emailError',
            'Email cannot be empty',
          ),
          isA<ContactUsState>().having(
            (s) => s.descriptionError,
            'descriptionError',
            'Message cannot be empty',
          ),
        ],
      );
    });
  });
}
