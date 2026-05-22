import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skelter/presentation/profile/bloc/profile_bloc.dart';
import 'package:skelter/presentation/profile/bloc/profile_event.dart';
import 'package:skelter/presentation/profile/bloc/profile_state.dart';
import 'package:skelter/services/performance_monitoring_service.dart';

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late ProfileBloc bloc;
  late MockPerformanceMonitoringService mockPerformanceService;

  setUp(() {
    mockPerformanceService = MockPerformanceMonitoringService();

    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
    sl.registerSingleton<PerformanceMonitoringService>(mockPerformanceService);

    bloc = ProfileBloc();
  });

  tearDown(() {
    bloc.close();
    final sl = GetIt.instance;
    if (sl.isRegistered<PerformanceMonitoringService>()) {
      sl.unregister<PerformanceMonitoringService>();
    }
  });

  group('ProfileBloc', () {
    test('initial state should have default name and email', () {
      expect(bloc.state.name, equals('Jessica Fernandes'));
      expect(bloc.state.email, equals('jessica@gmail.com'));
      expect(bloc.state.isProUser, isFalse);
    });

    group('UpdateProfileEvent', () {
      blocTest<ProfileBloc, ProfileState>(
        'should update name and email',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const UpdateProfileEvent(
            name: 'John Doe',
            email: 'john@test.com',
            isProUser: false,
          ),
        ),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.name, 'name', 'John Doe')
              .having((s) => s.email, 'email', 'john@test.com'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should update isProUser to true',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const UpdateProfileEvent(
            name: 'Jessica',
            email: 'jessica@gmail.com',
            isProUser: true,
          ),
        ),
        expect: () => [
          isA<ProfileState>().having((s) => s.isProUser, 'isProUser', true),
        ],
      );
    });

    group('UpdateSubscriptionStatusEvent', () {
      blocTest<ProfileBloc, ProfileState>(
        'should update isProUser to true',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const UpdateSubscriptionStatusEvent(isSubscribed: true)),
        expect: () => [
          isA<ProfileState>().having((s) => s.isProUser, 'isProUser', true),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should update isProUser to false',
        build: () => bloc,
        seed: () => ProfileState.initial(
          name: 'Test',
          email: 'test@test.com',
        ).copyWith(isProUser: true),
        act: (bloc) =>
            bloc.add(const UpdateSubscriptionStatusEvent(isSubscribed: false)),
        expect: () => [
          isA<ProfileState>().having((s) => s.isProUser, 'isProUser', false),
        ],
      );
    });
  });
}
