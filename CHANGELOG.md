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
