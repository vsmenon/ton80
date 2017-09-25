// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as path;
import 'package:quiver/strings.dart' as strings;
import 'package:args/args.dart' as args;
import 'dart:math' as math;
import 'dart:html' as html;

import 'package:ton80/src/common/dart/BenchmarkBase.dart';
import 'package:ton80/src/DeltaBlue/dart/DeltaBlue.dart' as DeltaBlue;
import 'package:ton80/src/Richards/dart/Richards.dart' as Richards;
import 'package:ton80/src/FluidMotion/dart/FluidMotion.dart' as FluidMotion;
import 'package:ton80/src/Tracer/dart/Tracer.dart' as Tracer;
import 'package:ton80/src/Havlak/dart/Havlak.dart' as Havlak;

final Runner runnerForDart = new DartRunner();
final Runner runnerForDirect = new DirectRunner();

final BENCHMARKS = {
  'DeltaBlue': () => new DeltaBlue.DeltaBlue(),
  'Richards': () => new Richards.Richards(),
  'FluidMotion': () => new FluidMotion.FluidMotion(),
  'Tracer': () => new Tracer.TracerBenchmark(),
  'Havlak': () => new Havlak.Havlak(),
};

final CATEGORIES = {
  'BASE' : {
    'RUNNERS': <Runner>[
        runnerForDirect,
    ],
    'BENCHMARKS': [
        'DeltaBlue',
        'Richards',
        'FluidMotion',
        'Tracer',
        'Havlak',
    ],
  },
};

String pathToJS;
String pathToDart;

void main(arguments) {
  var query = html.window.location.search;
  var filter = query != '' ? query.substring(1) : null;

  for (Map category in CATEGORIES.values) {
    for (String benchmark in category['BENCHMARKS']) {
      if (filter != null && filter != benchmark) continue;
      Iterable<Runner> enabled = category['RUNNERS'].where((e) => e.isEnabled);
      if (enabled.isEmpty) continue;
      print('Running $benchmark...');
      for (Runner runner in enabled) {
        runner.run(benchmark);
      }
    }
  }
}

abstract class Runner {
  bool get isEnabled => true;
  void run(String benchmark);
}

class DartRunner extends Runner {
  void run(String benchmark) {
    var generator = BENCHMARKS[benchmark];
    List<double> dart = extractScores(generator);
    print('  - Dart    : ${format(dart, "runs/sec")}');
  }
}

class DirectRunner extends DartRunner {
}

String format(List<double> scores, String metric) {
  double mean = computeMean(scores);
  double best = computeBest(scores);
  String score = strings.padLeft(best.toStringAsFixed(2), 8, ' ');
  if (scores.length == 1) {
    return "$score $metric";
  } else {
    final int n = scores.length;
    double standardDeviation = computeStandardDeviation(scores, mean);
    double standardError = standardDeviation / math.sqrt(n);
    double percent = (computeTDistribution(n) * standardError / mean) * 100;
    String error = percent.toStringAsFixed(1);
    return "$score $metric (${mean.toStringAsFixed(2)}±$error%)";
  }
}

double computeBest(List<double> scores) {
  double best = scores[0];
  for (int i = 1; i < scores.length; i++) {
    best = math.max(best, scores[i]);
  }
  return best;
}

double computeMean(List<double> scores) {
  double sum = 0.0;
  for (int i = 0; i < scores.length; i++) {
    sum += scores[i];
  }
  return sum / scores.length;
}

double computeStandardDeviation(List<double> scores, double mean) {
  double deltaSquaredSum = 0.0;
  for (int i = 0; i < scores.length; i++) {
    double delta = scores[i] - mean;
    deltaSquaredSum += delta * delta;
  }
  double variance = deltaSquaredSum / (scores.length - 1);
  return math.sqrt(variance);
}

double computeTDistribution(int n) {
  const List<double> TABLE = const [
      double.NAN, double.NAN, 12.71,
      4.30, 3.18, 2.78, 2.57, 2.45, 2.36, 2.31, 2.26, 2.23, 2.20, 2.18, 2.16,
      2.14, 2.13, 2.12, 2.11, 2.10, 2.09, 2.09, 2.08, 2.07, 2.07, 2.06, 2.06,
      2.06, 2.05, 2.05, 2.05, 2.04, 2.04, 2.04, 2.03, 2.03, 2.03, 2.03, 2.03,
      2.02, 2.02, 2.02, 2.02, 2.02, 2.02, 2.02, 2.01, 2.01, 2.01, 2.01, 2.01,
      2.01, 2.01, 2.01, 2.01, 2.00, 2.00, 2.00, 2.00, 2.00, 2.00, 2.00, 2.00,
      2.00, 2.00, 2.00, 2.00, 2.00, 2.00, 2.00, 1.99, 1.99, 1.99, 1.99, 1.99,
      1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99,
      1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99, 1.99 ];
  if (n >= 474) return 1.96;
  else if (n >= 160) return 1.97;
  else if (n >= TABLE.length) return 1.98;
  else return TABLE[n];
}

List<double> extractScores(BenchmarkBase Function() generator,
                           [int iterations = 10]) {
  List<double> scores = [];
  for (int i = 0; i < iterations; i++) {
    var benchmark = generator();
    var result = benchmark.measure();
    scores.add(1000000 / result);
  }
  return scores;
}

