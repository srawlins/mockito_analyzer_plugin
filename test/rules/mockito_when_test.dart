// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_when.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../with_mockito_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MockitoWhenTest);
  });
}

@reflectiveTest
class MockitoWhenTest extends AnalysisRuleTest with WithMockitoPackage {
  @override
  String get analysisRule => 'mockito_when';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoWhen());
    super.setUp();
  }

  void test_mockInstance() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7));
}
class C extends Mock {
  Null m(int p) => null;
}
''');
  }

  void test_notMockInstance() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7));
}
class C {
  Null m(int p) => null;
}
''',
      [lint(56, 12)],
    );
  }
}
