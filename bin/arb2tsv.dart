import 'dart:convert';
import 'dart:io';
import 'package:arb_tsv/bundle.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  var outputDir = Directory.current.path;
  final parser = ArgParser();
  parser.addOption(
    'output-dir',
    abbr: 'o',
    defaultsTo: '.',
    help: 'Set output directory for generated tsv file.',
    valueHelp: 'output directory',
    callback: (path) {
      if (!Directory(path).existsSync()) {
        print('Cannot find path specified which [${path}].');
        print('Usage: arb2tsv [arb file path] [options]');
        print(parser.usage);
        exit(0);
      }

      outputDir = path;
    },
  );

  final result = parser.parse(arguments);
  final targetDirectory = Directory(result.rest.isEmpty ? '.' : result.rest.first);

  if (!targetDirectory.existsSync() && !targetDirectory.path.contains('.arb')) {
    print('Cannot find path specified which [$targetDirectory].');
    print('Usage: arb2tsv [arb file path] [options]');
    print(parser.usage);
    exit(0);
  }

  final arbFiles = <File>[];

  if (targetDirectory.path.contains('.arb')) {
    arbFiles.add(File(targetDirectory.path));
  } else {
    arbFiles.addAll(
      targetDirectory
          .listSync()
          .where((directory) => directory.path.contains('.arb'))
          .map((directory) => File(directory.path)),
    );
  }

  for (final arbFile in arbFiles) {
    final bundle = Bundle.fromFile(arbFile);
    final fileName = arbFile.path.split(r'\').last.split('.').first;
    final tsvFile = File(path.join(outputDir, '${fileName}.tsv'));
    tsvFile.writeAsStringSync(bundle.tsv);
  }
}
