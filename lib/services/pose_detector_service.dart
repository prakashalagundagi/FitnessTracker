import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class PoseDetectorService {
  static final PoseDetectorService _instance = PoseDetectorService._internal();
  factory PoseDetectorService() => _instance;
  PoseDetectorService._internal();

  late PoseDetector _poseDetector;
  bool _isInitialized = false;

  // Push-up detection state
  int _pushupCount = 0;
  bool _isPushupUp = true;
  DateTime? _lastPushupTime;

  // Squat detection state
  int _squatCount = 0;
  bool _isSquatUp = true;
  DateTime? _lastSquatTime;

  // Sit-up detection state
  int _situpCount = 0;
  bool _isSitupDown = false;
  DateTime? _lastSitupTime;

  // Timing constants - high precision requirements
  final int _minTimeBetweenPushups = 2000; // ms - require full pushup cycle
  final int _minTimeBetweenSquats = 2500; // ms - require full squat cycle
  final int _minTimeBetweenSitups = 2000; // ms - require full situp cycle
  
  // High precision detection thresholds
  bool _personDetected = false;
  double _currentBodyPosition = 0.0;
  double _previousBodyPosition = 0.0;
  bool _inUpPosition = true;
  bool _inDownPosition = false;
  int _framesInPosition = 0;
  final int _requiredFramesInPosition = 5; // Must hold position for 5 frames
  final double _positionThreshold = 0.4; // 40% movement required for count

  Future<void> initialize() async {
    if (!_isInitialized) {
      // Initialize ML Kit Pose Detector
      _poseDetector = PoseDetector(options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ));
      _isInitialized = true;
    }
  }

  void dispose() {
    _poseDetector.close();
    _isInitialized = false;
  }

  // High precision pose detection with ML Kit
  Future<Map<String, dynamic>> detectExercise(CameraImage image, String exerciseType) async {
    if (!_isInitialized) {
      return {
        'count': 0,
        'isGoodForm': true,
        'feedback': 'Initializing...',
        'personDetected': false,
      };
    }

    final now = DateTime.now();
    Map<String, dynamic> result = {
      'count': 0,
      'isGoodForm': true,
      'feedback': 'No person detected',
      'personDetected': _personDetected,
    };

    try {
      // Convert CameraImage to InputImage for ML Kit
      final inputImage = _inputImageFromCameraImage(image);
      
      // Detect poses
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isEmpty) {
        _personDetected = false;
        result['feedback'] = 'Please stand in camera view';
        return result;
      }
      
      _personDetected = true;
      
      // Get the first pose (assume single person)
      final pose = poses.first;
      
      // Calculate body position from pose landmarks
      _currentBodyPosition = _calculateBodyPosition(pose, exerciseType);
      
      switch (exerciseType.toLowerCase()) {
        case 'pushups':
          result = _detectPushupsHighPrecision(now);
          break;
        case 'squats':
          result = _detectSquatsHighPrecision(now);
          break;
        case 'situps':
          result = _detectSitupsHighPrecision(now);
          break;
        case 'plank':
          result = _detectPlank(now);
          break;
      }

      _previousBodyPosition = _currentBodyPosition;
      
    } catch (e) {
      result['feedback'] = 'Detection error: $e';
      result['personDetected'] = false;
    }

    return result;
  }

  // Calculate body position from pose landmarks
  double _calculateBodyPosition(Pose pose, String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'pushups':
        return _calculatePushupPosition(pose);
      case 'squats':
        return _calculateSquatPosition(pose);
      case 'situps':
        return _calculateSitupPosition(pose);
      default:
        return 0.5;
    }
  }

  double _calculatePushupPosition(Pose pose) {
    // For pushups, track elbow angle and body height
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    
    if (leftShoulder != null && leftElbow != null && leftWrist != null) {
      // Calculate elbow angle using landmark positions
      final angle = _calculateAngleFromLandmarks(leftShoulder, leftElbow, leftWrist);
      // Convert to 0-1 range (0 = fully down, 1 = fully up)
      return (180 - angle) / 180;
    }
    return 0.5;
  }

  double _calculateSquatPosition(Pose pose) {
    // For squats, track knee angle and hip height
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      // Calculate knee angle using landmark positions
      final angle = _calculateAngleFromLandmarks(leftHip, leftKnee, leftAnkle);
      // Convert to 0-1 range (0 = fully down, 1 = fully up)
      return angle / 180;
    }
    return 0.5;
  }

  double _calculateSitupPosition(Pose pose) {
    // For situps, track torso angle
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    
    if (leftShoulder != null && leftHip != null) {
      // Calculate torso angle relative to vertical
      final dy = leftShoulder.y - leftHip.y;
      // Normalize to 0-1 range
      return (dy + 1) / 2;
    }
    return 0.5;
  }

  double _calculateAngleFromLandmarks(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final radians = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    var degrees = radians * 180 / pi;
    if (degrees < 0) degrees += 360;
    return degrees;
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    // This is a simplified version - you'd need to implement proper conversion
    // based on your camera configuration
    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
  
  bool _isSignificantMovement() {
    final movement = (_currentBodyPosition - _previousBodyPosition).abs();
    return movement > _positionThreshold;
  }

  Map<String, dynamic> _detectPushupsHighPrecision(DateTime now) {
    // Check timing constraint
    if (_lastPushupTime != null && 
        now.difference(_lastPushupTime!).inMilliseconds < _minTimeBetweenPushups) {
      return {
        'count': _pushupCount,
        'isGoodForm': true,
        'feedback': 'Good pace - wait for complete rep',
        'personDetected': true,
      };
    }

    // Detect position change
    if (_isSignificantMovement()) {
      if (_inUpPosition && _currentBodyPosition < 0.3) {
        // Moving down
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _inUpPosition = false;
          _inDownPosition = true;
          _framesInPosition = 0;
        }
      } else if (_inDownPosition && _currentBodyPosition > 0.7) {
        // Moving up - complete rep
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _pushupCount++;
          _lastPushupTime = now;
          _inUpPosition = true;
          _inDownPosition = false;
          _framesInPosition = 0;
          
          return {
            'count': _pushupCount,
            'isGoodForm': true,
            'feedback': 'Good pushup! $_pushupCount',
            'personDetected': true,
          };
        }
      } else {
        _framesInPosition = 0;
      }
    } else {
      _framesInPosition = 0;
    }

    return {
      'count': _pushupCount,
      'isGoodForm': true,
      'feedback': _inUpPosition ? 'Go down' : 'Push up',
      'personDetected': true,
    };
  }

  Map<String, dynamic> _detectSquatsHighPrecision(DateTime now) {
    // Check timing constraint
    if (_lastSquatTime != null && 
        now.difference(_lastSquatTime!).inMilliseconds < _minTimeBetweenSquats) {
      return {
        'count': _squatCount,
        'isGoodForm': true,
        'feedback': 'Good pace - wait for complete rep',
        'personDetected': true,
      };
    }

    // Detect position change
    if (_isSignificantMovement()) {
      if (_inUpPosition && _currentBodyPosition < 0.3) {
        // Moving down
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _inUpPosition = false;
          _inDownPosition = true;
          _framesInPosition = 0;
        }
      } else if (_inDownPosition && _currentBodyPosition > 0.7) {
        // Moving up - complete rep
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _squatCount++;
          _lastSquatTime = now;
          _inUpPosition = true;
          _inDownPosition = false;
          _framesInPosition = 0;
          
          return {
            'count': _squatCount,
            'isGoodForm': true,
            'feedback': 'Good squat! $_squatCount',
            'personDetected': true,
          };
        }
      } else {
        _framesInPosition = 0;
      }
    } else {
      _framesInPosition = 0;
    }

    return {
      'count': _squatCount,
      'isGoodForm': true,
      'feedback': _inUpPosition ? 'Go down' : 'Stand up',
      'personDetected': true,
    };
  }

  Map<String, dynamic> _detectSitupsHighPrecision(DateTime now) {
    // Check timing constraint
    if (_lastSitupTime != null && 
        now.difference(_lastSitupTime!).inMilliseconds < _minTimeBetweenSitups) {
      return {
        'count': _situpCount,
        'isGoodForm': true,
        'feedback': 'Good pace - wait for complete rep',
        'personDetected': true,
      };
    }

    // Detect position change
    if (_isSignificantMovement()) {
      if (_inUpPosition && _currentBodyPosition < 0.3) {
        // Moving down (lying back)
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _inUpPosition = false;
          _inDownPosition = true;
          _framesInPosition = 0;
        }
      } else if (_inDownPosition && _currentBodyPosition > 0.7) {
        // Moving up - complete rep
        _framesInPosition++;
        if (_framesInPosition >= _requiredFramesInPosition) {
          _situpCount++;
          _lastSitupTime = now;
          _inUpPosition = true;
          _inDownPosition = false;
          _framesInPosition = 0;
          
          return {
            'count': _situpCount,
            'isGoodForm': true,
            'feedback': 'Good situp! $_situpCount',
            'personDetected': true,
          };
        }
      } else {
        _framesInPosition = 0;
      }
    } else {
      _framesInPosition = 0;
    }

    return {
      'count': _situpCount,
      'isGoodForm': true,
      'feedback': _inUpPosition ? 'Lie back' : 'Sit up',
      'personDetected': true,
    };
  }

  Map<String, dynamic> _detectPlank(DateTime now) {
    // Plank is timed, not counted
    return {
      'count': 0,
      'isGoodForm': true,
      'feedback': 'Hold strong!',
      'isPlank': true,
      'personDetected': _personDetected,
    };
  }

  void resetCount() {
    _pushupCount = 0;
    _squatCount = 0;
    _situpCount = 0;
    _isPushupUp = true;
    _isSquatUp = true;
    _isSitupDown = false;
    _lastPushupTime = null;
    _lastSquatTime = null;
    _lastSitupTime = null;
    
    // Reset high precision detection variables
    _personDetected = false;
    _currentBodyPosition = 0.0;
    _previousBodyPosition = 0.0;
    _inUpPosition = true;
    _inDownPosition = false;
    _framesInPosition = 0;
  }

  int getCurrentCount(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'pushups':
        return _pushupCount;
      case 'squats':
        return _squatCount;
      case 'situps':
        return _situpCount;
      default:
        return 0;
    }
  }
}

class WorkoutResult {
  final int count;
  final bool isValid;
  final bool isNewRep;
  final String? phase;
  final bool personDetected;

  WorkoutResult({
    required this.count,
    required this.isValid,
    this.isNewRep = false,
    this.phase,
    required this.personDetected,
  });
}
