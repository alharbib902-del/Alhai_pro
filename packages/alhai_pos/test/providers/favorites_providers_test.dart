/// Unit tests for favorites_providers
///
/// Tests: FavoriteProductData model, favoritesListProvider
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/providers/favorites_providers.dart';

void main() {
  group('FavoriteProductData', () {
    late FavoriteProductData favoriteData;
    late FavoritesTableData fakeFavorite;
    late ProductsTableData fakeProduct;

    setUp(() {
      fakeFavorite = FavoritesTableData(
        id: 'fav-1',
        storeId: 'store-1',
        productId: 'prod-1',
        sortOrder: 3,
        createdAt: DateTime(2026, 1, 1),
      );

      // C-4 Stage B: SAR × 100 = cents
      fakeProduct = ProductsTableData(
        id: 'prod-1',
        storeId: 'store-1',
        name: 'Favorite Coffee',
        price: 1500,
        costPrice: 800,
        stockQty: 50,
        isActive: true,
        trackInventory: true,
        barcode: '1234567890',
        minQty: 1,
        onlineAvailable: false,
        onlineReservedQty: 0,
        autoReorder: false,
        createdAt: DateTime(2026, 1, 1),
      );

      favoriteData = FavoriteProductData(
        favorite: fakeFavorite,
        product: fakeProduct,
      );
    });

    test('id returns favorite id', () {
      expect(favoriteData.id, equals('fav-1'));
    });

    test('productId returns product id from favorite', () {
      expect(favoriteData.productId, equals('prod-1'));
    });

    test('name returns product name', () {
      expect(favoriteData.name, equals('Favorite Coffee'));
    });

    test('price returns product price', () {
      expect(favoriteData.price, equals(1500));
    });

    test('barcode returns product barcode', () {
      expect(favoriteData.barcode, equals('1234567890'));
    });

    test('barcode returns empty string when product barcode is null', () {
      final productWithoutBarcode = ProductsTableData(
        id: 'prod-2',
        storeId: 'store-1',
        name: 'No Barcode Product',
        price: 1000,
        costPrice: 500,
        stockQty: 20,
        isActive: true,
        trackInventory: true,
        minQty: 1,
        onlineAvailable: false,
        onlineReservedQty: 0,
        autoReorder: false,
        createdAt: DateTime(2026, 1, 1),
      );

      final noBarcodeFav = FavoriteProductData(
        favorite: fakeFavorite,
        product: productWithoutBarcode,
      );

      expect(noBarcodeFav.barcode, equals(''));
    });

    test('stock returns product stock quantity', () {
      expect(favoriteData.stock, equals(50.0));
    });

    test('imageUrl returns product imageThumbnail', () {
      // Default product has no imageThumbnail
      expect(favoriteData.imageUrl, isNull);
    });

    test('sortOrder returns favorite sort order', () {
      expect(favoriteData.sortOrder, equals(3));
    });

    test('exposes underlying favorite and product data', () {
      expect(favoriteData.favorite, equals(fakeFavorite));
      expect(favoriteData.product, equals(fakeProduct));
    });
  });
}
