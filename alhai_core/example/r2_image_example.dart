/// Example usage of R2 Image Storage
/// 
/// This example demonstrates how to:
/// 1. Upload product images to Cloudflare R2
/// 2. Display images with ProductImage widget
/// 3. Use different image sizes appropriately

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R2 Image Example',
      theme: AlhaiTheme.light(),
      home: const ProductImageExample(),
    );
  }
}

class ProductImageExample extends StatefulWidget {
  const ProductImageExample({super.key});

  @override
  State<ProductImageExample> createState() => _ProductImageExampleState();
}

class _ProductImageExampleState extends State<ProductImageExample> {
  final _imageService = ImageService();
  bool _isUploading = false;
  ProductImageUrls? _uploadedUrls;

  // Example: Upload image
  Future<void> _uploadImage() async {
    setState(() => _isUploading = true);

    try {
      // Replace with actual file from image picker
      final imageFile = File('path/to/test/image.jpg');
      final productId = 'product-123';

      final urls = await _imageService.uploadProductImage(
        productId: productId,
        imageFile: imageFile,
      );

      setState(() {
        _uploadedUrls = urls;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Upload successful!')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('R2 Image Storage Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: Upload Button
            AlhaiButton(
              label: _isUploading ? 'Uploading...' : 'Upload Image',
              onPressed: _isUploading ? null : _uploadImage,
              variant: ButtonVariant.primary,
            ),

            if (_uploadedUrls != null) ...[
              const SizedBox(height: 32),
              const Text('✅ Uploaded URLs:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Thumbnail: ${_uploadedUrls!.thumbnail}',
                  style: const TextStyle(fontSize: 12)),
              Text('Medium: ${_uploadedUrls!.medium}',
                  style: const TextStyle(fontSize: 12)),
              Text('Large: ${_uploadedUrls!.large}',
                  style: const TextStyle(fontSize: 12)),
            ],

            const SizedBox(height: 32),
            const Text('Example Usage:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Example 2: Grid with thumbnail
            const Text('Grid View (Thumbnail 300×300):'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ProductImage(
                    thumbnail: _uploadedUrls?.thumbnail,
                    medium: _uploadedUrls?.medium,
                    large: _uploadedUrls?.large,
                    size: ImageSize.thumbnail, // Use thumbnail in grid
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Example 3: Detail View with Large
            const Text('Detail View (Large 1200×1200):'),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ProductImage(
                thumbnail: _uploadedUrls?.thumbnail,
                medium: _uploadedUrls?.medium,
                large: _uploadedUrls?.large,
                size: ImageSize.large, // Use large in detail
              ),
            ),

            const SizedBox(height: 24),

            // Example 4: List Item with Medium
            const Text('List Item (Medium 600×600):'),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: ProductImage(
                    thumbnail: _uploadedUrls?.thumbnail,
                    medium: _uploadedUrls?.medium,
                    large: _uploadedUrls?.large,
                    size: ImageSize.medium, // Use medium in list
                  ),
                ),
                title: const Text('Product Name'),
                subtitle: const Text('8.50 ر.س'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example: Using with Product model
class ProductCardExample extends StatelessWidget {
  final Product product;

  const ProductCardExample({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Automatically uses the right size
          ProductImage(
            thumbnail: product.imageThumbnail,
            medium: product.imageMedium,
            large: product.imageLarge,
            size: ImageSize.thumbnail,
            width: double.infinity,
            height: 120,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${product.price} ر.س'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
