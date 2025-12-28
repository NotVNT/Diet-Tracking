import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Runs Flutter tests with coverage in multiple shards and merges the resulting
/// lcov files into a single output.
///
/// Why: On some Windows environments, `flutter test --coverage` can lose the VM
/// service connection when the suite is large. Sharding keeps each run smaller
/// and more reliable.
///
/// Usage:
///   dart run tool/coverage_sharded.dart
///   dart run tool/coverage_sharded.dart --shards=8
///   dart run tool/coverage_sharded.dart --out=coverage/lcov.info
///
/// Notes:
/// - Requires `flutter` on PATH.
/// - Merges only SF/DA/LF/LH records (the format Flutter emits by default).
Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final shards = options.shards;

  final testFiles = await _discoverTestFiles(Directory('test'));
  if (testFiles.isEmpty) {
    stderr.writeln('No test files found under ./test');
    exitCode = 1;
    return;
  }

  final tmpDir = Directory(options.tmpDir);
  if (!tmpDir.existsSync()) {
    tmpDir.createSync(recursive: true);
  }

  // Clean previous shard outputs.
  for (final entity in tmpDir.listSync()) {
    if (entity is File && entity.path.toLowerCase().endsWith('.info')) {
      entity.deleteSync();
    }
  }

  final initialBatches = _splitIntoShards(testFiles, shards);
  stdout.writeln(
    'Found ${testFiles.length} test files; starting with ${initialBatches.length} batches (will auto-split on VM service coverage failures)...',
  );

  var fileCounter = 0;
  final producedCoverageFiles = <File>[];

  for (var i = 0; i < initialBatches.length; i++) {
    final batch = initialBatches[i];
    stdout.writeln(
      '\n=== Coverage batch ${i + 1}/${initialBatches.length} (${batch.length} files) ===',
    );
    final files = await _runCoverageWithAutoSplit(
      options: options,
      tmpDir: tmpDir,
      testFiles: batch,
      fileCounter: () => ++fileCounter,
    );
    producedCoverageFiles.addAll(files);
  }

  producedCoverageFiles.sort((a, b) => a.path.compareTo(b.path));

  stdout.writeln('\nMerging ${producedCoverageFiles.length} lcov files...');

  final merged = _mergeLcovFiles(producedCoverageFiles);

  final outFile = File(options.outPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(merged);

  stdout.writeln('Wrote merged coverage to ${options.outPath}');
}

Future<List<File>> _runCoverageWithAutoSplit({
  required _Options options,
  required Directory tmpDir,
  required List<String> testFiles,
  required int Function() fileCounter,
  int depth = 0,
}) async {
  final outPath = _joinPaths(options.tmpDir, 'lcov_part_${fileCounter()}.info');

  final flutterArgs = <String>[
    'test',
    '--coverage',
    '--coverage-path=$outPath',
    ...testFiles,
  ];

  final result = await _runProcessCapture(
    executable: options.flutterExecutable,
    arguments: flutterArgs,
  );

  if (result.exitCode == 0) {
    final outFile = File(outPath);
    if (!outFile.existsSync() || outFile.lengthSync() == 0) {
      throw StateError('Coverage run succeeded but produced empty file: $outPath');
    }
    return <File>[outFile];
  }

  // If this is the known flaky coverage-collector failure, split and retry.
  if (_looksLikeVmServiceCoverageFailure(result.combinedOutput) && testFiles.length > 1) {
    final mid = (testFiles.length / 2).ceil();
    final left = testFiles.sublist(0, mid);
    final right = testFiles.sublist(mid);

    stdout.writeln(
      'Coverage failed due to VM service/coverage collector; splitting batch into ${left.length}+${right.length} and retrying...',
    );

    final leftFiles = await _runCoverageWithAutoSplit(
      options: options,
      tmpDir: tmpDir,
      testFiles: left,
      fileCounter: fileCounter,
      depth: depth + 1,
    );
    final rightFiles = await _runCoverageWithAutoSplit(
      options: options,
      tmpDir: tmpDir,
      testFiles: right,
      fileCounter: fileCounter,
      depth: depth + 1,
    );
    return <File>[...leftFiles, ...rightFiles];
  }

  throw StateError(
    'Coverage run failed (exitCode=${result.exitCode}) for ${testFiles.length} files.\n'
    'First file: ${testFiles.first}\n'
    'Last file: ${testFiles.last}',
  );
}

bool _looksLikeVmServiceCoverageFailure(String output) {
  return output.contains('getSourceReport') &&
      (output.contains('Service has disappeared') ||
          output.contains('Service connection disposed') ||
          output.contains('Service has been disposed'));
}

class _RunResult {
  final int exitCode;
  final String combinedOutput;

  const _RunResult({required this.exitCode, required this.combinedOutput});
}

