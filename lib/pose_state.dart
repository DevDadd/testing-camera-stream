import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

part 'pose_state.g.dart';

@CopyWith()
class PoseState extends Equatable {
  File? image;
  List<Pose>? poses;
  bool cameraReady;

  PoseState({this.image, this.poses, this.cameraReady = false});

  @override
  List<Object?> get props => [image, poses, cameraReady];
}
