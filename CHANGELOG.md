## 1.0.7

- **Enhancement**: `dispose_controllers` lint rule now accepts `close()` method in addition to `dispose()`
- Added support for more controller types that use `close()`: Timer, IOSink, HttpClient, WebSocket, RandomAccessFile, Socket
- Updated error messages to reflect that both `dispose()` and `close()` methods are acceptable
- Enhanced documentation with examples of both disposal patterns

## 1.0.6

- **Bug Fixes**: Fixed critical exceptions that could occur during AST analysis
- Added proper error handling in `dispose_controllers` lint rule when accessing type annotations
- Added safe type resolution in `no_as_type_assertion` lint rule to prevent crashes
- Improved robustness when analyzing complex generic types and malformed code
- Enhanced compatibility with different analyzer versions

## 1.0.5

- Revert unknowingly added lint rule

## 1.0.4

- Add `dispose_controllers` lint rule to enforce proper disposal of controllers like AnimationController, TextEditingController, etc.
- Prevents memory leaks by ensuring controllers have corresponding dispose() calls
- Supports 9 common controller types including StreamController and StreamSubscription
- Provides clear error messages for missing dispose methods or undisposed controllers

## 1.0.3

- Remove FVM-related content from README
- Remove hardcoded dependency versions from README to prevent misleading users

## 1.0.2

- Fix export problem

## 1.0.1

- Iterable access error lint fixes

## 1.0.0

- Initial version.
