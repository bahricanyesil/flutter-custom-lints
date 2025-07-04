# 1.0.18 - 05.07.2025

- **Enhanced `no_null_force` lint rule**:
  - Added support for regular assignment patterns (e.g., `x = value; ... x!`)
  - Enhanced pattern detection for variables that are guaranteed to be non-null after regular assignments
  - Fixed false positives for sequential assignments in the same function scope
  - Better handling of complex initialization patterns where variables are assigned and then immediately used

# 1.0.17 - 05.07.2025

- **Enhanced `no_null_force` lint rule**:
  - Added support for null-aware assignment patterns (e.g., `x ??= value; ... x!`)
  - Improved recognition of safe null force usage after null-aware assignment operator
  - Enhanced pattern detection for variables that are guaranteed to be non-null after `??=` assignment
  - Better handling of complex initialization patterns in service classes and dependency injection scenarios

# 1.0.16 - 02.07.2025

- **Enhanced `no_null_force` lint rule**:
  - Added support for null-check-with-assignment patterns (e.g., `if (x == null) { x = value; } ... x!`)
  - Improved recognition of safe null force usage after variable assignment within null checks
  - Enhanced pattern detection for variables that are guaranteed to be non-null after conditional assignment

# 1.0.15 - 02.07.2025

- **Enhanced `no_null_force` lint rule**:
  - Fixed false positive for spread operator usage in collection literals with null checks (e.g., `{if (action.pathParams != null) ...action.pathParams!}`)
  - Added proper handling of `SpreadElement` nodes within if conditions in collection literals
  - Enhanced variable name detection to support property access expressions like `object.property`
  - Improved pattern matching for complex expressions in null-safe contexts

# 1.0.14 - 02.07.2025

- **Enhanced `no_null_force` lint rule**:
  - Added support for early return patterns after null checks (e.g., `if (variable == null) return; ... variable!`)
  - Improved recognition of type promotion scenarios where variables are guaranteed to be non-null after early return null checks
  - Enhanced pattern matching for legitimate null force usage in methods with conditional early returns
  - Better handling of nested functions and complex control flow structures with null checks

# 1.0.13 - 02.07.2025

- **Enhanced `dispose_controllers` lint rule**:
  - Improved handling of late fields without initializers (now correctly treats them as state holders rather than managed resources)
  - Enhanced nullable field detection to avoid false positives for fields that are just state holders
  - Added support for `cancel()` method in addition to `dispose()` and `close()`
  - Better conditional disposal detection within if statements, try-catch blocks, and other control structures
  - Improved async disposal pattern recognition with proper await expression handling
  - Enhanced error reporting and robustness for edge cases

- **Enhanced `no_null_force` lint rule**:
  - Added support for null-safety checking in collection literals with if conditions (e.g., `{if (x != null) 'key': x!}`)
  - Improved detection of null checks in various contexts including nested conditions
  - Better pattern matching for legitimate null force usage after proper null checks

- **Comprehensive example application updates**:
  - Added detailed demonstrations of all lint rules with both good and bad examples
  - Added mock controller classes to showcase proper disposal patterns
  - Included examples of conditional disposal, async disposal, and edge cases
  - Added examples of classes that correctly avoid triggering lint rules (like nullable Timer fields used as state holders)
  - Enhanced documentation with clear explanations of each lint rule's purpose

# 1.0.12 - 01.07.2025

- **New lint rule**: Added `no_null_force` to prevent unsafe use of the null force operator (`!`)
- Enhanced `no_direct_iterable_access` rule to properly distinguish between read and write operations on collections
- Expanded example application with comprehensive demonstrations of all lint rules
- Updated comprehensive analysis options with latest Flutter linting best practices
- Improved error messages and documentation for better developer experience

## 1.0.11

- Improve dispose controller lint rule to not trigger when close method is used instead of dispose.

## 1.0.10

- Improve dispose controller lint rule to not trigger when timer and controllers are defined as fields.

## 1.0.9

- Improve dispose controller lint rule to consider async dispose methods.

## 1.0.8

- Improve dispose controller lint rule to consider isClosed check before.

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
