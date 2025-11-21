import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';
import 'package:attendance/ui/attend/attend_screen.dart';
import 'package:attendance/utils/face_detection/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _State();
}

class _State extends State<CameraScreen> with TickerProviderStateMixin {
  // === TEMA ORANGE PROFESIONAL ===
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF8C42);

  // Face Detector
  final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
    ),
  );

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  Future<void> loadCamera() async {
    cameras = await availableCameras();
    if (cameras == null || cameras!.isEmpty) {
      _showError("Camera not found!");
      return;
    }

    final frontCamera = cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras!.first,
    );

    controller = CameraController(frontCamera, ResolutionPreset.veryHigh);

    try {
      await controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      _showError("Camera initialization failed!");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showLoader() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
          strokeWidth: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Capture a selfie image",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview
          SizedBox(
            height: size.height,
            width: size.width,
            child: controller == null
                ? const Center(child: Text("Camera error!", style: TextStyle(color: Colors.white)))
                : !controller!.value.isInitialized
                    ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                    : CameraPreview(controller!),
          ),

          // Face Ring Animation
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Lottie.asset(
              "assets/raw/face_id_ring.json",
              fit: BoxFit.cover,
            ),
          ),

          // Bottom Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Make sure you're in a well-lit area so your face is clearly visible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),

                  // Shutter Button
                  ClipOval(
                    child: Material(
                      color: primaryOrange,
                      child: InkWell(
                        splashColor: accentOrange,
                        onTap: () async {
                          final hasPermission = await handleLocationPermission();
                          if (!hasPermission) return;

                          try {
                            if (controller != null && controller!.value.isInitialized) {
                              controller!.setFlashMode(FlashMode.off);
                              image = await controller!.takePicture();

                              _showLoader();

                              final inputImage = InputImage.fromFilePath(image!.path);

                              if (Platform.isAndroid) {
                                await processImage(inputImage);
                              } else {
                                if (mounted) {
                                  Navigator.pop(context); // close loader
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendScreen(image: image),
                                    ),
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            _showError("Failed to capture photo: $e");
                          }
                        },
                        child: const SizedBox(
                          width: 70,
                          height: 70,
                          child: Icon(Icons.camera_alt_rounded, size: 36, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === FUNGSI TETAP SAMA (TIDAK DIUBAH LOGIKANYA) ===
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location service disabled."), backgroundColor: Colors.redAccent),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied."), backgroundColor: Colors.redAccent),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied."), backgroundColor: Colors.redAccent),
      );
      return false;
    }
    return true;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;

    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (!mounted) return;

    Navigator.of(context).pop(); // close loader

    if (faces.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AttendScreen(image: image)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No face detected. Please try again with better lighting."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    faceDetector.close();
    super.dispose();
  }
}