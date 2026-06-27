import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../data/services/api/api_client.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/product_model.dart';
import '../order/order_controller.dart';

class ProductController extends TBaseController<ProductModel> {
  static ProductController get instance => Get.find();

  final _productRepository = Get.put(ProductRepository());

  /// Average rating per productId (0–5).
  final RxMap<String, double> productRatings = <String, double>{}.obs;

  /// Number of reviews per productId.
  final RxMap<String, int> productRatingCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadRatings();
  }

  @override
  Future<List<ProductModel>> fetchItems() async {
    return await _productRepository.getAllProducts();
  }

  /// Fetch all reviews from the public `/reviews` endpoint, group them by
  /// productId, and compute the average rating and review count per product.
  Future<void> loadRatings() async {
    try {
      final reviews = await ApiClient.instance.getList('/reviews');

      final sums = <String, double>{};
      final counts = <String, int>{};

      for (final review in reviews) {
        final productId = review['productId']?.toString();
        if (productId == null || productId.isEmpty) continue;

        final rawRating = review['rating'];
        final rating = rawRating is num
            ? rawRating.toDouble()
            : double.tryParse(rawRating?.toString() ?? '') ?? 0.0;

        sums[productId] = (sums[productId] ?? 0.0) + rating;
        counts[productId] = (counts[productId] ?? 0) + 1;
      }

      final averages = <String, double>{};
      sums.forEach((productId, sum) {
        final count = counts[productId] ?? 0;
        averages[productId] = count > 0 ? sum / count : 0.0;
      });

      productRatings.assignAll(averages);
      productRatingCounts.assignAll(counts);
    } catch (e) {
      print("Error loading ratings :- $e");
    }
  }

  @override
  bool containsSearchQuery(ProductModel item, String query) {
    return item.title.toLowerCase().contains(query.toLowerCase()) ||
        item.brand!.name.toLowerCase().contains(query.toLowerCase()) ||
        item.stock.toString().contains(query) ||
        item.price.toString().contains(query);
  }

  @override
  Future<void> deleteItem(ProductModel item) async {
    // You might want to add a check if any orders of this products exists, delete them first
    final orderController = Get.put(OrderController());

    // If no orders fetched, Fetch them first
    if (orderController.allItems.isEmpty) {
      await orderController.fetchItems();
    }

    // Check if any order exist containing this productId
    final orderExists = orderController.allItems.any((element) =>
        element.items.any((element) => element.productId == item.id));

    if (orderExists) {
      TLoaders.warningSnackBar(
          title: 'Dependents Exist',
          message:
              'In order to Delete this Product, Delete dependent Orders first.');
      return;
    }
    await _productRepository.deleteProduct(item);
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (ProductModel product) => product.title.toLowerCase());
  }

  /// Sorting related code
  void sortByPrice(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (ProductModel product) => product.title.toLowerCase());
  }

  /// Sorting related code
  void sortByStock(int sortColumnIndex, bool ascending) {
    sortByProperty(
        sortColumnIndex, ascending, (ProductModel product) => product.stock);
  }

  /// Get the product price or price range for variations.
  String getProductPrice(ProductModel product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    // If no variations exist, return the simple price or sale price
    if (product.productType == ProductType.single.toString() ||
        product.productVariations!.isEmpty) {
      return (product.price - (product.price * (product.salePrice * 0.01)))
          .toStringAsFixed(2)
          .toString();
      // (product.salePrice > 0.0 ? product.price : product.price)
      // .toString();
    } else {
      // Calculate the smallest and largest prices among variations
      for (var variation in product.productVariations!) {
        // Determine the price to consider (sale price if available, otherwise regular price)
        double priceToConsider =
            variation.salePrice > 0.0 ? variation.salePrice : variation.price;

        // Update smallest and largest prices
        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      // If smallest and largest prices are the same, return a single price
      if (smallestPrice.isEqual(largestPrice)) {
        return largestPrice.toString();
      } else {
        // Otherwise, return a price range
        return '$smallestPrice - ₹$largestPrice';
      }
    }
  }

  /// -- Calculate Discount Percentage
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;

    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// -- Calculate Product Stock
  String getProductStockTotal(ProductModel product) {
    return product.productType == ProductType.single.toString()
        ? product.stock.toString()
        : product.productVariations!
            .fold<int>(
                0, (previousValue, element) => previousValue + element.stock)
            .toString();
  }

  String getProductDepartment(ProductModel product) {
    return product.productType == ProductType.single.toString()
        ? product.departmentname.toString()
        : product.productVariations!
            .fold<int>(
                0, (previousValue, element) => previousValue + element.stock)
            .toString();
  }

  /// -- Check Product Stock Status
  String getProductStockStatus(ProductModel product) {
    return product.stock > 0 ? 'In Stock' : 'Out of Stock';
  }
}
