/// Functions which imitate the path_to_regexp package
/// (https://pub.dev/packages/path_to_regexp) by which
/// the following is heavily inspired
///
///
/// The reason we implement this rather than depending on path_to_regexp
/// in to enable wildcards (*), which path_to_regexp does not

/// The pattern as defined by VRouter
final _inputPattern = /* :anything or :* */ RegExp(r':(\w+|\*(?=\())'
    /* RegExp in (), optional */ r'(\((?:\\.|[^\\()])+\))?');

/// The real regexp to replace a path parameter which does not specify
/// its path parameter
final _defaultOutputPattern = r'([^/]+?)'; // everything except "/"

/// [pathParameters] will be populated with the path parameters
/// of the given [path]
RegExp pathToRegExp(
  String path,
  List<String> pathParameters,
) {
  final matches = _inputPattern.allMatches(path);

  // A list of the names of the path parameters
  pathParameters.clear();
  pathParameters.addAll([for (var match in matches) match.group(1)!]);

  var newPath = StringBuffer(r'^');
  RegExpMatch? previousMatch;
  for (var match in matches) {
    newPath.write(
      RegExp.escape(
        path.substring(previousMatch?.end ?? 0, match.start),
      ),
    );
    final regExpPattern = match.group(2);
    newPath.write(regExpPattern != null
        ? escapeGroup(regExpPattern)
        : _defaultOutputPattern);
    previousMatch = match;
  }
  newPath.write(path.substring(previousMatch?.end ?? 0));
  if (previousMatch != null && !previousMatch.toString().endsWith('/')) {
    // Match until a delimiter or end of input, unless
    //  (a) there are no tokens (matching the empty string), or
    //  (b) the last token itself ends in a delimiter
    // in which case, anything may follow.
    newPath.write(r'(?=/|$)');
  }

  return RegExp(newPath.toString());
}

/// Extract the [parameters] from the [match]
///
/// [parameters] can be obtained in place using [pathToRegExp]
Map<String, String> extract(List<String> parameters, Match match) => {
      for (var i = 0; i < parameters.length; ++i)
        parameters[i]: match.group(i + 1)!,
      // Offset by 1 since 0 is the entire match
    };

/// Replaces the path parameters of the [path] with the given ones
String replacePathParameters(String path, Map<String, String> pathParameters) {
  final matches = _inputPattern.allMatches(path);

  var newPath = StringBuffer(r'');
  RegExpMatch? previousMatch;
  for (var match in matches) {
    newPath.write(path.substring(previousMatch?.end ?? 0, match.start));

    final pathParametersValue = pathParameters[match.group(1)];
    assert(
      pathParametersValue != null,
      'Expected path parameter "${match.group(1)}" but it was not given',
    );
    newPath.write(pathParameters[match.group(1)]);
    previousMatch = match;
  }
  newPath.write(path.substring(previousMatch?.end ?? 0));

  return newPath.toString();
}

/// Replaces wildcards by value that are understood by [pathToRegExp]
String replaceWildcards(String path) {
  // A wildcard contained in the path
  final inPathWildcardRegexp = RegExp(r'\*(?![^\(]*\))(?=.)');

  // A wildcard contained at the end of the path
  final trailingWildcardRegexp = RegExp(r'\*(?![^\(]*\))$');

  return path
      .replaceAll(inPathWildcardRegexp, r':*([^\/]*)')
      .replaceAll(trailingWildcardRegexp, r':*(.*)');
}

/// Matches any characters that could prevent a group from capturing.
final _groupRegExp = RegExp(r'[:=!]');

/// Escapes a single character [match].
String _escape(Match match) => '\\${match[0]}';

/// Escapes a [group] to ensure it remains a capturing group.
///
/// This prevents turning the group into a non-capturing group `(?:...)`, a
/// lookahead `(?=...)`, or a negative lookahead `(?!...)`. Allowing these
/// patterns would break the assumption used to map parameter names to match
/// groups.
String escapeGroup(String group) =>
    group.replaceFirstMapped(_groupRegExp, _escape);
