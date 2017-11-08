Ton 80
======

This is a slightly modified version of [the primary Ton80 repository](https://github.com/dart-lang/ton80)
modified to experiment with DDC.  DDC doesn't fit easily into the main Ton80 runner.
Instead, I've added a web entrypoint for DDC (which also makes it easy to use Chrome profiling tools).

It uses the new `package:build` to drive DDC.

Make sure the version of DDC / the SDK that you want to test is first on your path (e.g., your built `dart-sdk/bin` directory).

```
> pub get
> dart tool/build.dart
```

and navigate to:

- http://localhost:8080 to run all benchmarks, or
- http://localhost:8080?DeltaBlue to run a single one.

All output is on the JavaScript console.

Notes:
- Some of these benchmarks still have dynamic calls.  These should be converted to typed ones.
- DDC is not particular efficient on typed arrays.

The standard runner (see below) has also been modified to output checked mode run times.

## README from main repository....

Ton 80 is a benchmark suite for Dart.

In it's current setup, the Ton80 benchmark suite is easy to run and
profile from the command line. When adding new benchmarks to the suite, 
please use the existing harness and help us make sure we can continue to
easily run and profile from the command line.

You can run Ton80 using `bin/ton80.dart`. It has the following usage:<br>
```dart ton80.dart [OPTION]... [BENCHMARK]```

The following values are valid for ```[OPTION]```:<br>
```
--js: Path to JavaScript runner (this probably needs to be set)
--dart: Path to Dart runner
--wrk: Path to wrk benchmarking tool
```

## Contributing

We're happy to review Pull Requests that fix bugs in benchmark implementations.

We're intentionally keeping the list of benchmarks small. We especially want
to avoid micro-benchmarks. If you have a good idea for a benchmark, please
open a new issue first. Our team will respond to discuss the benchmark.

Before contributed code can be merged, the author must first sign the
[Google CLA](https://cla.developers.google.com/about/google-individual).

