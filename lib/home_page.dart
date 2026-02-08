import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streampose/pose_cubit.dart';
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
            return CameraPreview(controller);
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
