import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  PosePainter({
    required this.poses,
    required this.imageSize,
    this.offset = Offset.zero,
    this.pointColor = Colors.greenAccent,
    this.lineColor = Colors.redAccent,
    this.pointRadius = 4.0,
    this.lineWidth = 2.0,
  });

  final List<Pose> poses;
  final Size imageSize;
  final Offset offset;
  final Color pointColor;
  final Color lineColor;
  final double pointRadius;
  final double lineWidth;

  static final List<(PoseLandmarkType, PoseLandmarkType)> _connections = [
    // Torso
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
    // Arms
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
    (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
    (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
    // Legs
    (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
    (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
    (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
    (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
    // Head
    (PoseLandmarkType.leftEye, PoseLandmarkType.rightEye),
    (PoseLandmarkType.leftEar, PoseLandmarkType.leftEye),
    (PoseLandmarkType.rightEar, PoseLandmarkType.rightEye),
    (PoseLandmarkType.nose, PoseLandmarkType.leftEye),
    (PoseLandmarkType.nose, PoseLandmarkType.rightEye),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty || imageSize.width == 0 || imageSize.height == 0) {
      return;
    }

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final pose in poses) {
      final landmarks = pose.landmarks;

      // Draw points
      for (final landmark in landmarks.values) {
        final Offset p = Offset(
          landmark.x * scaleX,
          landmark.y * scaleY,
        ) +
            offset;
        canvas.drawCircle(p, pointRadius, pointPaint);
      }

      // Draw connections
      for (final (startType, endType) in _connections) {
        final start = landmarks[startType];
        final end = landmarks[endType];
        if (start == null || end == null) continue;

        final Offset p1 =
            Offset(start.x * scaleX, start.y * scaleY) + offset;
        final Offset p2 = Offset(end.x * scaleX, end.y * scaleY) + offset;
        canvas.drawLine(p1, p2, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.lineColor != lineColor;
  }
}

