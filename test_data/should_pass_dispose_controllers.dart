// Mock controller classes for testing
// ignore: prefer-match-file-name
class AnimationController {
  void dispose() {}
}

class TextEditingController {
  void dispose() {}
}

class ScrollController {
  void dispose() {}
}

class PageController {
  void dispose() {}
}

class StreamController<T> {
  void dispose() {}
}

class StreamSubscription<T> {
  void cancel() {}
}

class FocusNode {
  void dispose() {}
}

// This should pass - AnimationController with proper disposal
class GoodAnimationWidget {
  late AnimationController _controller;

  void initWidget() {
    _controller = AnimationController();
  }

  void dispose() {
    _controller.dispose();
  }
}

// This should pass - TextEditingController with proper disposal
class GoodFormWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
  }
}

// This should pass - All controllers properly disposed
class GoodMultipleControllers {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();

  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _focusNode.dispose();
  }
}

// This should pass - StreamController with proper disposal
class GoodStreamWidget {
  final StreamController<String> _streamController = StreamController<String>();

  void dispose() {
    _streamController.dispose();
  }
}

// This should pass - StreamSubscription with proper cancellation
class GoodSubscriptionWidget {
  final StreamSubscription<int> _subscription = StreamSubscription<int>();

  void dispose() {
    _subscription.cancel();
  }
}

// This should pass - No controllers defined
class WidgetWithoutControllers {
  String title = 'Hello';
  int count = 0;

  void updateCount() {
    count++;
  }
}

// This should pass - Late field without initializer (conditionally created)
class ConditionalControllerWidget {
  late TextEditingController _controller;
  bool _isInitialized = false;

  void maybeInitialize() {
    if (!_isInitialized) {
      _controller = TextEditingController();
      _isInitialized = true;
    }
  }

  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
  }
}
