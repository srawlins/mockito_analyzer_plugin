// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:test_analyzer_plugin/src/rules/mockito_when.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MockitoWhenTest);
  });
}

@reflectiveTest
class MockitoWhenTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'mockito_when';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoWhen());

    super.setUp();

    var mockitoPath = '/packages/mockito';
    newFile('$mockitoPath/lib/src/mock.dart', '''
class Mock {}
Expectation get when => (_) {}
Null get any => null;
Null anyNamed(String named) => null;
Null argThat(Object? matcher, {String? named}) => null;
typedef Expectation = void Function(Object? o);
''');
    writeTestPackageConfig(
      PackageConfigFileBuilder()
        ..add(name: 'mockito', rootPath: convertPath(mockitoPath)),
    );
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
