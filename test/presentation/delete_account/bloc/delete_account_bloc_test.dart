import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/delete_account/bloc/delete_account_bloc.dart';
import 'package:skelter/presentation/delete_account/bloc/delete_account_event.dart';
import 'package:skelter/presentation/delete_account/bloc/delete_account_state.dart';
import 'package:skelter/presentation/delete_account/enum/delete_account_reasons.dart';
import 'package:skelter/services/firebase_auth_services.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late DeleteAccountBloc bloc;
  late MockFirebaseAuthService mockFirebaseAuthService;
  late MockPerformanceMonitoringService mockPerformanceService;

  setUpAll(() {
    registerFallbackValue((String error, {StackTrace? stackTrace}) {});
  });

  setUp(() {
    mockFirebaseAuthService = MockFirebaseAuthService();
    mockPerformanceService = MockPerformanceMonitoringService();

    final sl = GetIt.instance;
    if (sl.isRegistered<FirebaseAuthService>()) {
      sl.unregister<FirebaseAuthService>();
    }
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<FirebaseAuthService>(mockFirebaseAuthService);
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = DeleteAccountBloc();
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<FirebaseAuthService>()) {
      sl.unregister<FirebaseAuthService>();
    }
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('DeleteAccountBloc', () {
    test('initial state should have no reason selected', () {
      expect(bloc.state.selectedReason, isNull);
      expect(bloc.state.otherReasonText, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, isNull);
    });

    group('DeleteReasonSelectedEvent', () {
      blocTest<DeleteAccountBloc, DeleteAccountState>(
        'should emit state with selected reason',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const DeleteReasonSelectedEvent(
            reason: DeleteAccountReasons.dislikeTheApp,
          ),
        ),
        expect: () => [
          isA<DeleteAccountInputUpdatedState>().having(
            (s) => s.selectedReason,
            'selectedReason',
            DeleteAccountReasons.dislikeTheApp,
          ),
        ],
      );

      blocTest<DeleteAccountBloc, DeleteAccountState>(
        'should update reason to other',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const DeleteReasonSelectedEvent(reason: DeleteAccountReasons.other),
        ),
        expect: () => [
          isA<DeleteAccountInputUpdatedState>().having(
            (s) => s.selectedReason,
            'selectedReason',
            DeleteAccountReasons.other,
          ),
        ],
      );
    });

    group('DeleteOtherReasonTextChangedEvent', () {
      blocTest<DeleteAccountBloc, DeleteAccountState>(
        'should emit state with updated other reason text',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const DeleteOtherReasonTextChangedEvent(
            text: 'I have privacy concerns',
          ),
        ),
        expect: () => [
          isA<DeleteAccountInputUpdatedState>().having(
            (s) => s.otherReasonText,
            'otherReasonText',
            'I have privacy concerns',
          ),
        ],
      );

      blocTest<DeleteAccountBloc, DeleteAccountState>(
        'should preserve selected reason when text changes',
        build: () => bloc,
        seed: () => const DeleteAccountState(
          selectedReason: DeleteAccountReasons.other,
          otherReasonText: '',
          isLoading: false,
          errorMessage: null,
        ),
        act: (bloc) => bloc.add(
          const DeleteOtherReasonTextChangedEvent(text: 'My reason'),
        ),
        expect: () => [
          isA<DeleteAccountInputUpdatedState>()
              .having(
                (s) => s.selectedReason,
                'selectedReason',
                DeleteAccountReasons.other,
              )
              .having((s) => s.otherReasonText, 'otherReasonText', 'My reason'),
        ],
      );
    });

    group('DeleteAccountSubmittedEvent', () {
      blocTest<DeleteAccountBloc, DeleteAccountState>(
        'should emit loading then success when delete succeeds',
        build: () {
          when(
            () => mockFirebaseAuthService.deleteCurrentUser(
              onError: any(named: 'onError'),
            ),
          ).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteAccountSubmittedEvent()),
        expect: () => [
          isA<DeleteAccountState>().having(
            (s) => s.isLoading,
            'isLoading',
            true,
          ),
          isA<DeleteAccountState>().having(
            (s) => s.isLoading,
            'isLoading',
            false,
          ),
          isA<DeleteAccountSuccessState>(),
        ],
      );
    });
  });
}
