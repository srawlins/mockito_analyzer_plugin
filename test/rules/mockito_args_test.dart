// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_args.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MockitoArgsTest);
  });
}

@reflectiveTest
class MockitoArgsTest extends AnalysisRuleTest {
  @override
  String get analysisRule => 'mockito_args';

  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoArgs());

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

  void test_any_notStubCall_badTarget() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  c.m(any);
}
class C {
  void m(Object? p) {}
}
''',
      [lint(60, 3, name: 'arg_matcher_outside_stub')],
    );
  }

  void test_anyNamed_notStubCall_badTarget() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  c.m(p: anyNamed('p'));
}
class C {
  void m({Object? p}) {}
}
''',
      [lint(63, 13, name: 'arg_matcher_outside_stub')],
    );
  }

  void test_argThat_notStubCall_badTarget() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  c.m(argThat(1));
}
class C {
  void m(Object? p) {}
}
''',
      [lint(60, 10, name: 'arg_matcher_outside_stub')],
    );
  }

  void test_argThat_notStubCall_noTarget() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f() {
  print(argThat(1));
}
''',
      [lint(59, 10, name: 'arg_matcher_outside_stub')],
    );
  }

  void test_argThat_stubCall() async {
    await assertNoDiagnostics(r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  c.m(argThat(1));
}
class C extends Mock {
  void m(Object? p) {}
}
''');
  }

  void test_namedArgument_any() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(p: any));
}
class C extends Mock {
  Null m({Object? p}) => null;
}
''',
      [lint(68, 3, name: 'arg_matcher_must_be_named')],
    );
  }

  void test_namedArgument_anyNamedWithWrongNamed() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(p: anyNamed('q')));
}
class C extends Mock {
  Null m({Object? p}) => null;
}
''',
      [lint(68, 13, name: 'arg_matcher_has_wrong_name')],
    );
  }

  void test_namedArgument_argThatWithoutNamed() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(p: argThat(1)));
}
class C extends Mock {
  Null m({Object? p}) => null;
}
''',
      [lint(68, 10, name: 'arg_matcher_missing_named_arg')],
    );
  }

  void test_namedArgument_argThatWithWrongNamed() async {
    await assertDiagnostics(
      r'''
import 'package:mockito/src/mock.dart';
void f(C c) {
  when(c.m(p: argThat(1, named: 'q')));
}
class C extends Mock {
  Null m({Object? p}) => null;
}
''',
      [lint(68, 22, name: 'arg_matcher_has_wrong_name')],
    );
  }
}
