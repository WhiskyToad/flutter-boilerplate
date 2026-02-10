import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/checkout/model/product_cart.dart';
import 'package:skelter/presentation/home/data/models/product_model.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

class InvoiceModel {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String shippingAddress;
  final String paymentMethod;
  final List<CartModel> items;
  final double subtotal;
  final double discount;
  final double deliveryCharges;
  final double totalAmount;

  InvoiceModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.totalAmount,
  });

  factory InvoiceModel.fromProductDetail({
    required ProductDetail productDetail,
    required AppLocalizations localization,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final invoiceNumber = 'INV-${timestamp.toString().substring(
          timestamp.toString().length - 8,
        )}';

    const quantity = 1;
    const discountPercent = 0.10;
    const deliveryCharges = 10.0;
    const customerName = 'Roz Cooper';
    const shippingAddress = '2118 Thornridge Cir. Syracuse, Connecticut 35624';

    final itemPrice = productDetail.price * quantity;
    final discount = (itemPrice * discountPercent * 100).floor() / 100;
    final totalAmount =
        ((itemPrice - discount + deliveryCharges) * 100).floor() / 100;

    final cartItem = CartModel(
      product: ProductModel(
        id: productDetail.id,
        title: productDetail.title,
        price: productDetail.price,
        description: productDetail.description,
        category: productDetail.category,
        image: productDetail.image,
        rating: productDetail.rating,
        reviews: 0,
        availableQuantities: 1,
        seller: 'Seller',
      ),
      quantities: quantity,
      expectedDeliveryDate: '9:00 am, Sat, 15 Apr',
    );

    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      invoiceDate: DateTime.now(),
      customerName: customerName,
      shippingAddress: shippingAddress,
      paymentMethod: localization.online_payment_method,
      items: [cartItem],
      subtotal: itemPrice,
      discount: discount,
      deliveryCharges: deliveryCharges,
      totalAmount: totalAmount,
    );
  }
}
