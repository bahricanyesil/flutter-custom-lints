import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

class NoNullForce extends DartLintRule {
  const NoNullForce() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'no_null_force',
    problemMessage:
        '''Avoid using the null force operator (!). Consider using null-aware operators or proper null checking instead.''',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addPostfixExpression((PostfixExpression node) {
      if (node.operator.type == TokenType.BANG) {
        // Check if the expression is part of a null check
        final AstNode? parent = node.parent;

        // Case 1: Check for "x == null || x!.method()" pattern
        if (parent is BinaryExpression) {
          final Expression leftOperand = parent.leftOperand;
          if (leftOperand is BinaryExpression &&
              leftOperand.operator.type == TokenType.EQ_EQ &&
              leftOperand.rightOperand is NullLiteral) {
            return;
          }
        }

        // Case 2: Check if we're inside an if statement that checks for null
        AstNode? currentNode = node;
        while (currentNode != null) {
          if (currentNode is IfStatement) {
            final Expression condition = currentNode.expression;
            if (_isNullCheckCondition(condition)) {
              final String? checkedVar = _getCheckedVariableName(condition);
              final String? forcedVar = _getVariableName(node.operand);

              if (checkedVar != null &&
                  forcedVar != null &&
                  checkedVar == forcedVar) {
                return;
              }
            }
          }
          // Case 3: Check for collection literal if conditions
          // e.g., {if (x != null) 'key': x!}
          else if (currentNode is MapLiteralEntry ||
              currentNode is CollectionElement) {
            // Look for parent SetOrMapLiteral or ListLiteral
            AstNode? parentLiteral = currentNode.parent;
            while (parentLiteral != null) {
              if (parentLiteral is SetOrMapLiteral ||
                  parentLiteral is ListLiteral) {
                // Check if this is within an if element
                AstNode? ifElement = currentNode;
                while (ifElement != null && ifElement != parentLiteral) {
                  if (ifElement is IfElement) {
                    final Expression condition = ifElement.expression;
                    if (_isNullCheckCondition(condition)) {
                      final String? checkedVar = _getCheckedVariableName(
                        condition,
                      );
                      final String? forcedVar = _getVariableName(node.operand);

                      if (checkedVar != null &&
                          forcedVar != null &&
                          checkedVar == forcedVar) {
                        return;
                      }
                    }
                  }
                  ifElement = ifElement.parent;
                }
                break;
              }
              parentLiteral = parentLiteral.parent;
            }
          }
          currentNode = currentNode.parent;
        }

        reporter.reportError(
          AnalysisError.forValues(
            source: reporter.source,
            offset: node.offset,
            length: node.length,
            errorCode: _code,
            message: _code.problemMessage,
          ),
        );
      }
    });
  }

  /// Check if the condition is a null check (either x == null or x != null)
  bool _isNullCheckCondition(Expression condition) {
    if (condition is BinaryExpression) {
      final TokenType operatorType = condition.operator.type;
      return (operatorType == TokenType.EQ_EQ ||
              operatorType == TokenType.BANG_EQ) &&
          (condition.rightOperand is NullLiteral ||
              condition.leftOperand is NullLiteral);
    }
    return false;
  }

  /// Get the variable name from a null check condition
  String? _getCheckedVariableName(Expression condition) {
    if (condition is BinaryExpression) {
      // Handle both x == null and x != null patterns
      if (condition.rightOperand is NullLiteral) {
        return _getVariableName(condition.leftOperand);
      } else if (condition.leftOperand is NullLiteral) {
        return _getVariableName(condition.rightOperand);
      }
    }
    return null;
  }

  String? _getVariableName(Expression? expression) {
    if (expression is SimpleIdentifier) {
      return expression.name;
    }
    return null;
  }
}
