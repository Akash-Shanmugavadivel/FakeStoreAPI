import 'package:flutter/material.dart';
import 'api_service.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> products;
  late Future<List<String>> categories;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    // Load all categories and products initially
    categories = apiService.fetchCategories();
    products = apiService.fetchProducts();
  }

  void loadProductsByCategory(String category) {
    setState(() {
      selectedCategory = category;
      products = category.isEmpty
          ? apiService.fetchProducts()
          : apiService.fetchProductsByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FakeStore Products'),
      ),
      body: Column(
        children: [
          // Dropdown for category selection
          FutureBuilder<List<String>>(
            future: categories,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  hint: Text("Select a category"),
                  items: snapshot.data!.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (category) {
                    if (category != null) {
                      loadProductsByCategory(category);
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products found'));
                }

                final screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount = screenWidth ~/ 180; // Set card width to 180 pixels
                crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount; // Minimum 2 columns

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6, // Adjusts the height of each card
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.network(
                                product['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  product['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Product Price
                                Text(
                                  'Price: \$${product['price']}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Product Rating
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.yellow, size: 18),
                                    Text(
                                      ' ${product['rating']['rate']} / 5.0',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
