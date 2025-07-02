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
        '''Controllers must be disposed to prevent memory leaks. Add a dispose() or close() call for this controller in the dispose() method.''',
    errorSeverity: ErrorSeverity.ERROR,
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
    'Timer',
    'IOSink',
    'HttpClient',
    'WebSocket',
    'RandomAccessFile',
    'Socket',
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
            // Skip nullable fields without initializers - they're likely just
            // state holders, not managed resources
            final bool isNullable = _isNullableType(typeAnnotation);
            final bool hasInitializer = variable.initializer != null;

            // Only track fields that are either:
            // 1. Non-nullable (definitely need disposal)
            // 2. Nullable but have initializers (actively managing resources)
            if (!isNullable || hasInitializer) {
              controllerFields[fieldName] = member;
            }
          }
        }
      }
    }

    // Check if the class has a dispose or close method
    // and collect disposed controllers
    MethodDeclaration? disposeMethod;
    for (final ClassMember member in classNode.members) {
      if (member is MethodDeclaration &&
          (member.name.lexeme == 'dispose' || member.name.lexeme == 'close')) {
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
              '''Class with controllers must have a dispose() or close() method to clean up resources.''',
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

    try {
      if (typeAnnotation is NamedType) {
        // For simple types like AnimationController
        // Use safe access to prevent exceptions
        typeName = typeAnnotation.name2.lexeme;
      } else {
        // Fallback to string representation for other types
        typeName = typeAnnotation.toString();
        // Extract type name from generic types like "StreamController<String>"
        if (typeName.contains('<')) {
          typeName = typeName.substring(0, typeName.indexOf('<'));
        }
      }
    } catch (e) {
      // If we can't get the type name safely, use string representation
      typeName = typeAnnotation.toString();
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

  bool _isNullableType(TypeAnnotation typeAnnotation) {
    // Check if the type is nullable (ends with ?)
    if (typeAnnotation is NamedType) {
      return typeAnnotation.question != null;
    }

    // For other types, check string representation
    final String typeString = typeAnnotation.toString();
    return typeString.endsWith('?');
  }

  void _collectDisposedControllers(
    MethodDeclaration disposeMethod,
    Set<String> disposedControllers,
  ) {
    final BlockFunctionBody? body = disposeMethod.body is BlockFunctionBody
        ? disposeMethod.body as BlockFunctionBody
        : null;
    if (body == null) return;

    _collectDisposedControllersFromStatements(
      body.block.statements,
      disposedControllers,
    );
  }

  void _collectDisposedControllersFromStatements(
    List<Statement> statements,
    Set<String> disposedControllers,
  ) {
    for (final Statement statement in statements) {
      _collectDisposedControllersFromStatement(statement, disposedControllers);
    }
  }

  void _collectDisposedControllersFromStatement(
    Statement statement,
    Set<String> disposedControllers,
  ) {
    if (statement is ExpressionStatement) {
      _checkDisposalExpression(statement.expression, disposedControllers);
    } else if (statement is IfStatement) {
      // Recursively check the then statement
      _collectDisposedControllersFromStatement(
        statement.thenStatement,
        disposedControllers,
      );

      // Check the else statement if it exists
      final Statement? elseStatement = statement.elseStatement;
      if (elseStatement != null) {
        _collectDisposedControllersFromStatement(
          elseStatement,
          disposedControllers,
        );
      }
    } else if (statement is Block) {
      // Recursively check statements in blocks
      _collectDisposedControllersFromStatements(
        statement.statements,
        disposedControllers,
      );
    } else if (statement is TryStatement) {
      // Check the try block
      _collectDisposedControllersFromStatement(
        statement.body,
        disposedControllers,
      );

      // Check catch clauses
      for (final CatchClause catchClause in statement.catchClauses) {
        _collectDisposedControllersFromStatement(
          catchClause.body,
          disposedControllers,
        );
      }

      // Check finally block
      final Block? finallyBlock = statement.finallyBlock;
      if (finallyBlock != null) {
        _collectDisposedControllersFromStatement(
          finallyBlock,
          disposedControllers,
        );
      }
    }
  }

  void _checkDisposalExpression(
    Expression expression,
    Set<String> disposedControllers,
  ) {
    if (expression is MethodInvocation) {
      _checkMethodInvocation(expression, disposedControllers);
    } else if (expression is AwaitExpression) {
      // Handle awaited disposal calls like: await controller.close()
      final Expression awaitedExpression = expression.expression;
      if (awaitedExpression is MethodInvocation) {
        _checkMethodInvocation(awaitedExpression, disposedControllers);
      }
    }
  }

  void _checkMethodInvocation(
    MethodInvocation methodInvocation,
    Set<String> disposedControllers,
  ) {
    final String methodName = methodInvocation.methodName.name;

    // Accept dispose(), close(), or cancel() methods
    if (methodName == 'dispose' ||
        methodName == 'close' ||
        methodName == 'cancel') {
      final Expression? target = methodInvocation.target;
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
}
