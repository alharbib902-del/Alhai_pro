// avoid_direct_material_widgets
//
// Warns when app code constructs a raw Material widget that has an Alhai
// design-system wrapper. Detection is AST-based (`InstanceCreationExpression`)
// rather than regex, so it catches:
//
//   * `ElevatedButton(onPressed: ..., child: ...)`
//   * `const Card(child: Text('...'))`
//   * `Card.filled(child: ...)`            // named constructors
//   * `TextField(...)`  in arbitrary positions
//
// …without flagging the same identifiers appearing in strings, comments,
// variable names, or unrelated types with the same shortname.
//
// **Transitional severity**: WARNING, not ERROR. There are 832 existing
// violations across the monorepo at the time this rule was introduced; the
// rule exists to stop the bleeding while migration happens gradually.
//
// **Exemptions** (skipped by path):
//   * `packages/alhai_design_system/**`  — this *is* the wrapper layer.
//   * `packages/alhai_shared_ui/**`       — wraps the wrappers, needs raw access.
//   * `**/test/**`, `**/test_driver/**`   — tests may need to pump raw widgets.
//   * `**/*.generated.dart`, `**/*.g.dart`, `**/*.freezed.dart`
//   * anything under `.dart_tool/` or `build/`.
//
// To extend: add the (widgetName, suggestedReplacement) pair to
// `_bannedWidgets` below.

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidDirectMaterialWidgets extends DartLintRule {
  const AvoidDirectMaterialWidgets() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'avoid_direct_material_widgets',
    problemMessage:
        "Direct Material '{0}' use. Prefer {1} from alhai_design_system.",
    correctionMessage:
        'Replace the raw Material widget with the Alhai design-system wrapper '
        'so typography, spacing, colour, and RTL handling stay consistent.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// Map of banned Material widget short name -> suggested replacement.
  ///
  /// Short name is matched against the name written in source code. We also
  /// verify the resolved type lives in `package:flutter/src/material/` so
  /// that an unrelated user class called `Card` does not get flagged.
  static const Map<String, String> _bannedWidgets = <String, String>{
    'ElevatedButton': 'AlhaiButton (primary)',
    'TextButton': 'AlhaiButton (text variant)',
    'OutlinedButton': 'AlhaiButton (outlined variant)',
    'IconButton': 'AlhaiIconButton',
    'Card': 'AlhaiCard',
    'TextField': 'AlhaiTextField',
    'TextFormField': 'AlhaiTextField (form variant)',
    'AlertDialog': 'AlhaiDialog',
    'SnackBar': 'AlhaiSnackBar / AlhaiToast',
    'Chip': 'AlhaiChip',
    'ListTile': 'AlhaiListTile',
  };

  static final List<RegExp> _skipPathPatterns = <RegExp>[
    // Source wrappers — they are allowed to use raw Material.
    RegExp(r'[\\/]packages[\\/]alhai_design_system[\\/]'),
    RegExp(r'[\\/]alhai_design_system[\\/]'),
    RegExp(r'[\\/]packages[\\/]alhai_shared_ui[\\/]'),
    // Tests — often need to pump Material widgets directly.
    RegExp(r'[\\/]test[\\/]'),
    RegExp(r'[\\/]test_driver[\\/]'),
    RegExp(r'[\\/]integration_test[\\/]'),
    // Generated code.
    RegExp(r'\.g\.dart$'),
    RegExp(r'\.freezed\.dart$'),
    RegExp(r'\.generated\.dart$'),
    RegExp(r'[\\/]\.dart_tool[\\/]'),
    RegExp(r'[\\/]build[\\/]'),
  ];

  static bool _shouldSkipFile(String path) {
    for (final RegExp pattern in _skipPathPatterns) {
      if (pattern.hasMatch(path)) return true;
    }
    return false;
  }

  /// Returns true if [type] is declared in the Flutter Material library,
  /// i.e. comes from `package:flutter/src/material/...`. This prevents false
  /// positives on user-defined classes that happen to share a name.
  static bool _isFlutterMaterial(DartType? type) {
    if (type == null) return false;
    final Uri? uri = type.element3?.library2?.uri;
    if (uri == null) return false;
    final String uriString = uri.toString();
    return uriString.startsWith('package:flutter/src/material/') ||
        uriString == 'package:flutter/material.dart';
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final String filePath = resolver.path;
    if (_shouldSkipFile(filePath)) return;

    context.registry.addInstanceCreationExpression((node) {
      // Widget class written in source, e.g. `Card` or `Card.filled`.
      final String typeName = node.constructorName.type.name2.lexeme;

      final String? replacement = _bannedWidgets[typeName];
      if (replacement == null) return;

      // Confirm the constructor actually resolves to a Flutter Material
      // widget (not a same-named user class).
      if (!_isFlutterMaterial(node.staticType)) return;

      reporter.atNode(
        node.constructorName,
        _code,
        arguments: <Object>[typeName, replacement],
      );
    });
  }
}
