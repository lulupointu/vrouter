library vrouter;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:simple_url_handler/simple_url_handler.dart';
import 'package:url_strategy/url_strategy.dart';
// import 'move_to_background.dart';
import 'fake_web_helpers.dart' if (dart.library.js) 'web_helpers.dart';
import 'dart:io' if (dart.library.js) 'dart:html';


part 'exceptions.dart';
part 'route_element_widget.dart';
part 'navigation_2_wrappers.dart';
part 'navigation_guard.dart';
part 'page.dart';
part 'route.dart';
part 'route_element.dart';
part 'router.dart';

var logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);