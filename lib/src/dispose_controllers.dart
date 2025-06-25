import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class DisposeControllers extends DartLintRule {
  const DisposeControllers() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'dispose_controllers',
    problemMessage:
        '''Controllers must be disposed to prevent memory leaks. Add a dispose() call for this controller in the dispose() method.''',
    errorSeverity: ErrorSeverity.WARNING,
  );

  // List of controller types that need disposal
  static const Set<String> _controllerTypes = <String>{
    'AnimationController',
    'TextEditingController',
    'ScrollController',
    'PageController',
    'TabController',
    'VideoPlayerController',
    'FocusNode',
    'StreamController',
    'StreamSubscription',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((ClassDeclaration node) {
      _checkControllerDisposal(node, reporter);
    });
  }

  void _checkControllerDisposal(
    ClassDeclaration classNode,
    ErrorReporter reporter,
  ) {
    // Find all controller fields in the class
    final Map<String, FieldDeclaration> controllerFields =
        <String, FieldDeclaration>{};
    final Set<String> disposedControllers = <String>{};

    // Collect controller fields
    for (final ClassMember member in classNode.members) {
      if (member is FieldDeclaration) {
        for (final VariableDeclaration variable in member.fields.variables) {
          final String fieldName = variable.name.lexeme;

          // Check type annotation from AST instead of resolved type
          final TypeAnnotation? typeAnnotation = member.fields.type;
          if (typeAnnotation != null &&
              _isControllerTypeFromAnnotation(typeAnnotation)) {
            controllerFields[fieldName] = member;
          }
        }
      }
    }

    // Check if the class has a dispose method and collect disposed controllers
    MethodDeclaration? disposeMethod;
    for (final ClassMember member in classNode.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
        disposeMethod = member;
        _collectDisposedControllers(member, disposedControllers);
        break;
      }
    }

    // If there are controllers but no dispose method, report class-level error
    if (controllerFields.isNotEmpty && disposeMethod == null) {
      reporter.reportError(
        AnalysisError.forValues(
          source: reporter.source,
          offset: classNode.name.offset,
          length: classNode.name.length,
          errorCode: _code,
          message:
              '''Class with controllers must have a dispose() method to clean up resources.''',
        ),
      );
    } else if (controllerFields.isNotEmpty && disposeMethod != null) {
      // If dispose method exists, check for undisposed controllers
      for (final MapEntry<String, FieldDeclaration> entry
          in controllerFields.entries) {
        final String fieldName = entry.key;
        final FieldDeclaration fieldDeclaration = entry.value;

        if (!disposedControllers.contains(fieldName)) {
          // Check if it's a late field that might be conditionally initialized
          final bool isLate = fieldDeclaration.fields.isLate;
          final bool hasInitializer = fieldDeclaration.fields.variables.any(
            (VariableDeclaration variable) => variable.initializer != null,
          );

          // Only report if it's not a late field without initializer
          // (assuming late fields without initializers might be
          // conditionally created)
          if (!isLate || hasInitializer) {
            reporter.reportError(
              AnalysisError.forValues(
                source: reporter.source,
                offset: fieldDeclaration.offset,
                length: fieldDeclaration.length,
                errorCode: _code,
                message: _code.problemMessage,
              ),
            );
          }
        }
      }
    }
  }

  bool _isControllerTypeFromAnnotation(TypeAnnotation typeAnnotation) {
    // Get the type name from the AST node
    String typeName = '';

    if (typeAnnotation is NamedType) {
      // For simple types like AnimationController
      typeName = typeAnnotation.name2.lexeme;
    } else {
      // Fallback to string representation for other types
      typeName = typeAnnotation.toString();
      // Extract type name from generic types like "StreamController<String>"
      if (typeName.contains('<')) {
        typeName = typeName.substring(0, typeName.indexOf('<'));
      }
    }

    // Check if it's one of our controller types
    if (_controllerTypes.contains(typeName)) {
      return true;
    }

    // Check if it's a generic type (like StreamController<String>)
    for (final String controllerType in _controllerTypes) {
      if (typeName.startsWith(controllerType)) {
        return true;
      }
    }

    return false;
  }

  void _collectDisposedControllers(
    MethodDeclaration disposeMethod,
    Set<String> disposedControllers,
  ) {
    final BlockFunctionBody? body = disposeMethod.body as BlockFunctionBody?;
    if (body == null) return;

    for (final Statement statement in body.block.statements) {
      // Look for dispose calls like: controller.dispose()
      if (statement is ExpressionStatement) {
        final Expression expression = statement.expression;

        if (expression is MethodInvocation) {
          final String methodName = expression.methodName.name;
          if (methodName == 'dispose') {
            final Expression? target = expression.target;
            if (target is SimpleIdentifier) {
              disposedControllers.add(target.name);
            } else if (target is PropertyAccess) {
              final Expression? propertyTarget = target.target;
              if (propertyTarget is ThisExpression) {
                disposedControllers.add(target.propertyName.name);
              }
            }
          }
        }

        // Look for cancel calls like: subscription.cancel()
        if (expression is MethodInvocation) {
          final String methodName = expression.methodName.name;
          if (methodName == 'cancel') {
            final Expression? target = expression.target;
            if (target is SimpleIdentifier) {
              disposedControllers.add(target.name);
            }
          }
        }
      }
    }
  }
}
