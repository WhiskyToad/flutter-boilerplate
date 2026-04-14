import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/notifications/bloc/notification_bloc.dart';
import 'package:skelter/presentation/notifications/bloc/notification_event.dart';
import 'package:skelter/presentation/notifications/bloc/notification_state.dart';
import 'package:skelter/presentation/notifications/model/notification_model.dart';

void main() {
  late NotificationBloc bloc;

  setUp(() {
    bloc = NotificationBloc();
  });

  tearDown(() {
    bloc.close();
  });

  final tNotifications = [
    NotificationModel(
      id: '1',
      insertedOn: DateTime(2024, 1, 15),
      title: 'Test Notification 1',
      message: 'Message 1',
      isSeen: false,
    ),
    NotificationModel(
      id: '2',
      insertedOn: DateTime(2024, 1, 16),
      title: 'Test Notification 2',
      message: 'Message 2',
      isSeen: true,
    ),
    NotificationModel(
      id: '3',
      insertedOn: DateTime(2024, 1, 17),
      title: 'Test Notification 3',
      message: 'Message 3',
      isSeen: false,
    ),
  ];

  group('NotificationBloc', () {
    test('initial state should be NotificationInitializeState', () {
      expect(bloc.state, isA<NotificationInitializeState>());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.notificationList, isEmpty);
    });

    group('InitializeNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit NotificationInitializeState',
        build: () => bloc,
        act: (bloc) => bloc.add(InitializeNotificationEvent()),
        expect: () => [isA<NotificationInitializeState>()],
      );
    });

    group('NotificationLoadingEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should set isLoading to true',
        build: () => bloc,
        act: (bloc) => bloc.add(NotificationLoadingEvent(isLoading: true)),
        expect: () => [
          isA<NotificationState>().having(
            (s) => s.isLoading,
            'isLoading',
            true,
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'should set isLoading to false',
        build: () => bloc,
        act: (bloc) => bloc.add(NotificationLoadingEvent(isLoading: false)),
        expect: () => [
          isA<NotificationState>().having(
            (s) => s.isLoading,
            'isLoading',
            false,
          ),
        ],
      );
    });

    group('DeleteNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should remove notification by id',
        build: () => bloc,
        seed: () => NotificationState(
          isLoading: false,
          notificationList: tNotifications,
        ),
        act: (bloc) => bloc.add(DeleteNotificationEvent(notificationId: '2')),
        expect: () => [
          isA<NotificationDeletedState>().having(
            (s) => s.notificationList.length,
            'list length',
            2,
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'should not remove anything if id not found',
        build: () => bloc,
        seed: () => NotificationState(
          isLoading: false,
          notificationList: tNotifications,
        ),
        act: (bloc) => bloc.add(DeleteNotificationEvent(notificationId: '999')),
        expect: () => [
          isA<NotificationDeletedState>().having(
            (s) => s.notificationList.length,
            'list length',
            3,
          ),
        ],
      );
    });

    group('NotificationErrorEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit NotificationErrorState with message',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(NotificationErrorEvent(msg: 'Something failed')),
        expect: () => [
          isA<NotificationErrorState>().having(
            (s) => s.message,
            'message',
            'Something failed',
          ),
        ],
      );
    });

    group('GetNotificationDataEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'should emit loading state first',
        build: () => bloc,
        act: (bloc) => bloc.add(GetNotificationDataEvent()),
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          expect(bloc.state.notificationList, isNotEmpty);
        },
      );
    });
  });
}
