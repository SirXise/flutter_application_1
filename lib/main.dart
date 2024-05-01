import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:image_processing_contouring/Classes/Contour.dart';

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
    print('Before Image width: ${image.width},Before height: ${image.height}');

    int Dwidth = (image.width * 1.5).toInt();
    int Dheight = (image.height * 1.5).toInt();

    var resizedImage = img.copyResize(image, width: Dwidth, height: Dheight);

    print(
        'After Image width: ${resizedImage.width},After height: ${resizedImage.height}');

    //Greyscale
    var greyscaleImage = img.grayscale(resizedImage);

    print('After Greyscale Image width: ${greyscaleImage.width},After height: ${greyscaleImage.height}');

    // Gassian Blur
    // var gassianBlur = img.gaussianBlur(resizedImage, radius: 5);

    // print(
    //     'After Gassian Blur Image width: ${gassianBlur.width},After height: ${gassianBlur.height}');

    //sobel edge detecting
    // var edgeDetected = img.sobel(gassianBlur);

    // print(
    //     'After Sobel Image width: ${edgeDetected.width},After height: ${edgeDetected.height}');

    // Uint8List resultImage = img.encodeJpg(edgeDetected);

    // img.Image? decodedImage = img.decodeImage(Uint8List.fromList(resultImage))!;

    // print('After decodeJpg Image width: ${decodedImage.width},After height: ${decodedImage.height}');

    //Add Contrast
    var enhancedImage = img.contrast(greyscaleImage, contrast: 2.0);

    print('After Contrast Image width: ${enhancedImage.width},After height: ${enhancedImage.height}');

    //Sharpen
    //var sharpened = sharpenImage(edgeDetected);

    //print(
    //    'After Sharpening with Kernel Image width: ${sharpened.width},After height: ${sharpened.height}');

    // Apply contour detection
    //List<Contour> contours = edgeDetected.detectContours();

    // Draw contours on the image
    //var imageWithContours = drawContours(resizedImage, contours);

    return enhancedImage;
  }

  img.Image sharpenImage(img.Image image) {
    final List<num> kernel = [
      0,
      -1,
      0,
      -1,
      5,
      -1,
      0,
      -1,
      0,
    ];

    // Apply the kernel as a convolution filter
    final sharpened = img.convolution(image, filter: kernel);

    return sharpened;
  }

  img.Image drawContours(img.Image image, List<Contour> contours) {
    // Draw contours on a copy of the image
    img.Image imageCopy =
        img.copyResize(image, width: image.width, height: image.height);

    // Draw contours on the image copy
    for (var contour in contours) {
      for (var point in contour.Points) {
        imageCopy.setPixel(point.x.toInt(), point.y.toInt(),
            img.ColorInt16.rgb(255, 0, 0)); // Draw contour in red
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
                  // Display original image with its intrinsic width
                  Image.memory(
                    Uint8List.fromList(img.encodeJpg(originalImage)),
                    width:
                        originalImage.width.toDouble(), // Use intrinsic width
                    height:
                        originalImage.height.toDouble(), // Use intrinsic height
                  ),
                  // Display processed image with its intrinsic width
                  Image.memory(
                    Uint8List.fromList(img.encodeJpg(processedImage)),
                    width:
                        processedImage.width.toDouble(), // Use intrinsic width
                    height: processedImage.height
                        .toDouble(), // Use intrinsic height
                  ),
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
