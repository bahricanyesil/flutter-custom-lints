// ignore_for_file: unused_field, prefer-match-file-name

/// Mock controller classes for testing
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

class FocusNode {
  void dispose() {}
}

// This should fail - AnimationController without disposal
class BadAnimationWidget {
  late AnimationController _controller;

  void initWidget() {
    _controller = AnimationController();
  }

  // Missing dispose() method - should trigger lint error
}

// This should fail - TextEditingController without disposal
class BadFormWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Missing dispose() method - should trigger lint error
}

// This should fail - Controllers exist but dispose method doesn't dispose them
class BadPartialDisposeWidget {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  void dispose() {
    // Only disposing one controller, missing the other
    _scrollController.dispose();
  }
}

// This should fail - StreamController without disposal
class BadStreamWidget {
  final StreamController<String> _streamController = StreamController<String>();

  // Missing dispose() method - should trigger lint error
}

// This should fail - Multiple controllers, no dispose method
class BadMultipleControllers {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Missing dispose() method - should trigger lint error
}
