import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
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
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _cameraController!
        .initialize()
        .then((_) {
          if (isClosed) return;
          emit(state.copyWith(cameraReady: true));
          _startCameraStream();
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // TODO: handle camera permission denied.
                break;
              default:
                // TODO: handle other camera errors.
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
        developer.log(
          'type: $type, x: $x, y: $y, z: $z',
          name: 'streampose.pose_detection.image',
        );
      });
    }
  }

  void _startCameraStream() {
    final controller = _cameraController;
    if (controller == null) return;

    controller.startImageStream((CameraImage image) async {
      if (isProcessing) return;
      isProcessing = true;
      try {
        final inputImage = _convertCameraImage(image, controller.description);
        final poses = await poseDetector.processImage(inputImage);

        // Cập nhật state để sau này có thể vẽ skeleton nếu cần.
        emit(state.copyWith(poses: poses));

        for (final pose in poses) {
          pose.landmarks.forEach((_, landmark) {
            final type = landmark.type;
            final x = landmark.x;
            final y = landmark.y;
            final z = landmark.z;

            developer.log(
              'stream landmark - type: $type, x: $x, y: $y, z: $z',
              name: 'streampose.pose_detection.stream',
            );
          });
        }
      } catch (e, s) {
        developer.log(
          'Pose stream error: $e',
          name: 'streampose.pose_detection.stream',
          error: e,
          stackTrace: s,
        );
      } finally {
        isProcessing = false;
      }
    });
  }

  InputImage _convertCameraImage(CameraImage image, CameraDescription camera) {
    final int width = image.width;
    final int height = image.height;

    // CameraX Android trả về YUV_420_888, chuyển sang NV21 cho ML Kit.
    final Uint8List nv21 = _yuv420ToNv21(image, width, height);

    final Size imageSize = Size(width.toDouble(), height.toDouble());

    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: InputImageFormat.nv21,
      bytesPerRow: width,
    );

    return InputImage.fromBytes(bytes: nv21, metadata: metadata);
  }

  static Uint8List _yuv420ToNv21(CameraImage image, int width, int height) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y (tôn trọng bytesPerRow).
    for (int row = 0; row < height; row++) {
      final int yRow = row * yPlane.bytesPerRow;
      final int outRow = row * width;
      for (int col = 0; col < width; col++) {
        nv21[outRow + col] = yPlane.bytes[yRow + col];
      }
    }

    // Interleave VU: NV21 = Y + VU VU...
    final int halfHeight = height ~/ 2;
    final int halfWidth = width ~/ 2;
    int uvIndex = ySize;
    for (int row = 0; row < halfHeight; row++) {
      final int vRow = row * vPlane.bytesPerRow;
      final int uRow = row * uPlane.bytesPerRow;
      for (int col = 0; col < halfWidth; col++) {
        final int vIndex = vRow + col;
        final int uIndex = uRow + col;
        nv21[uvIndex++] = vPlane.bytes[vIndex];
        nv21[uvIndex++] = uPlane.bytes[uIndex];
      }
    }

    return nv21;
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
