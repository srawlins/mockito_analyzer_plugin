import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/mockito_args.dart';

final plugin = MockitoPackagePlugin();

class MockitoPackagePlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(MockitoArgs());
    // TODO(srawlins): `when` on a non-mock.
    // TODO(srawlins): `when` without a stub result, https://github.com/dart-lang/mockito/issues/184
    // TODO(srawlins): when stubbing Future- or Stream-returning type, use `thenAnswer(() async)`
    // TODO(srawlins): `verify(...).called(0)` does not work. https://github.com/dart-lang/mockito/issues/185
    // TODO(srawlins): Proper names: https://github.com/dart-lang/mockito/issues/183
  }
}
