// alhai_lints — custom_lint plugin entry point.
//
// Registers Alhai-specific lint rules. The plugin is discovered by
// `custom_lint` through the `createPlugin` top-level function below, which
// is the standard contract for `custom_lint_builder` plugins.
//
// Rules exported by this package:
//   * avoid_direct_material_widgets — warns when app code instantiates raw
//     Material widgets (ElevatedButton, Card, TextField, ...) instead of the
//     equivalent `alhai_design_system` / `alhai_shared_ui` wrapper.
//
// Adding more rules in the future is as simple as appending them to the list
// returned by `_AlhaiLintsPlugin.getLintRules`.

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/avoid_direct_material_widgets.dart';

/// Entry point invoked by the `custom_lint` runner.
PluginBase createPlugin() => _AlhaiLintsPlugin();

class _AlhaiLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => <LintRule>[
        const AvoidDirectMaterialWidgets(),
      ];
}
