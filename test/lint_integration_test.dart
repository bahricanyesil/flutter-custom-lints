// ignore_for_file: invalid_use_of_internal_member

import 'dart:developer';
import 'dart:io';

import 'package:analyzer/error/error.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_custom_lints/flutter_custom_lints.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  // Load all Dart files from test_data
  final List<File> files = getFiles();

  // Map of expected error counts: {fileName: {lintName: expectedCount}}
  final Map<String, Map<String, int>> expectedErrorCounts =
      <String, Map<String, int>>{
        'should_fail_as_type_assertion.dart': <String, int>{
          'no_as_type_assertion': 1,
        },
        'should_pass_as_type_assertion.dart': <String, int>{
          'no_as_type_assertion': 0,
        },
        'should_fail_direct_iterable_access.dart': <String, int>{
          'no_direct_iterable_access': 6,
        },
        'should_pass_direct_iterable_access.dart': <String, int>{
          'no_direct_iterable_access': 0,
        },
        'should_fail_compare_without_case.dart': <String, int>{
          'use_compare_without_case': 4,
        },
        'should_pass_compare_without_case.dart': <String, int>{
          'use_compare_without_case': 0,
        },
      };

  group('AppLintsPlugin integration', () {
    for (final File file in files) {
      test('run plugin on example project - file: ${file.path}', () async {
        final PluginBase plugin = createPlugin();
        final List<LintRule> lints = plugin.getLintRules(
          CustomLintConfigs.empty,
        );

        for (final LintRule lint in lints) {
          final List<AnalysisError> errors = await (lint as DartLintRule)
              .testAnalyzeAndRun(file);
          final String fileName = p.basename(file.path);
          final String lintName = lint.code.name;
          final int? expected = expectedErrorCounts[fileName]?[lintName];
          if (expected != null) {
            expect(
              errors.length,
              expected,
              reason:
                  '''Expected $expected errors, found ${errors.length} for $lintName on $fileName. Errors: $errors''',
            );
            log(
              '''Expected $expected errors, found ${errors.length} for $lintName on $fileName. Errors: $errors''',
            );
          } else {
            // If not specified, just print for manual inspection
            log('No expected error count for $lintName on $fileName');
            log('Found ${errors.length} errors: $errors');
          }
        }
      });
    }
  });
}

List<File> getFiles() {
  final Directory dir = Directory(p.join(Directory.current.path, 'test_data'));
  if (!dir.existsSync()) return <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();
}
