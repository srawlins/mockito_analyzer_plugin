import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension InterfaceTypeExtension on InterfaceType {
  bool get extendsMock {
    if (element.name == 'Mock' && element.isDeclaredInMockito) {
      return true;
    }

    if (element.isSynthetic) return false;

    return element.allSupertypes.any(
      (i) => i.element.name == 'Mock' && i.element.isDeclaredInMockito,
    );
  }
}

extension ExpressionExtension on Expression {
  bool get isWhen {
    var self = this;
    return self is SimpleIdentifier &&
        self.name == 'when' &&
        self.element.isDeclaredInMockito;
  }
}

extension SimpleIdentifierExtension on SimpleIdentifier {
  bool get isAny => name == 'any' && element.isDeclaredInMockito;

  bool get isAnyNamed => name == 'anyNamed' && element.isDeclaredInMockito;

  bool get isArgThat => name == 'argThat' && element.isDeclaredInMockito;

  bool get isCaptureAny => name == 'captureAny' && element.isDeclaredInMockito;

  bool get isCaptureAnyNamed =>
      name == 'captureAnyNamed' && element.isDeclaredInMockito;

  bool get isCaptureThat =>
      name == 'captureThat' && element.isDeclaredInMockito;

  bool get isArgMatcher =>
      isAny ||
      isAnyNamed ||
      isArgThat ||
      isCaptureAny ||
      isCaptureAnyNamed ||
      isCaptureThat;
}

extension on Element? {
  bool get isDeclaredInMockito => this?.library?.uri == _mockLibrary;
}

final _mockLibrary = Uri.parse('package:mockito/src/mock.dart');
