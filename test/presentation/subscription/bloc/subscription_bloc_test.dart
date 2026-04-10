import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_bloc.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/services/performance_monitoring_service.dart';
import 'package:skelter/services/subscription_service.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late SubscriptionBloc bloc;
  late MockSubscriptionService mockSubscriptionService;
  late MockPerformanceMonitoringService mockPerformanceService;
  late MockAppLocalizations mockLocalizations;

  setUp(() {
    mockSubscriptionService = MockSubscriptionService();
    mockPerformanceService = MockPerformanceMonitoringService();
    mockLocalizations = MockAppLocalizations();

    when(
      () => mockLocalizations.no_subscription_available,
    ).thenReturn('No subscriptions available');
    when(
      () => mockLocalizations.failed_to_load_subscriptions,
    ).thenReturn('Failed to load subscriptions');
    when(
      () => mockLocalizations.restore_success,
    ).thenReturn('Restore successful');
    when(
      () => mockLocalizations.no_active_subscriptions,
    ).thenReturn('No active subscriptions');
    when(() => mockLocalizations.restore_error).thenReturn('Restore error:');

    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = SubscriptionBloc(
      localization: mockLocalizations,
      subscriptionService: mockSubscriptionService,
    );
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('SubscriptionBloc', () {
    test('initial state should be FetchSubscriptionPlanLoadingState', () {
      expect(bloc.state, isA<FetchSubscriptionPlanLoadingState>());
      expect(bloc.state.isLoadingPackages, isTrue);
      expect(bloc.state.packages, isEmpty);
    });

    group('FetchSubscriptionPackagesEvent', () {
      blocTest<SubscriptionBloc, SubscriptionState>(
        'should emit failure when no packages available',
        build: () {
          when(
            () => mockSubscriptionService.getPackages(),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(FetchSubscriptionPackagesEvent()),
        expect: () => [
          isA<FetchSubscriptionPlanLoadingState>(),
          isA<FetchSubscriptionPlanFailureState>(),
        ],
      );

      blocTest<SubscriptionBloc, SubscriptionState>(
        'should emit failure when service throws exception',
        build: () {
          when(
            () => mockSubscriptionService.getPackages(),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(FetchSubscriptionPackagesEvent()),
        expect: () => [
          isA<FetchSubscriptionPlanLoadingState>(),
          isA<FetchSubscriptionPlanFailureState>(),
        ],
      );
    });

    group('ClearSnackBarMessageEvent', () {
      blocTest<SubscriptionBloc, SubscriptionState>(
        'should emit loaded state with cleared snackbar',
        build: () => bloc,
        act: (bloc) => bloc.add(ClearSnackBarMessageEvent()),
        expect: () => [isA<FetchSubscriptionPlanLoadedState>()],
      );
    });

    group('RestoreSubscriptionEvent', () {
      blocTest<SubscriptionBloc, SubscriptionState>(
        'should emit success message when restore returns true',
        build: () {
          when(
            () => mockSubscriptionService.restorePurchases(),
          ).thenAnswer((_) async => true);
          return bloc;
        },
        act: (bloc) => bloc.add(RestoreSubscriptionEvent()),
        expect: () => [
          isA<FetchSubscriptionPlanLoadedState>().having(
            (s) => s.isRestoring,
            'isRestoring',
            true,
          ),
          isA<FetchSubscriptionPlanLoadedState>()
              .having((s) => s.isRestoring, 'isRestoring', false)
              .having(
                (s) => s.restoreStatusMessage,
                'message',
                'Restore successful',
              ),
        ],
      );

      blocTest<SubscriptionBloc, SubscriptionState>(
        'should emit no active subscriptions when restore returns false',
        build: () {
          when(
            () => mockSubscriptionService.restorePurchases(),
          ).thenAnswer((_) async => false);
          return bloc;
        },
        act: (bloc) => bloc.add(RestoreSubscriptionEvent()),
        expect: () => [
          isA<FetchSubscriptionPlanLoadedState>().having(
            (s) => s.isRestoring,
            'isRestoring',
            true,
          ),
          isA<FetchSubscriptionPlanLoadedState>()
              .having((s) => s.isRestoring, 'isRestoring', false)
              .having(
                (s) => s.restoreStatusMessage,
                'message',
                'No active subscriptions',
              ),
        ],
      );
    });
  });
}
