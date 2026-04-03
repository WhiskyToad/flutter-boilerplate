import 'package:skelter/presentation/home/domain/entities/product.dart';

const sampleProducts = <Product>[
  Product(
    id: '1001',
    image: 'https://example.com/product1.jpg',
    title: 'Wireless Noise-Cancelling Headphones',
    description: 'Premium over-ear headphones with active noise cancellation.',
    category: 'Electronics',
    rating: 4.5,
    reviews: 230,
    availableQuantities: 10,
    price: 99.99,
    seller: 'TechStore',
  ),
  Product(
    id: '1002',
    image: 'https://example.com/product2.jpg',
    title: 'Smart Fitness Watch',
    description: 'Feature-rich smartwatch with health and fitness monitoring.',
    category: 'Wearables',
    rating: 4.0,
    reviews: 85,
    availableQuantities: 5,
    price: 149.99,
    seller: 'GadgetHub',
  ),
];
