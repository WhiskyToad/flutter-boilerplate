import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/force_update/bloc/force_update_bloc.dart';
import 'package:skelter/presentation/force_update/bloc/force_update_event.dart';
import 'package:skelter/presentation/force_update/bloc/force_update_state.dart';

void main() {
  group('ForceUpdateBloc', () {
    group('initial state', () {
      test('should have isMandatoryUpdate true when passed true', () {
        final bloc = ForceUpdateBloc(isMandatoryUpdate: true);
        expect(bloc.state.isMandatoryUpdate, isTrue);
        bloc.close();
      });

      test('should have isMandatoryUpdate false when passed false', () {
        final bloc = ForceUpdateBloc(isMandatoryUpdate: false);
        expect(bloc.state.isMandatoryUpdate, isFalse);
        bloc.close();
      });
    });

    group('SkipUpdateEvent', () {
      blocTest<ForceUpdateBloc, ForceUpdateState>(
        'should emit SkipUpdateState',
        build: () => ForceUpdateBloc(isMandatoryUpdate: false),
        act: (bloc) => bloc.add(SkipUpdateEvent()),
        expect: () => [isA<SkipUpdateState>()],
      );

      blocTest<ForceUpdateBloc, ForceUpdateState>(
        'should preserve isMandatoryUpdate in SkipUpdateState',
        build: () => ForceUpdateBloc(isMandatoryUpdate: true),
        act: (bloc) => bloc.add(SkipUpdateEvent()),
        expect: () => [
          isA<SkipUpdateState>().having(
            (s) => s.isMandatoryUpdate,
            'isMandatoryUpdate',
            true,
          ),
        ],
      );
    });
  });
}
