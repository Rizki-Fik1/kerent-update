import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:kerent/app/data/models/product.dart';
import 'package:kerent/app/modules/CheckOut/views/check_out_view.dart';

import '../../../data/recommendation.dart';
import '../controllers/search_result_controller.dart';

class SearchResultView extends GetView<SearchResultController> {
  const SearchResultView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: Obx(() => controller.isSearching.value
                  ? _buildSearchResults()
                  : _buildRecommendations()),
            ),
          ],
        ),
      ),
    );  
  }

Widget _buildSearchHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(5, 12, 16, 12), 
    decoration: BoxDecoration(
      color: const Color(0xFF272829),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8), 
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF31363F),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: const Color(0xFF404040),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: controller.searchQuery.value),
                    onChanged: controller.updateSearchQuery,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: const Color(0xFF404040),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                // Filter Button dengan efek hover
                _buildIconButton(
                  icon: Icons.filter_list,
                  onTap: () => _showSortingOptions(),
                ),
                // Category Button dengan efek hover
                _buildIconButton(
                  icon: Icons.category,
                  onTap: () => _showCategoryOptions(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildIconButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: const Color(0xFFFF8225),
          size: 20,
        ),
      ),
    ),
  );
}

Widget _buildSearchResults() {
  return Obx(() {
    // If user is typing, show loading indicator
    if (controller.isTyping.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8225),
        ),
      );
    }

    // If actively loading results
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8225),
        ),
      );
    }

    // If no search query
    if (controller.searchQuery.value.isEmpty) {
      return const Center(
        child: Text(
          'Type something to search',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // If no results found after search
    if (!controller.isTyping.value && 
        !controller.isLoading.value && 
        controller.filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.filteredProducts.length,
          itemBuilder: (context, index) {
            final item = controller.filteredProducts[index];
            return _buildProductCard(context, item, constraints);
          },
        );
      },
    );
  });
}

Widget _buildProductCard(BuildContext context, Product product, BoxConstraints constraints) {
  // Hitung ukuran berdasarkan constraints
  final isSmallScreen = constraints.maxWidth < 400;
  final isMediumScreen = constraints.maxWidth < 600;
  
  // Responsive text sizes
  final titleFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
  final priceFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 15.0 : 17.0);
  final ratingFontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: const Color(0xFF31363F),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckOutView(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    product.images,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price.toString(),
                    style: TextStyle(
                      color: const Color(0xFFFF8225),
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFF8225),
                        size: isSmallScreen ? 14 : 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: ratingFontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


    Widget _buildRecommendations() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = controller.recommendations[index];
        return _buildRecommendationItem(recommendation);
      },
    );
  }

  Widget _buildRecommendationItem(SearchRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF31363F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            recommendation.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                recommendation.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (recommendation.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8225),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              recommendation.price,
              style: const TextStyle(
                color: Color(0xFFFF8225),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        onTap: () {
          controller.updateSearchQuery(recommendation.title);
        },
      ),
    );
  }

  void _showSortingOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF272829),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildSortOption('Price: Low to High', Icons.arrow_upward),
                _buildSortOption('Price: High to Low', Icons.arrow_downward),
                _buildSortOption('Rating', Icons.star),
                _buildSortOption('Newest', Icons.access_time),
              ],
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(
        icon, 
        color: controller.selectedSort.value == label 
            ? const Color(0xFFFF8225) 
            : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: controller.selectedSort.value == label 
              ? Colors.white 
              : Colors.grey,
          fontSize: 15,
        ),
      ),
      trailing: controller.selectedSort.value == label
          ? const Icon(
              Icons.check,
              color: Color(0xFFFF8225),
            )
          : null,
      onTap: () {
        controller.updateSort(label);
        Get.back();
      },
    );
  }

 void _showCategoryOptions() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF272829),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: controller.selectedCategory.value == category,
                onSelected: (selected) {
                  if (selected) {
                    controller.selectCategory(category);
                    Get.back();
                  }
                },
                backgroundColor: const Color(0xFF31363F),
                selectedColor: const Color(0xFFFF8225),
                labelStyle: TextStyle(
                  color: controller.selectedCategory.value == category
                      ? Colors.white
                      : Colors.grey[400],
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
}
