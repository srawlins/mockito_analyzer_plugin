# mockito_analyzer_plugin

This package is an analyzer plugin that provides additional static analysis for
usage of the mockito package.

I should add quick fixes to this plugin, but for now, there are just warnings
for:

* when an arg matcher (`any`, `anyNamed`, `argThat`, `captureAny`,
  `captureAnyNamed`, `captureArgThat`) is used outside of creating a stub
  response
* when a named arg matcher is used as an argument for a positional parameter
* when an unnamed arg matcher is used as an argument for a named parameter
* when a named arg matcher is used as an argument for a named parameter with a
  different name
* when a call to `when` is given a stub call on a _non_ Mock instance
* when a call to `when` is not followed by a stub (`thenReturn`,
  `thenReturnInOrder`, `thenThrow`, or `thenAnswer`)
* when a call to `verify` is followed by `.called(0)`
