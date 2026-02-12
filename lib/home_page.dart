import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streampose/pose_cubit.dart';
import 'package:streampose/pose_painter.dart';
import 'package:streampose/pose_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PoseCubit, PoseState>(
        builder: (context, state) {
          final cubit = context.read<PoseCubit>();
          final controller = cubit.cameraController;

          if (controller != null && controller.value.isInitialized) {
            final previewSize = controller.value.previewSize;
            final imageSize = previewSize ?? const Size(0, 0);

            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller),
                if (state.poses != null && imageSize.width > 0)
                  CustomPaint(
                    painter: PosePainter(
                      poses: state.poses!,
                      imageSize: imageSize,
                      // Dịch skeleton lên trên một chút (âm là đi lên).
                      offset: const Offset(0, -20),
                    ),
                  ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.image != null)
                  Image.file(
                    state.image!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                else
                  const Text("Chưa có ảnh"),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    cubit.initCamera();
                  },
                  child: const Text("Mở camera"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
