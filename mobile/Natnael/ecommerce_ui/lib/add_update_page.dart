import 'package:flutter/material.dart';

class AddUpdatePage extends StatefulWidget {
  const AddUpdatePage({super.key});

  @override
  State<AddUpdatePage> createState() => _AddUpdatePageState();
}

class _AddUpdatePageState extends State<AddUpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Add Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 40),
        child: Form(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(51),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 40),
                        SizedBox(height: 8),
                        Text('upload image', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('name'),
                _buildTextField(_nameController),
                const SizedBox(height: 10),
                _buildLabel('category'),
                _buildTextField(_categoryController),
                const SizedBox(height: 10),
                _buildLabel('price'),
                _buildTextField(_priceController, suffix: const Text('\$')),
                const SizedBox(height: 10),
                _buildLabel('description'),
                _buildTextField(_descriptionController, maxLines: 4),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Validate and pass product data back
                    final name = _nameController.text.trim();
                    final category = _categoryController.text.trim();
                    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
                    final description = _descriptionController.text.trim();
                    if (name.isEmpty || category.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    final product = {
                      'name': name,
                      'category': category,
                      'price': price,
                      'description': description,
                      // Add image and other fields as needed
                    };
                    Navigator.pop(context, product);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('ADD'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    _nameController.clear();
                    _categoryController.clear();
                    _priceController.clear();
                    _descriptionController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fields cleared')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Align(alignment: Alignment.centerLeft, child: Text(text.toLowerCase()));

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffix: suffix,
      ),
    );
  }
}
