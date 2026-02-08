import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streampose/pose_state.dart';

class PoseCubit extends Cubit<PoseState> {
  late ImagePicker imagePicker;
  late PoseDetector poseDetector;
  CameraController? _cameraController;
  bool isProcessing = false;

  PoseCubit() : super(PoseState()) {
    initialData();
  }

  CameraController? get cameraController => _cameraController;

  void initialData() {
    imagePicker = ImagePicker();
    final options = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.single,
    );
    poseDetector = PoseDetector(options: options);
  }

  Future<void> initCamera() async {
    if (_cameraController != null) return;

    final cameras = await availableCameras();
    final cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      cam,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _cameraController!.initialize().then((_) {
      if (isClosed) return;
      emit(state.copyWith(cameraReady: true));
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }
  pickImageFromLibrary() async {
    XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      state.image = File(pickedFile.path);
    }
  }

  startPoseDetection() async {
    InputImage inputImage = InputImage.fromFile(state.image!);
    state.poses = await poseDetector.processImage(inputImage);
    for (Pose poses in state.poses!) {
      poses.landmarks.forEach((_, landmark) {
        final type = landmark.type;
        final x = landmark.x;
        final y = landmark.y;
        final z = landmark.z;
        print('type: $type, x: $x, y: $y, z: $z');
      });
    }
  }

  @override
  Future<void> close() async {
    final controller = _cameraController;
    if (controller != null) {
      _cameraController = null;
      try {
        await controller.stopImageStream();
      } catch (_) {
        // Stream may not have been started.
      }
      try {
        await controller.dispose();
      } catch (_) {
        // Plugin may throw during dispose (e.g. CameraX observer bug).
      }
    }
    poseDetector.close();
    return super.close();
  }
}
