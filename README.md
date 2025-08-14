# mockito_analyzer_plugin

This package is an analyzer plugin that provides additional static analysis for
usage of the mockito package.

This analyzer plugin provides the following additional analysis:

* Report a warning when an arg matcher is used outside of creating a stub
  response.
* Report a warning when a named arg matcher is used as an argument for a
  positional parameter.
* Report a warning when an unnamed arg matcher is used as an argument for a
  named parameter.
* Report a warning when a named arg matcher is used as an argument for a named
  parameter with a different name.
