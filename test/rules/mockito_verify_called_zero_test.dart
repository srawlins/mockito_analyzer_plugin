// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_verify_called_zero.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../with_mockito_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MockitoVerifyCalledZeroTest);
  });
}

@reflectiveTest
class MockitoVerifyCalledZeroTest extends AnalysisRuleTest
    with WithMockitoPackage {
  @override
  String get analysisRule => 'mockito_verify_called_zero';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoVerifyCalledZero());
    super.setUp();
  }

  void test_verifyCalledTwo() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  verify(c.m(7)).called(2);
}
class C extends Mock {
  Null m(int p) => null;
}
''');
  }

  void test_verifyCalledZero() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  verify(c.m(7)).called(0);
}
class C extends Mock {
  Null m(int p) => null;
}
''',
      [lint(70, 10)],
    );
  }

  void test_verify_noParentMethodInvocation() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  verify(c.m(7));
}
class C extends Mock {
  Null m(int p) => null;
}
''');
  }
}
