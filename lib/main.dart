import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Processing Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImageProcessingDemo(),
    );
  }
}

class ImageProcessingDemo extends StatefulWidget {
  @override
  _ImageProcessingDemoState createState() => _ImageProcessingDemoState();
}

class _ImageProcessingDemoState extends State<ImageProcessingDemo> {
  late img.Image originalImage;
  late img.Image processedImage;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final imageData = await rootBundle.load('assets/sample_image.png');
    final List<int> bytes = Uint8List.view(imageData.buffer).toList();
    final img.Image loadedImage = img.decodeImage(Uint8List.fromList(bytes))!;
    
    setState(() {
      originalImage = loadedImage;
      processedImage = preprocessImage(loadedImage);
    });
  }

  //Can edit code here

  img.Image preprocessImage(img.Image image) {
    // Resize image to desired dimensions
    final resizedImage = img.copyResize(image, width: 300, height: 300);

    // Convert image to grayscale
    final grayscaleImage = img.grayscale(resizedImage);

    // Apply sharpening filter (e.g., simple Laplacian)
    final sharpenedImage = sharpenImage(grayscaleImage);

    return sharpenedImage;
  }

  img.Image sharpenImage(img.Image image) {
    // Create a sharpening kernel (e.g., simple Laplacian)
    final List<int> kernel = [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0,
    ];

    // Apply the kernel as a convolution filter
    final sharpened = img.convolution(image, kernel);

    return sharpened;
  }

  //end of editing code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (originalImage != null && processedImage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.memory(Uint8List.fromList(img.encodeJpg(originalImage)), width: 200),
                  Image.memory(Uint8List.fromList(img.encodeJpg(processedImage)), width: 200),
                ],
              ),
            SizedBox(height: 20),
            if (originalImage == null || processedImage == null)
              CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
