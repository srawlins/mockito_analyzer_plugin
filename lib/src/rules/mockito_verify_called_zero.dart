import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:mockito_analyzer_plugin/src/utils.dart';

class MockitoVerifyCalledZero extends AnalysisRule {
  static const LintCode code = LintCode(
    'mockito_verify_called_zero',
    "Do not use 'called(0)' to verify a method is not called.",
    correctionMessage: "Try using 'verifyNever' instead",
  );

  MockitoVerifyCalledZero()
    : super(
        name: 'mockito_verify_called_zero',
        description:
            r"Do not use 'called(0)' to verify a method is not called.",
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (!node.function.isVerify) return;

    if (node.parent case MethodInvocation parentInvocation) {
      if (parentInvocation.methodName.name != 'called') return;
      if (parentInvocation.argumentList.arguments.isEmpty) return;
      var firstArgument = parentInvocation.argumentList.arguments.first;
      if (firstArgument is IntegerLiteral &&
          firstArgument.literal.lexeme == '0') {
        var offset = parentInvocation.operator!.offset;
        var length = parentInvocation.end - offset;
        rule.reportAtOffset(offset, length);
      }
    }
  }
}
