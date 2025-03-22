import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

abstract class Logger {
  void debug(String message, {Type? callerType});

  void info(String message, {Type? callerType});

  void error(String message, {Type? callerType});

  void critical(String message, {Type? callerType});
}

class LoggerImpl implements Logger {
  @override
  void debug(String message, {Type? callerType}) {
    if (kDebugMode) {
      log(_buildMessageLine('[D]', message, callerType));
    }
  }

  @override
  void info(String message, {Type? callerType}) {
    if (kDebugMode) {
      log(_buildMessageLine('[I]', message, callerType));
    }
  }

  @override
  void error(String message, {Type? callerType}) {
    if (kDebugMode) {
      log(_buildMessageLine('[E]', message, callerType));
    }
  }

  @override
  void critical(String message, {Type? callerType}) {
    if (kDebugMode) {
      log(_buildMessageLine('[C]', message, callerType));
    }
  }

  // Helpers
  String _buildMessageLine(String prefix, String message, Type? callerType) {
    var callerTypeText = '';
    if (callerType != null) callerTypeText = ' [@$callerType]';
    return '[APP] $prefix [${_getDateTime()}]$callerTypeText $message';
  }

  String _getDateTime() {
    return DateFormat('dd.MM.yyyy HH:mm:ss:S').format(DateTime.now().toUtc());
  }
  // - Helpers
}
