// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_missing_stub.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../with_mockito_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MockitoMissingStubTest);
  });
}

@reflectiveTest
class MockitoMissingStubTest extends AnalysisRuleTest with WithMockitoPackage {
  @override
  String get analysisRule => 'mockito_missing_stub';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoMissingStub());
    super.setUp();
  }

  void test_hasThenAnswer() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7)).thenAnswer((_) => 5);
}
class C extends Mock {
  int m(int p) => 1;
}
''');
  }

  void test_hasThenReturn() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7)).thenReturn(5);
}
class C extends Mock {
  int m(int p) => 1;
}
''');
  }

  void test_hasThenReturnInOrder() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7)).thenReturnInOrder([1, 2, 3]);
}
class C extends Mock {
  int m(int p) => 1;
}
''');
  }

  void test_hasThenThrow() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7)).thenThrow((_) => 'boo');
}
class C extends Mock {
  int m(int p) => 1;
}
''');
  }

  void test_missingStub() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(7));
}
class C extends Mock {
  Null m(int p) => null;
}
''',
      [lint(56, 4)],
    );
  }
}