class _Options {
  final int shards;
  final String outPath;
  final String tmpDir;
  final String flutterExecutable;

  const _Options({
    required this.shards,
    required this.outPath,
    required this.tmpDir,
    required this.flutterExecutable,
  });
}

_Options _parseArgs(List<String> args) {
  int shards = 8;
  String outPath = _joinPaths('coverage', 'lcov.info');
  String tmpDir = _joinPaths('coverage', 'partials');
  String flutterExecutable = 'flutter';

  for (final arg in args) {
    if (arg.startsWith('--shards=')) {
      shards = int.tryParse(arg.substring('--shards='.length)) ?? shards;
    } else if (arg.startsWith('--out=')) {
      outPath = arg.substring('--out='.length);
    } else if (arg.startsWith('--tmp=')) {
      tmpDir = arg.substring('--tmp='.length);
    } else if (arg.startsWith('--flutter=')) {
      flutterExecutable = arg.substring('--flutter='.length);
    }
  }

  if (shards < 1) shards = 1;
  return _Options(
    shards: shards,
    outPath: outPath,
    tmpDir: tmpDir,
    flutterExecutable: flutterExecutable,
  );
}

Future<List<String>> _discoverTestFiles(Directory root) async {
  if (!root.existsSync()) return <String>[];

  final results = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!path.endsWith('_test.dart')) continue;

    // Keep paths relative to project root for nicer command lines.
    results.add(_toPosixRelative(path));
  }

  results.sort();
  return results;
}

List<List<String>> _splitIntoShards(List<String> items, int shards) {
  if (items.isEmpty) return <List<String>>[];
  if (shards <= 1) return <List<String>>[List<String>.from(items)];

  final shardLists = List.generate(shards, (_) => <String>[]);
  for (var i = 0; i < items.length; i++) {
    shardLists[i % shards].add(items[i]);
  }

  // Drop empty shards (when shards > items).
  return shardLists.where((s) => s.isNotEmpty).toList(growable: false);
}

Future<_RunResult> _runProcessCapture({
  required String executable,
  required List<String> arguments,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    runInShell: true,
    mode: ProcessStartMode.normal,
  );

  final buffer = StringBuffer();

  Future<void> pipe(Stream<List<int>> stream, IOSink sink) async {
    await for (final chunk in stream) {
      final text = utf8.decode(chunk, allowMalformed: true);
      buffer.write(text);
      sink.write(text);
    }
  }

  final outFuture = pipe(process.stdout, stdout);
  final errFuture = pipe(process.stderr, stderr);

  final code = await process.exitCode;
  await Future.wait(<Future<void>>[outFuture, errFuture]);

  return _RunResult(exitCode: code, combinedOutput: buffer.toString());
}

String _mergeLcovFiles(List<File> files) {
  // Map: SF -> Map(line -> hits)
  final merged = <String, Map<int, int>>{};

  for (final file in files) {
    final lines = const LineSplitter().convert(file.readAsStringSync());

    String? currentSf;
    for (final line in lines) {
      if (line.startsWith('SF:')) {
        currentSf = line.substring(3);
        merged.putIfAbsent(currentSf, () => <int, int>{});
      } else if (line.startsWith('DA:')) {
        if (currentSf == null) continue;
        final rest = line.substring(3);
        final parts = rest.split(',');
        if (parts.length < 2) continue;
        final lineNo = int.tryParse(parts[0]);
        final hits = int.tryParse(parts[1]);
        if (lineNo == null || hits == null) continue;

        final map = merged[currentSf]!;
        map[lineNo] = (map[lineNo] ?? 0) + hits;
      } else if (line == 'end_of_record') {
        currentSf = null;
      }
    }
  }

  final buffer = StringBuffer();
  final sfs = merged.keys.toList()..sort();

  for (final sf in sfs) {
    final da = merged[sf]!;
    final lineNos = da.keys.toList()..sort();
    buffer.writeln('SF:$sf');

    var lh = 0;
    for (final ln in lineNos) {
      final hits = da[ln] ?? 0;
      if (hits > 0) lh++;
      buffer.writeln('DA:$ln,$hits');
    }

    buffer.writeln('LF:${lineNos.length}');
    buffer.writeln('LH:$lh');
    buffer.writeln('end_of_record');
  }

  return buffer.toString();
}

String _toPosixRelative(String path) {
  final current = Directory.current.path;
  var relative = path;
  if (path.startsWith(current)) {
    relative = path.substring(current.length);
    if (relative.startsWith(Platform.pathSeparator)) {
      relative = relative.substring(1);
    }
  }
  return relative.replaceAll('\\', '/');
}

String _joinPaths(String a, String b) {
  if (a.isEmpty) return b;
  if (b.isEmpty) return a;
  if (a.endsWith(Platform.pathSeparator)) return '$a$b';
  return '$a${Platform.pathSeparator}$b';
}
