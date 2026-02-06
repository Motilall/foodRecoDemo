import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// --- CONFIGURATION ---
// PASTE YOUR WORKING KEY HERE
const String apiKey = 'AIzaSyDclgmU4QgO1BvH3AIIQrEnMHfZItkiZmk'; 

void main() {
  runApp(const FoodScannerApp());
}

class FoodScannerApp extends StatelessWidget {
  const FoodScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Scanner',
      theme: ThemeData(
        // We use a nice Orange/Green "Food" theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange, 
          brightness: Brightness.light
        ),
        useMaterial3: true,
      ),
      home: const FoodScannerHome(),
    );
  }
}

class FoodScannerHome extends StatefulWidget {
  const FoodScannerHome({super.key});

  @override
  State<FoodScannerHome> createState() => _FoodScannerHomeState();
}

class _FoodScannerHomeState extends State<FoodScannerHome> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  String? _result;
  
  // Animation Controller for the Fade Effect
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? returnedImage = await _picker.pickImage(source: source);

    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
        _result = null; 
        _controller.reset(); // Reset animation when new image is picked
      });
    }
  }

  Future<void> _analyzeFood() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );

      final imageBytes = await _selectedImage!.readAsBytes();
      
      // We instruct the AI to format specifically for our UI
      const prompt = """
      Identify this food. Output the response in this EXACT Markdown format with emojis:

      # 🍽️ [Food Name]
      
      ## 📊 Nutrition & Taste
      **Calories:** [Approx calories]  
      **Spice Level:** [🌶️ Low/Medium/High]  
      **Category:** [Breakfast/Lunch/Snack]

      ## 🛒 Ingredients
      - [Ingredient 1]
      - [Ingredient 2]
      - ...

      ## 👩‍🍳 Recipe Instructions
      1. [Step 1]
      2. [Step 2]
      ...
      
      Make it sound delicious and fun!
      """;

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);

      setState(() {
        _result = response.text;
        _isLoading = false;
        _controller.forward(); // Start the Fade In Animation
      });
      
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // Light food background color
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 10),
            Text('FoodSnap AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE CONTAINER
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, height: 300, fit: BoxFit.cover)
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Tap the + button to scan food!", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 25),

            // BUTTON WITH ANIMATION
            if (_selectedImage != null && !_isLoading)
              ElevatedButton.icon(
                onPressed: _analyzeFood,
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text('Reveal Recipe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
              ),

            if (_isLoading)
               const Column(
                 children: [
                   SizedBox(height: 20),
                   CircularProgressIndicator(color: Colors.deepOrange),
                   SizedBox(height: 10),
                   Text("Chef AI is thinking...", style: TextStyle(color: Colors.deepOrange)),
                 ],
               ),

            const SizedBox(height: 30),

            // RESULT CARD WITH ANIMATION
            if (_result != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: MarkdownBody(
                    data: _result!,
                    selectable: true,
                    // CUSTOM STYLING FOR THE MARKDOWN
                    styleSheet: MarkdownStyleSheet(
                      // Main Title (Food Name)
                      h1: const TextStyle(fontSize: 28, color: Colors.deepOrange, fontWeight: FontWeight.bold, letterSpacing: -1),
                      // Section Headers (Ingredients, etc.)
                      h2: TextStyle(
                          fontSize: 20, 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.orange[400], // Makes it look like a section bar
                      ),
                      h2Padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      // Regular Text
                      p: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
                      // Bullet Points
                      listBullet: const TextStyle(color: Colors.orange, fontSize: 18),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPickerOptions,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
