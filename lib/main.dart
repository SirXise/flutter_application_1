import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_processing_contouring/Classes/Contour.dart';
import 'package:image_processing_contouring/Image/ImageContouring.dart';
import 'package:image_processing_contouring/Image/ImageDrawing.dart';
import 'package:image_processing_contouring/Image/ImageManipulation.dart';
import 'package:image_processing_contouring/Image/ImageOperation.dart';

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
    // Resize the image
    var resizedImage = img.copyResize(image, width: 300, height: 1000);

    // Gassian Blur
    var gassianBlur = img.gaussianBlur(resizedImage, radius: 0);
    
    //sobel edge detecting
    var edgeDetected = img.sobel(gassianBlur);

    // Apply contour detection
    List<Contour> contours = edgeDetected.detectContours();

    // Draw contours on the image
    var imageWithContours = drawContours(resizedImage, contours);

    return imageWithContours;
  }

  img.Image drawContours(img.Image image, List<Contour> contours) {
    // Draw contours on a copy of the image
    img.Image imageCopy = img.copyResize(image, width: image.width, height: image.height);

    // Draw contours on the image copy
    for (var contour in contours) {
      for (var point in contour.Points) {
        imageCopy.setPixel(point.x.toInt(), point.y.toInt(), img.ColorInt16.rgb(255, 0, 0)); // Draw contour in red
      }
    }

    return imageCopy;
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
                  Image.memory(Uint8List.fromList(img.encodeJpg(originalImage)),
                      width: 200),
                  Image.memory(
                      Uint8List.fromList(img.encodeJpg(processedImage)),
                      width: 200),
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
