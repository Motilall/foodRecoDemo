import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/food_ai_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? _result;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();
  final FoodAIService _aiService = FoodAIService();

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _result = null;
    });
  }

  Future<void> _analyzeFood() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    final label = await _aiService.detectFood(_image!);

    setState(() {
      _loading = false;
      _result = label ?? "No food detected";
    });
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FoodWise")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 220, fit: BoxFit.cover),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _pickFromGallery,
              child: const Text("Upload From Gallery"),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _analyzeFood,
              child: const Text("Analyze Food"),
            ),

            const SizedBox(height: 16),

            if (_loading) const CircularProgressIndicator(),

            if (_result != null && !_loading)
              Text(
                "🍽 Detected: $_result",
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
