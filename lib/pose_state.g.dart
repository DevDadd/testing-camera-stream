// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pose_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PoseStateCWProxy {
  PoseState image(File? image);

  PoseState poses(List<Pose>? poses);

  PoseState cameraReady(bool cameraReady);

  /// Creates a new instance with the provided field values.
  PoseState call({File? image, List<Pose>? poses, bool? cameraReady});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPoseState.copyWith(...)` or call `instanceOfPoseState.copyWith.fieldName(value)` for a single field.
class _$PoseStateCWProxyImpl implements _$PoseStateCWProxy {
  const _$PoseStateCWProxyImpl(this._value);

  final PoseState _value;

  @override
  PoseState image(File? image) => call(image: image);

  @override
  PoseState poses(List<Pose>? poses) => call(poses: poses);

  @override
  PoseState cameraReady(bool cameraReady) => call(cameraReady: cameraReady);

  @override
  PoseState call({
    Object? image = const $CopyWithPlaceholder(),
    Object? poses = const $CopyWithPlaceholder(),
    Object? cameraReady = const $CopyWithPlaceholder(),
  }) {
    return PoseState(
      image: image == const $CopyWithPlaceholder()
          ? _value.image
          // ignore: cast_nullable_to_non_nullable
          : image as File?,
      poses: poses == const $CopyWithPlaceholder()
          ? _value.poses
          // ignore: cast_nullable_to_non_nullable
          : poses as List<Pose>?,
      cameraReady: cameraReady == const $CopyWithPlaceholder()
          ? _value.cameraReady
          // ignore: cast_nullable_to_non_nullable
          : cameraReady as bool,
    );
  }
}

extension $PoseStateCopyWith on PoseState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPoseState.copyWith(...)` or `instanceOfPoseState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PoseStateCWProxy get copyWith => _$PoseStateCWProxyImpl(this);
}
