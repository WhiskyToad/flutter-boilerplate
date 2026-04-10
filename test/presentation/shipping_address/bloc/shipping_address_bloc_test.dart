import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/shipping_address/bloc/shipping_address_bloc.dart';
import 'package:skelter/presentation/shipping_address/bloc/shipping_address_events.dart';
import 'package:skelter/presentation/shipping_address/bloc/shipping_address_state.dart';

void main() {
  late ShippingAddressBloc bloc;

  setUp(() {
    bloc = ShippingAddressBloc();
  });

  tearDown(() {
    bloc.close();
  });

  group('ShippingAddressBloc', () {
    test('initial state should have selectedAddressIndex 0', () {
      expect(bloc.state.selectedAddressIndex, equals(0));
    });

    group('SelectedAddressIndexUpdateEvent', () {
      blocTest<ShippingAddressBloc, ShippingAddressState>(
        'should update selectedAddressIndex to 1',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const SelectedAddressIndexUpdateEvent(index: 1)),
        expect: () => [
          isA<ShippingAddressState>().having(
            (s) => s.selectedAddressIndex,
            'selectedAddressIndex',
            1,
          ),
        ],
      );

      blocTest<ShippingAddressBloc, ShippingAddressState>(
        'should update selectedAddressIndex to 2',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const SelectedAddressIndexUpdateEvent(index: 2)),
        expect: () => [
          isA<ShippingAddressState>().having(
            (s) => s.selectedAddressIndex,
            'selectedAddressIndex',
            2,
          ),
        ],
      );

      blocTest<ShippingAddressBloc, ShippingAddressState>(
        'should update selectedAddressIndex back to 0',
        build: () => ShippingAddressBloc(),
        seed: () =>
            ShippingAddressState.initial().copyWith(selectedAddressIndex: 2),
        act: (bloc) =>
            bloc.add(const SelectedAddressIndexUpdateEvent(index: 0)),
        expect: () => [
          isA<ShippingAddressState>().having(
            (s) => s.selectedAddressIndex,
            'selectedAddressIndex',
            0,
          ),
        ],
      );
    });

    group('ShippingAddressBlocExtension', () {
      blocTest<ShippingAddressBloc, ShippingAddressState>(
        'updateSelectedAddressIndex should add event',
        build: () => bloc,
        act: (bloc) => bloc.updateSelectedAddressIndex(3),
        expect: () => [
          isA<ShippingAddressState>().having(
            (s) => s.selectedAddressIndex,
            'selectedAddressIndex',
            3,
          ),
        ],
      );
    });
  });
}
