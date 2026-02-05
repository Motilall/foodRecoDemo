import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const FoodWiseApp());
}

class FoodWiseApp extends StatelessWidget {
  const FoodWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodWise',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLoading = false;
  String _result = "";

  final ImagePicker _picker = ImagePicker();

  // 📸 Camera
  Future<void> _captureImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = "";
      });
    }
  }

  // 🖼️ Gallery
  Future<void> _pickFromGallery() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = "";
      });
    }
  }

  // 🔍 Analyze (temporary fake result – backend later)
  Future<void> _analyzeFood() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _result = "";
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _result = """
🍕 Detected Food: Pizza
🔥 Calories: 285
🥗 Type: Fast Food
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FoodWise")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_image != null)
              Center(
                child: Image.file(
                  _image!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // 📸 Camera Button
            Center(
              child: ElevatedButton(
                onPressed: _captureImage,
                child: const Text("Capture Food Image"),
              ),
            ),

            const SizedBox(height: 10),

            // 🖼️ Gallery Button (NEW)
            Center(
              child: ElevatedButton(
                onPressed: _pickFromGallery,
                child: const Text("Upload From Gallery"),
              ),
            ),

            const SizedBox(height: 10),

            // 🔍 Analyze Button
            Center(
              child: ElevatedButton(
                onPressed: _analyzeFood,
                child: const Text("Analyze Food"),
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator()),

            if (_result.isNotEmpty)
              Text(
                _result,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
