import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/home/domain/entities/product.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

class MyOrderState extends Equatable {
  const MyOrderState({
    required this.products,
    this.selectedProductDetail,
    this.isProductDetailLoading = false,
    this.isGeneratingInvoice = false,
    this.invoiceGenerationError,
    this.generatedInvoicePdf,
    this.generatedInvoiceName,
  });

  final List<Product> products;
  final ProductDetail? selectedProductDetail;
  final bool isProductDetailLoading;
  final bool isGeneratingInvoice;
  final String? invoiceGenerationError;
  final Uint8List? generatedInvoicePdf;
  final String? generatedInvoiceName;

  const MyOrderState.initial()
      : products = const [],
        selectedProductDetail = null,
        isProductDetailLoading = false,
        isGeneratingInvoice = false,
        invoiceGenerationError = null,
        generatedInvoicePdf = null,
        generatedInvoiceName = null;

  MyOrderState.copy(MyOrderState state)
      : products = state.products,
        selectedProductDetail = state.selectedProductDetail,
        isProductDetailLoading = state.isProductDetailLoading,
        isGeneratingInvoice = state.isGeneratingInvoice,
        invoiceGenerationError = state.invoiceGenerationError,
        generatedInvoicePdf = state.generatedInvoicePdf,
        generatedInvoiceName = state.generatedInvoiceName;

  MyOrderState copyWith({
    List<Product>? products,
    String? selectedOrderId,
    ProductDetail? selectedProductDetail,
    bool? isProductDetailLoading,
    bool? isGeneratingInvoice,
    String? invoiceGenerationError,
    Uint8List? generatedInvoicePdf,
    String? generatedInvoiceName,
    bool haveToClearPreviousInvoice = false,
    bool haveToClearInvoiceGenerationError = false,
  }) {
    return MyOrderState(
      products: products ?? this.products,
      selectedProductDetail:
          selectedProductDetail ?? this.selectedProductDetail,
      isProductDetailLoading:
          isProductDetailLoading ?? this.isProductDetailLoading,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
      invoiceGenerationError: haveToClearInvoiceGenerationError
          ? null
          : invoiceGenerationError ?? this.invoiceGenerationError,
      generatedInvoicePdf: haveToClearPreviousInvoice
          ? null
          : generatedInvoicePdf ?? this.generatedInvoicePdf,
      generatedInvoiceName: haveToClearPreviousInvoice
          ? null
          : generatedInvoiceName ?? this.generatedInvoiceName,
    );
  }

  @override
  List<Object?> get props => [
        products,
        selectedProductDetail,
        isProductDetailLoading,
        isGeneratingInvoice,
        invoiceGenerationError,
        generatedInvoicePdf,
        generatedInvoiceName,
      ];
}

class MyOrderLoadingState extends MyOrderState {
  MyOrderLoadingState(super.state) : super.copy();
}

class MyOrderLoadedState extends MyOrderState {
  MyOrderLoadedState(MyOrderState state, {required List<Product> products})
      : super.copy(state.copyWith(products: products));
}

class MyOrderErrorState extends MyOrderState {
  final String errorMessage;

  MyOrderErrorState(super.state, {required this.errorMessage}) : super.copy();
}

class ProductDetailLoadingState extends MyOrderState {
  ProductDetailLoadingState(MyOrderState state)
      : super.copy(state.copyWith(isProductDetailLoading: true));
}

class ProductDetailLoadedState extends MyOrderState {
  ProductDetailLoadedState(
    MyOrderState state, {
    required ProductDetail productDetail,
  }) : super.copy(
          state.copyWith(
            selectedProductDetail: productDetail,
            isProductDetailLoading: false,
          ),
        );
}

class ProductDetailErrorState extends MyOrderState {
  final String errorMessage;

  ProductDetailErrorState(MyOrderState state, {required this.errorMessage})
      : super.copy(state.copyWith(isProductDetailLoading: false));
}
