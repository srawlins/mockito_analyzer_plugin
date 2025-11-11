import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:mockito_analyzer_plugin/src/utils.dart';

class MockitoMissingStub extends AnalysisRule {
  static const LintCode code = LintCode(
    'mockito_missing_stub',
    "A call to 'when' must be followed by a stub.",
    correctionMessage:
        "Try calling 'thenReturn', 'thenReturnInOrder', 'thenAnswer', or "
        "'thenThrow' after the 'when' call",
  );

  MockitoMissingStub()
    : super(
        name: 'mockito_missing_stub',
        description: r"A call to 'when' must be followed by a stub.",
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
    if (!node.function.isWhen) return;

    if (node.parent case MethodInvocation parentInvocation) {
      if (const [
        'thenReturn',
        'thenReturnInOrder',
        'thenThrow',
        'thenAnswer',
      ].contains(parentInvocation.methodName.name)) {
        return;
      }
    }
    rule.reportAtNode(node);
  }
}
