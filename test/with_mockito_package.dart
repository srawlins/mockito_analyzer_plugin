import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_missing_stub.dart';

mixin WithMockitoPackage on AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(MockitoMissingStub());

    super.setUp();

    var mockitoPath = '/packages/mockito';
    newFile('$mockitoPath/lib/src/mock.dart', '''
class Mock {}
Expectation get when => (_) {}
Null get any => null;
Null anyNamed(String named) => null;
Null argThat(Object? matcher, {String? named}) => null;

typedef Expectation = PostExpectation<T> Function<T>(T x);
typedef Answering<T> = T Function(Invocation realInvocation);
class PostExpectation<T> {
  void thenReturn(T expected) {}
  void thenReturnInOrder(List<T> expects) {}
  void thenThrow(Object throwable) {}
  void thenAnswer(Answering<T> answer) {}
}

typedef Verification = VerificationResult Function<T>(T matchingInvocations);
Verification get verify => _makeVerify(false);
class VerificationResult {
  void called(dynamic matcher) {}
}
''');
    writeTestPackageConfig(
      PackageConfigFileBuilder()
        ..add(name: 'mockito', rootPath: convertPath(mockitoPath)),
    );
  }
}
