import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';

class MockitoArgs extends MultiAnalysisRule {
  static const LintCode argMatcherOutsideStub = LintCode(
    'arg_matcher_outside_stub',
    'An arg matcher must only be used when creating a method stub',
    correctionMessage: 'Try dotdotdot',
  );

  static const LintCode argMatcherMissingNamedArg = LintCode(
    'arg_matcher_missing_named_arg',
    "An arg matcher passed as a named argument must itself have a 'named' argument",
    correctionMessage: "Try specifying `named: '{0}'`",
  );

  static const LintCode argMatcherMustBeNamed = LintCode(
    'arg_matcher_must_be_named',
    "'{0}' must be used when passed as a named argument",
    correctionMessage: "Try using '{0}'",
  );

  static const LintCode argMatcherHasWrongName = LintCode(
    'arg_matcher_has_wrong_name',
    "'{0}' must be specified as the arg matcher name",
    correctionMessage: "Try specifying `named: '{0}'`",
  );

  MockitoArgs()
    : super(
        name: 'mockito_args',
        description: r"Avoid using 'FutureOr<void>' as the type of a result.",
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [argMatcherOutsideStub];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
    registry.addSimpleIdentifier(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  void _checkArgMatcherName() {}

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!node.methodName.isArgMatcher) return;

    if (node.parent case ArgumentList(parent: MethodInvocation invocation)) {
      _checkArgMatcherOutsideStub(node, invocation);
    }

    if (node.parent case NamedExpression(
      name: var expectedArgLabel,
      parent: ArgumentList(parent: MethodInvocation invocation),
    )) {
      _checkArgMatcherOutsideStub(node, invocation);

      var expectedArgName = expectedArgLabel.label.name;
      Expression? argIndicatingName;
      var argIndicatingNameIsPositional =
          node.methodName.isAnyNamed || node.methodName.isCaptureAnyNamed;
      if (argIndicatingNameIsPositional) {
        argIndicatingName = node.argumentList.arguments.firstOrNull;
        if (argIndicatingName == null) {
          // The _required_ argument is missing, so there is a compile-time
          // error. Don't bother reporting anything.
          return;
        }
      } else {
        var argMatcherNamedArg = node.argumentList.arguments
            .whereType<NamedExpression>()
            .firstWhereOrNull((a) => a.name.label.name == 'named');
        if (argMatcherNamedArg == null) {
          // Something like `when(a.b(c: argThat(7)))`.
          rule.reportAtNode(
            node,
            diagnosticCode: MockitoArgs.argMatcherMissingNamedArg,
            arguments: [expectedArgName],
          );
          return;
        }
        argIndicatingName = argMatcherNamedArg.expression;
      }

      if (argIndicatingName case SimpleStringLiteral(
        stringValue: var nameValue?,
      )) {
        if (expectedArgName != nameValue) {
          // Something like `when(a.b(c: argThat(7, named: 'd')))`.
          rule.reportAtNode(
            node,
            diagnosticCode: MockitoArgs.argMatcherHasWrongName,
            arguments: [expectedArgName],
          );
        }
      } else {
        // Either the argument expression is not a SimpleStringLiteral, or
        // it's value couldn't be resolved. Don't worry about it.
      }
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!node.isArgMatcher) return;

    if (node.parent case ArgumentList(parent: MethodInvocation invocation)) {
      _checkArgMatcherOutsideStub(node, invocation);
    }

    if (node.parent case NamedExpression(parent: ArgumentList())) {
      // A simple identifier arg matcher (`any`, `captureAny`) as a named
      // argument.

      var namedEquivalent = const {
        'any': 'anyNamed',
        'captureAny': 'captureAnyNamed',
      }[node.name]!;
      rule.reportAtNode(
        node,
        diagnosticCode: MockitoArgs.argMatcherMustBeNamed,
        arguments: [namedEquivalent],
      );
    }
  }

  void _checkArgMatcherOutsideStub(
    AstNode errorNode,
    MethodInvocation invocation,
  ) {
    var targetType = invocation.realTarget?.staticType;
    if (targetType == null) {
      // TODO(srawlins): Check for implicit `this`. collection_unrelated has
      // examples.

      // E.g. `print(argThat(isNotNull))`
      rule.reportAtNode(
        errorNode,
        diagnosticCode: MockitoArgs.argMatcherOutsideStub,
      );
    } else {
      if (targetType is InterfaceType && targetType.extendsMock) return;
      rule.reportAtNode(
        errorNode,
        diagnosticCode: MockitoArgs.argMatcherOutsideStub,
      );
    }
  }
}

extension on InterfaceType {
  bool get extendsMock {
    if (element.name == 'Mock' && element.library.uri == _mockLibrary) {
      return true;
    }

    if (element.isSynthetic) return false;

    return element.allSupertypes.any(
      (i) => i.element.name == 'Mock' && i.element.library.uri == _mockLibrary,
    );
  }
}

extension on SimpleIdentifier {
  bool get isAny => name == 'any' && element?.library?.uri == _mockLibrary;

  bool get isAnyNamed =>
      name == 'anyNamed' && element?.library?.uri == _mockLibrary;

  bool get isArgThat =>
      name == 'argThat' && element?.library?.uri == _mockLibrary;

  bool get isCaptureAny =>
      name == 'captureAny' && element?.library?.uri == _mockLibrary;

  bool get isCaptureAnyNamed =>
      name == 'captureAnyNamed' && element?.library?.uri == _mockLibrary;

  bool get isCaptureThat =>
      name == 'captureThat' && element?.library?.uri == _mockLibrary;

  bool get isArgMatcher =>
      isAny ||
      isAnyNamed ||
      isArgThat ||
      isCaptureAny ||
      isCaptureAnyNamed ||
      isCaptureThat;
}

final _mockLibrary = Uri.parse('package:mockito/src/mock.dart');
