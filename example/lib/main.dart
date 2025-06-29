// ignore_for_file: unused_local_variable, avoid_print, unnecessary_type_check

import 'dart:async';

Future<void> main() async {
  // Examples that will trigger lint warnings
  print('Flutter Custom Lints Example');

  // Example 1: no_as_type_assertion
  demonstrateAsTypeAssertion();

  // Example 2: no_direct_iterable_access
  demonstrateDirectIterableAccess();

  // Example 3: no_null_force
  demonstrateNullForce();

  // Example 4: use_compare_without_case
  demonstrateStringComparison();

  // Example 5: dispose_controllers
  await demonstrateDisposeControllers();
}

/// This is a test for the no_as_type_assertion lint
void demonstrateAsTypeAssertion() {
  const Object data = 'Hello World';

  // ❌ This will trigger no_as_type_assertion lint
  // const String str = data as String;

  // ✅ Better approach
  const String safeStr = data is String ? data : ''; // Safe type promotion
  print('Safe cast: $safeStr');
}

/// This is a test for the no_direct_iterable_access lint
void demonstrateDirectIterableAccess() {
  final List<String> items = <String>['apple', 'banana', 'cherry'];
  final List<String> emptyList = <String>[];

  // ❌ This will trigger no_direct_iterable_access lint for empty lists
  // ignore: no_direct_iterable_access
  final String first = emptyList.first; // Would throw at runtime

  // ✅ Better approaches
  final String? safeFirst = items.isNotEmpty ? items.safeFirst : null;
  print('Safe first item: $safeFirst');
}

/// This is a test for the no_null_force lint
void demonstrateNullForce() {
  const String nullableString = 'Hello';
  String? actuallyNull;

  // ❌ This will trigger no_null_force lint
  // final String forced = actuallyNull!; // Would throw at runtime

  // ✅ Better approach
  const String safe = nullableString; // Null-promoted
  print('Safe value: $safe');
}

/// This is a test for the use_compare_without_case lint
void demonstrateStringComparison() {
  const String str1 = 'Hello';
  const String str2 = 'HELLO';

  // ❌ This will trigger use_compare_without_case lint
  // if (str1 == str2) {
  //   print('Strings match (case insensitive)');
  // }

  // ✅ Better approach would be to use compareWithoutCase extension
  // For now, using standard comparison
  if (str1.compareWithoutCase(str2)) {
    print('Strings match (case insensitive)');
  }
}

extension on String {
  bool compareWithoutCase(String other) {
    // ignore: use_compare_without_case
    return toLowerCase() == other.toLowerCase();
  }
}

/// This is a test for the safe_first lint
// ignore: prefer-match-file-name
extension IterableUtilExtensions<T> on Iterable<T> {
  /// This is a test for the safe_first lint
  T? get safeFirst {
    if (isEmpty) return null;
    return first;
  }
}

/// This is a test for the dispose_controllers lint
Future<void> demonstrateDisposeControllers() async {
  print('Creating widgets with controllers...');

  // Create instances to demonstrate the lint rule
  final GoodControllerWidget goodWidget = GoodControllerWidget();
  final ConditionalDisposeWidget conditionalWidget = ConditionalDisposeWidget();
  final AsyncDisposeWidget asyncWidget = AsyncDisposeWidget();

  // Initialize and dispose properly
  goodWidget
    ..initControllers()
    ..dispose();

  conditionalWidget
    ..initControllers()
    ..dispose();

  // Demonstrate async disposal
  asyncWidget.initControllers();
  await asyncWidget.dispose();

  print('Controllers properly disposed');
}

/// Mock controller classes for the example
class AnimationController {
  bool _disposed = false;

  /// This is a test for the dispose_controllers lint
  bool get isDisposed => _disposed;

  /// This is a test for the dispose_controllers lint
  void dispose() {
    _disposed = true;
  }
}

/// This is a test for the dispose_controllers lint
class StreamController<T> {
  bool _closed = false;

  /// This is a test for the dispose_controllers lint
  bool get isClosed => _closed;

  /// This is a test for the dispose_controllers lint
  void close() {
    _closed = true;
  }
}

// ❌ This would trigger dispose_controllers lint
// class BadControllerWidget {
//   late AnimationController _animationController;
//   late StreamController<String> _streamController;
//
//   void initControllers() {
//     _animationController = AnimationController();
//     _streamController = StreamController<String>();
//   }
//
//   // Missing dispose() method - would trigger lint error
// }

/// ✅ Good example: Proper disposal
class GoodControllerWidget {
  late AnimationController _animationController;
  late StreamController<String> _streamController;

  /// This is a test for the dispose_controllers lint
  void initControllers() {
    _animationController = AnimationController();
    _streamController = StreamController<String>();
  }

  /// This is a test for the dispose_controllers lint
  void dispose() {
    _animationController.dispose();
    _streamController.close();
  }
}

/// ✅ Good example: Conditional disposal (like your case)
class ConditionalDisposeWidget {
  late StreamController<String> _visibilityController;
  bool _isDisposed = false;

  /// This is a test for the dispose_controllers lint
  void initControllers() {
    _visibilityController = StreamController<String>();
  }

  /// This is a test for the dispose_controllers lint
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // This pattern is now properly recognized by the lint rule
    if (!_visibilityController.isClosed) {
      _visibilityController.close();
    }
  }
}

/// ✅ Good example: Async disposal with await (like your case)
class AsyncDisposeWidget {
  late StreamController<String> _notificationController;
  late StreamController<int> _dataController;

  /// This is a test for the dispose_controllers lint
  void initControllers() {
    _notificationController = StreamController<String>();
    _dataController = StreamController<int>();
  }

  /// This is a test for the dispose_controllers lint
  Future<String?> dispose() async {
    try {
      // This pattern with await is now properly recognized
      _notificationController.close();
      _dataController.close();
      return null;
    } catch (e) {
      return 'Disposal failed: $e';
    }
  }
}

/// Information about a toast timer
/// ✅ This class has a Timer? field but correctly doesn't trigger the lint rule
/// because nullable fields without initializers are considered state holders,
/// not managed resources that need disposal
class ToastTimerInfo {
  /// Create toast timer info
  ToastTimerInfo({
    required this.toastId,
    required this.remainingDuration,
    required this.createdAt,
    required this.isPaused,
  });

  /// Toast ID
  final String toastId;

  /// Remaining duration before dismissal
  Duration remainingDuration;

  /// When the toast was created
  final DateTime createdAt;

  /// Whether the timer is currently paused
  bool isPaused;

  /// Active timer (null if paused) - nullable field without initializer
  /// This won't trigger the dispose_controllers lint because it's clearly
  /// just a state holder, not a managed resource
  Timer? timer;
}

/// This is a test for the dispose_controllers lint
class AuthBloc {
  late StreamSubscription<int> _authStateSubscription;

  /// This is a test for the dispose_controllers lint
  Future<void> close() async {
    await _authStateSubscription.cancel();
  }
}
