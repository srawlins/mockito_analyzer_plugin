import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:mockito_analyzer_plugin/src/utils.dart';

class MockitoWhen extends AnalysisRule {
  static const LintCode code = LintCode(
    'mockito_when',
    "Only use a Mock object inside a call to 'when'.",
    correctionMessage: "Try using a Mock object inside the call to 'when'",
  );

  MockitoWhen()
    : super(
        name: 'mockito_when',
        description: r"Only use a Mock object inside a call to 'when'.",
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

    var firstArgument = node.argumentList.arguments.firstOrNull;
    if (firstArgument == null) return;

    DartType? targetType;

    // The argument to `when` should be a property access, or a method call.
    if (firstArgument is MethodInvocation) {
      // `when(a.b())` or `when(a.b.c())`.
      // `realTarget` is used in case of cascades, which we really shouldn't
      // have here. Probably not worth worrying about though, as you'd have to
      // be working hard to go the wrong way, using a cascade when creating a
      // stub.
      targetType = firstArgument.realTarget?.staticType;
    } else if (firstArgument is PropertyAccess) {
      // `when(a.b)` or `when(a.b.c)`.
      targetType = firstArgument.realTarget.staticType;
    } else {
      // Well this could be even weirder. Something like `when(a)` or `when(7)`
      // or `when(!a)`... should probably report something...
      return;
    }

    if (targetType is! InterfaceType || !targetType.extendsMock) {
      rule.reportAtNode(node.function);
    }
  }
}
