import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_missing_stub.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_verify_called_zero.dart';
import 'package:mockito_analyzer_plugin/src/rules/mockito_when.dart';

import 'src/rules/mockito_args.dart';

final plugin = MockitoPackagePlugin();

class MockitoPackagePlugin extends Plugin {
  @override
  String get name => 'mockito_plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(MockitoArgs());
    registry.registerWarningRule(MockitoMissingStub());
    registry.registerWarningRule(MockitoVerifyCalledZero());
    registry.registerWarningRule(MockitoWhen());
    // TODO(srawlins): when stubbing Future- or Stream-returning type, use `thenAnswer(() async)`
    // TODO(srawlins): `verify(...).called(0)` does not work. https://github.com/dart-lang/mockito/issues/185
    // TODO(srawlins): Proper names: https://github.com/dart-lang/mockito/issues/183
  }
}
