import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_event.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_state.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/generate_ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/get_product_detail.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({
    required GetProductDetail getProductDetail,
    required GenerateAIProductDescription generateAIProductDescription,
  })  : _getProductDetail = getProductDetail,
        _generateAIProductDescription = generateAIProductDescription,
        super(const ProductDetailState.initial()) {
    _setupEventListeners();
  }

  final GetProductDetail _getProductDetail;
  final GenerateAIProductDescription _generateAIProductDescription;

  void _setupEventListeners() {
    on<GetProductDetailDataEvent>(_onGetProductDetailDataEvent);
    on<ProductImageSelectedEvent>(_onProductImageSelectedEvent);
    on<GenerateAIDescriptionEvent>(_onGenerateAIDescriptionEvent);
  }

  void _onGetProductDetailDataEvent(
    GetProductDetailDataEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading(state));

    final result = await _getProductDetail(
      GetProductDetailParams(id: event.productId),
    );

    result.fold(
      (failure) => emit(
        ProductDetailErrorState(state, errorMessage: failure.errorMessage),
      ),
      (productDetail) => emit(
        ProductDetailLoadedState(
          state,
          productDetail: productDetail,
        ),
      ),
    );
  }

  void _onProductImageSelectedEvent(
    ProductImageSelectedEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(
      state.copyWith(selectedImageIndex: event.selectedIndex),
    );
  }

  void _onGenerateAIDescriptionEvent(
    GenerateAIDescriptionEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    debugPrint('[AI Description] Starting generation...');
    emit(AIDescriptionGenerating(state));

    try {
      final result = await _generateAIProductDescription(
        GenerateAIProductDescriptionParams(
          productDetail: event.productDetail,
          userOrderHistory: event.userOrderHistory,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('[AI Description] Error: ${failure.errorMessage}');
          emit(
            AIDescriptionError(state, errorMessage: failure.errorMessage),
          );
        },
        (aiDescription) {
          debugPrint('[AI Description] Success: Generated description');
          emit(
            AIDescriptionGenerated(
              state,
              aiDescription: aiDescription,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('[AI Description] Exception: $e');
      emit(
        AIDescriptionError(
          state,
          errorMessage: 'Failed to generate AI description: $e',
        ),
      );
    }
  }
}
