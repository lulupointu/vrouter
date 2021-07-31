import 'package:flutter_test/flutter_test.dart';
import 'package:vrouter/src/path_to_regexp/path_to_regexp.dart';

void main() {
  group(
    'With inPath * AND trailing *',
    () {
      group(
        'Valid paths',
        () {
          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/2/value/ok/again',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/some/random/2/value/ok/again';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues, {'namedId': '2', '*': 'again'});
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/2/value/ok/again/something',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/some/random/2/value/ok/again/something';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues,
                  {'namedId': '2', '*': 'again/something'});
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/2/value/ok/',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/some/random/2/value/ok/';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues, {'namedId': '2', '*': ''});
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/2/value/ok/again',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/some/random/2//ok/again';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues, {'namedId': '2', '*': 'again'});
            },
          );
        },
      );

      group(
        'Invalid path',
        () {
          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /fdskjf',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/fdskjf';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);

              // assert
              expect(encodedBluePrint.hasMatch(path), false);
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/a/value/ok/again/something',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path =
                  '/some/random/a/value/ok/again/something'; // not digit
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);

              // assert
              expect(encodedBluePrint.hasMatch(path), false);
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/a/value/ok/again/something',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path =
                  '/some/random/2/ok/again/something'; // Missing first *
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);

              // assert
              expect(encodedBluePrint.hasMatch(path), false);
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok/* | path: /some/random/2/value/ok',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok/*';
              final path = '/some/random/2/value/ok'; // Missing last *
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);

              // assert
              expect(encodedBluePrint.hasMatch(path), false);
            },
          );
        },
      );
    },
  );

  group(
    'With inPath * and NOT trailing *',
    () {
      group(
        'Valid paths',
        () {
          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok | path: /some/random/2/value/ok',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok';
              final path = '/some/random/2/value/ok';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues, {'namedId': '2', '*': 'value'});
            },
          );

          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok | path: /some/random/2//ok',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok';
              final path = '/some/random/2//ok';
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);
              final pathParametersValues = extract(
                  pathParameters, encodedBluePrint.matchAsPrefix(path)!);

              // assert
              expect(encodedBluePrint.hasMatch(path), true);
              expect(pathParametersValues, {'namedId': '2', '*': ''});
            },
          );
        },
      );

      group(
        'Invalid path',
        () {
          test(
            r'Blueprint: /some/random/:namedId(\d*)/*/ok | path: /some/random/2/value/test/ok',
            () async {
              // arrange
              final bluePrint = r'/some/random/:namedId(\d*)/*/ok';
              final path =
                  '/some/random/2/value/test/ok'; // In path * should only path between //
              final List<String> pathParameters = [];

              // act
              final encodedBluePrint =
                  pathToRegExp(replaceWildcards(bluePrint), pathParameters);

              // assert
              expect(encodedBluePrint.hasMatch(path), false);
            },
          );
        },
      );
    },
  );

  group(
    'replacePathParameters',
    () {
      test(
        'replacePathParameters with trailing wildCard',
        () async {
          // arrange
          final path = '/some/random/:namedId(\d*)/*';
          final pathParameters = {
            'namedId': '12',
            '*': 'something',
          };

          // act
          final result =
              replacePathParameters(replaceWildcards(path), pathParameters);

          // assert
          expect(result, '/some/random/12/something');
        },
      );

      test(
        'replacePathParameters with in path wildCard',
        () async {
          // arrange
          final path = '/some/random/:namedId(\d*)/*/value';
          final pathParameters = {
            'namedId': '12',
            '*': 'something',
          };

          // act
          final result =
              replacePathParameters(replaceWildcards(path), pathParameters);

          // assert
          expect(result, '/some/random/12/something/value');
        },
      );

      test(
        'replacePathParameters with trailing :name',
        () async {
          // arrange
          final path = '/some/random/:namedId(\d*)';
          final pathParameters = {
            'namedId': '12',
          };

          // act
          final result =
              replacePathParameters(replaceWildcards(path), pathParameters);

          // assert
          expect(result, '/some/random/12');
        },
      );

      test(
        'AssertionError when missing path parameters',
        () async {
          // arrange
          final path = '/some/random/:namedId(\d*)';
          final pathParameters = <String, String>{};

          // act

          // assert
          expect(
            () => replacePathParameters(replaceWildcards(path), pathParameters),
            throwsA(isA<AssertionError>()),
          );
        },
      );
    },
  );
}
