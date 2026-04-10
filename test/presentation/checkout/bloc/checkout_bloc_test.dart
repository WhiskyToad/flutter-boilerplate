import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_bloc.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_events.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_state.dart';
import 'package:skelter/presentation/checkout/data/cart_sample_data.dart';

void main() {
  late CheckoutBloc checkoutBloc;

  setUp(() {
    checkoutBloc = CheckoutBloc();
  });

  tearDown(() {
    checkoutBloc.close();
  });

  group('CheckoutBloc', () {
    test('initial state should be CheckoutState.initial()', () {
      expect(checkoutBloc.state.stepperIndex, equals(0));
      expect(checkoutBloc.state.totalPrice, equals(0.0));
      expect(checkoutBloc.state.discount, equals(0.0));
      expect(checkoutBloc.state.deliveryCharges, equals(0.0));
      expect(checkoutBloc.state.finalAmount, equals(0.0));
      expect(checkoutBloc.state.isPaymentMethodOnline, isTrue);
      expect(checkoutBloc.state.couponCount, equals(1));
    });

    group('StepperIndexUpdateEvent', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'should emit StepperIndexUpdateState with new index',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(const StepperIndexUpdateEvent(index: 1)),
        expect: () => [
          isA<StepperIndexUpdateState>().having(
            (s) => s.stepperIndex,
            'stepperIndex',
            1,
          ),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'should update to index 2',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(const StepperIndexUpdateEvent(index: 2)),
        expect: () => [
          isA<StepperIndexUpdateState>().having(
            (s) => s.stepperIndex,
            'stepperIndex',
            2,
          ),
        ],
      );
    });

    group('InitialCalculationEvent', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'should calculate totals from cart data',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(const InitialCalculationEvent()),
        expect: () => [
          isA<CheckoutState>()
              .having((s) => s.totalPrice, 'totalPrice', greaterThan(0))
              .having((s) => s.discount, 'discount', 25.9)
              .having((s) => s.deliveryCharges, 'deliveryCharges', 10.0)
              .having((s) => s.finalAmount, 'finalAmount', greaterThan(0)),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'should compute finalAmount as (totalPrice - discount) + '
        'deliveryCharges',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(const InitialCalculationEvent()),
        verify: (bloc) {
          final state = bloc.state;
          final expectedFinal = double.parse(
            ((state.totalPrice - 25.9) + 10.0).toStringAsFixed(2),
          );
          expect(state.finalAmount, equals(expectedFinal));
        },
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'totalPrice should match sum of cart items',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(const InitialCalculationEvent()),
        verify: (bloc) {
          final expectedTotal = cartSampleData.fold(
            0.0,
            (total, item) => total + (item.product.price * item.quantities),
          );
          expect(bloc.state.totalPrice, equals(expectedTotal));
        },
      );
    });

    group('SelectPaymentMethodEvent', () {
      blocTest<CheckoutBloc, CheckoutState>(
        'should set isPaymentMethodOnline to false (COD)',
        build: () => checkoutBloc,
        act: (bloc) => bloc.add(
          const SelectPaymentMethodEvent(isPaymentMethodOnline: false),
        ),
        expect: () => [
          isA<CheckoutState>().having(
            (s) => s.isPaymentMethodOnline,
            'isPaymentMethodOnline',
            false,
          ),
        ],
      );

      blocTest<CheckoutBloc, CheckoutState>(
        'should set isPaymentMethodOnline to true (Online)',
        build: () => checkoutBloc,
        seed: () =>
            CheckoutState.initial().copyWith(isPaymentMethodOnline: false),
        act: (bloc) => bloc.add(
          const SelectPaymentMethodEvent(isPaymentMethodOnline: true),
        ),
        expect: () => [
          isA<CheckoutState>().having(
            (s) => s.isPaymentMethodOnline,
            'isPaymentMethodOnline',
            true,
          ),
        ],
      );
    });
  });
}
