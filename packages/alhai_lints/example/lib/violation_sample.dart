// Every constructor in this file should trigger
// `avoid_direct_material_widgets`.
//
// Expected lint output (WARNING severity), one per `expect_lint` comment:
//
//   violation_sample.dart:NN:NN  warning: Direct Material 'ElevatedButton' use. Prefer AlhaiButton (primary) from alhai_design_system.
//   violation_sample.dart:NN:NN  warning: Direct Material 'Card' use. Prefer AlhaiCard from alhai_design_system.
//   ... one per constructor below.

import 'package:flutter/material.dart';

class ViolationSample extends StatelessWidget {
  const ViolationSample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // expect_lint: avoid_direct_material_widgets
        ElevatedButton(onPressed: () {}, child: const Text('press')),
        // expect_lint: avoid_direct_material_widgets
        TextButton(onPressed: () {}, child: const Text('press')),
        // expect_lint: avoid_direct_material_widgets
        OutlinedButton(onPressed: () {}, child: const Text('press')),
        // expect_lint: avoid_direct_material_widgets
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        // expect_lint: avoid_direct_material_widgets
        const Card(child: Text('body')),
        // expect_lint: avoid_direct_material_widgets
        const TextField(),
        // expect_lint: avoid_direct_material_widgets
        TextFormField(initialValue: 'hi', onChanged: (_) {}),
        // expect_lint: avoid_direct_material_widgets
        const Chip(label: Text('label')),
        // expect_lint: avoid_direct_material_widgets
        const ListTile(title: Text('item')),
      ],
    );
  }
}

// `AlertDialog` and `SnackBar` are still InstanceCreationExpressions but
// live in argument positions rather than children lists.
Future<void> showExamples(BuildContext context) async {
  await showDialog<void>(
    context: context,
    // expect_lint: avoid_direct_material_widgets
    builder: (_) => const AlertDialog(title: Text('hello')),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    // expect_lint: avoid_direct_material_widgets
    const SnackBar(content: Text('hi')),
  );
}

// Compile-time negative control: a user-defined class with a name that
// is NOT in the banned list must not be flagged. (We cannot shadow `Card`
// in this same library because it would break the Material Card reference
// above — so we use a distinct name.)
class LocalStyledPanel {
  const LocalStyledPanel({this.title});
  final String? title;
}

LocalStyledPanel makeOwnPanel() => const LocalStyledPanel(title: 'mine');
