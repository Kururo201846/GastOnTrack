import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:camera/camera.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _selectedImage;
  String _extractedText = "";
  bool _isProcessing = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _cameraController == null) return;
    try {
      final XFile picture = await _cameraController!.takePicture();
      final File imageFile = File(picture.path);
      setState(() => _selectedImage = imageFile);
      _extractText(imageFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al tomar foto: ${e.toString()}")),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    if (albums.isEmpty) return;

    final List<AssetEntity> images = await albums.first.getAssetListRange(
      start: 0,
      end: 100,
    );
    if (images.isEmpty) return;

    final AssetEntity image = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: images.length,
            itemBuilder: (context, index) => FutureBuilder<File?>(
              future: images[index].file,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, images[index]),
                    child: Image.file(snapshot.data!, fit: BoxFit.cover),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );

    final File? file = await image.file;
    if (file != null) {
      setState(() => _selectedImage = file);
      _extractText(file);
    }
    }

  Future<void> _extractText(File image) async {
    setState(() => _isProcessing = true);
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      setState(() => _extractedText = recognizedText.text);
      textRecognizer.close();
    } catch (e) {
      setState(() => _extractedText = "Error: ${e.toString()}");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraReady && _selectedImage == null
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _pickImageFromGallery,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            )
          : _selectedImage != null
              ? Column(
                  children: [
                    Expanded(
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    ),
                    if (_isProcessing) const CircularProgressIndicator(),
                    if (_extractedText.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(_extractedText),
                          ),
                        ),
                      ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _isCameraReady && _selectedImage == null
            ? SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera, size: 50),
                ),
              )
            : null,
    );
  }
}