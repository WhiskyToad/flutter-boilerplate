import 'package:equatable/equatable.dart';

abstract class MyOrderEvent extends Equatable {
  const MyOrderEvent();
}

class GetMyOrderProductsEvent extends MyOrderEvent {
  const GetMyOrderProductsEvent();

  @override
  List<Object> get props => [];
}

class GetOrderProductDetailEvent extends MyOrderEvent {
  final String productId;

  const GetOrderProductDetailEvent({required this.productId});

  @override
  List<Object> get props => [productId];
}

class GenerateInvoiceEvent extends MyOrderEvent {
  const GenerateInvoiceEvent();

  @override
  List<Object?> get props => [];
}

class ClearInvoiceGenerationErrorEvent extends MyOrderEvent {
  const ClearInvoiceGenerationErrorEvent();

  @override
  List<Object?> get props => [];
}
