import 'dart:typed_data';

import 'package:currency_converter/stack/failure.dart';
import 'package:currency_converter/stack/result.dart';
import 'package:dio/dio.dart';

enum ApiContentType { json, text }

enum ApiMethod { get, post, put, patch, delete, download }

enum ApiResponseType { json, text, bytes }

enum ApiErrorType {
  connectionTimeout,
  requestTimeout,
  responseTimeout,
  connectionError,
  networkUnavailable,
  invalidResponse,
  operationCanceled,
  badRequest,
  badCertificate,
  unauthorized,
  forbidden,
  notFound,
  methodNotAllowed,
  notAcceptable,
  conflict,
  preconditionFailed,
  serverError,
  unspecified,
}

class ApiResult<TValue extends Object> extends Result<TValue, ApiError> {
  const ApiResult.success({super.value}) : super.internal();

  const ApiResult.failure(ApiError error) : super.internal(error: error);
}

class ApiSetupParams {
  ApiSetupParams({
    required this.baseUrl,
    this.baseHeaders,
    this.baseQueryParams,
    this.connectTimeout,
    this.requestTimeout,
    this.responseTimeout,
    this.retryCount,
    this.retryDelays,
  });

  /// Base request url.
  /// It can contain sub paths like: "https://www.google.com/api/".
  final String baseUrl;

  /// Base headers to define for all the calls.
  final Map<String, dynamic>? baseHeaders;

  /// Base query parameters.
  final Map<String, dynamic>? baseQueryParams;

  /// Timeout for opening url.
  final Duration? connectTimeout;

  /// Timeout for sending data.
  final Duration? requestTimeout;

  /// Timeout for receiving data.
  final Duration? responseTimeout;

  /// The number of retries in case of an error.
  final int? retryCount;

  /// The delays between retries. Empty [retryDelays] means no delay.
  ///
  /// If [retryCount] is bigger than [retryDelays] count,
  /// the last element value of [retryDelays] will be used.
  final List<Duration>? retryDelays;
}

class ApiCancelToken {
  CancelToken _token = CancelToken();

  /// Internal token. Obscured because it's only used in ApiManager.
  dynamic get token => _token;

  /// Cancel apis which this token is provided to.
  void cancel() => _token.cancel();

  /// Refresh the current cancel token.
  /// Should be used when cancellation is completed.
  void refresh() => _token = CancelToken();
}

class ApiCall<TOutput extends Object> {
  ApiCall({
    required this.method,
    required this.path,
    this.contentType = ApiContentType.json,
    this.responseType = ApiResponseType.json,
    this.responseMapper,
    this.queryParams,
    this.body,
    this.downloadFileName,
    this.ignoreBaseUrl,
    this.ignoreBadCertificate,
    this.canLogContent = true,
  }) {
    _assertGetMethod();
    _assertDownloadMethod();
    _assertResponses();
  }

  /// Api method.
  final ApiMethod method;

  /// Api path. It can also be an endpoint if base url is provided.
  final String path;

  /// Specified api request content type. Defaults to [ApiContentType.json].
  final ApiContentType contentType;

  /// Expected api response type. Defaults to [ApiResponseType.json].
  final ApiResponseType responseType;

  /// Mapper to deserialize response JSON map.
  final TOutput Function(dynamic response)? responseMapper;

  /// Additional query parameters.
  final Map<String, dynamic>? queryParams;

  /// Request body to send.
  final dynamic body;

  /// Optional name of the file to be downloaded.
  final String? downloadFileName;

  /// Ignore base url to be able to use full path only.
  final bool? ignoreBaseUrl;

  /// Whether ignore bad certificate or not.
  final bool? ignoreBadCertificate;

  /// Whether request/response contents can be logged or not. Defaults to true.
  final bool canLogContent;

  // Helpers
  void _assertGetMethod() {
    if (method == ApiMethod.get) {
      assert(body == null, 'Get APIs cannot have a body to send!');
    }
  }

  void _assertDownloadMethod() {
    if (method == ApiMethod.download) {
      assert(
        body == null && responseMapper == null,
        'Download APIs cannot have a body and a response mapper!',
      );
    } else {
      assert(
        downloadFileName == null,
        'File name can only be provided for download APIs!',
      );
    }
  }

  void _assertResponses() {
    if (responseType == ApiResponseType.json && method == ApiMethod.get) {
      _assertJsonResponse();
    } else if (responseType == ApiResponseType.text) {
      _assertTextResponse();
    } else if (responseType == ApiResponseType.bytes) {
      _assertBytesResponse();
    }
  }

  void _assertJsonResponse() {
    assert(
      responseMapper != null,
      '''
Get APIs must have a response mapper provided if JSON is expected as a response!''',
    );
  }

  void _assertTextResponse() {
    assert(
      TOutput == String,
      'Output type should be String if text is expected as a response!',
    );
    assert(
      responseMapper == null,
      'Response mapper cannot be set if text is expected as a response!',
    );
  }

  void _assertBytesResponse() {
    assert(
      TOutput == Uint8List,
      'Output type should be Uint8List if bytes is expected as a response!',
    );
    assert(
      responseMapper == null,
      'Response mapper cannot be set if bytes is expected as a response!',
    );
  }
  // - Helpers
}

class ApiError extends Failure {
  const ApiError._internal({
    required this.errorType,
    required super.message,
  });

  /// Api error type generated out of api failures.
  final ApiErrorType errorType;

  factory ApiError.fromException(Exception e) {
    return ApiError._internal(
      errorType: _getErrorType(e),
      message: _getErrorMessage(e),
    );
  }

  @override
  String toString() => message;

  // Helpers
  static ApiErrorType _getErrorType(Exception ex) {
    if (ex is DioException) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        return ApiErrorType.connectionTimeout;
      } else if (ex.type == DioExceptionType.sendTimeout) {
        return ApiErrorType.requestTimeout;
      } else if (ex.type == DioExceptionType.receiveTimeout) {
        return ApiErrorType.responseTimeout;
      } else if (ex.type == DioExceptionType.connectionError) {
        return ApiErrorType.connectionError;
      } else if (ex.type == DioExceptionType.cancel) {
        return ApiErrorType.operationCanceled;
      } else if (ex.type == DioExceptionType.badCertificate) {
        return ApiErrorType.badCertificate;
      } else if (ex.type == DioExceptionType.badResponse) {
        return _getErrorTypeFromResponse(ex.response!);
      }
    } else if (ex is NetworkUnavailableException) {
      return ApiErrorType.networkUnavailable;
    } else if (ex is InvalidResponseException) {
      return ApiErrorType.invalidResponse;
    }
    return ApiErrorType.unspecified;
  }

  static String _getErrorMessage(Exception ex) {
    var msg = '';
    if (ex is DioException) {
      msg += _getErrorStringFromType(ex.type);

      if (ex.response?.statusMessage != null) {
        msg += '${ex.response?.statusMessage} - ';
      }
      if (ex.message != null) msg += ex.message!;

      if (ex.response?.data is Map<String, dynamic>?) {
        final responseData = ex.response?.data as Map<String, dynamic>?;
        if (responseData != null &&
            responseData.containsKey('status_message')) {
          msg += '\n${responseData['status_message']}';
        }
      }
    } else {
      msg = ex.toString();
    }
    return msg;
  }

  static ApiErrorType _getErrorTypeFromResponse(Response<dynamic> response) {
    final statusCode = response.statusCode;
    if (statusCode == null) return ApiErrorType.unspecified;
    // Map client & server error responses.
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          return ApiErrorType.badRequest;
        case 401:
          return ApiErrorType.unauthorized;
        case 403:
          return ApiErrorType.forbidden;
        case 404:
          return ApiErrorType.notFound;
        case 405:
          return ApiErrorType.methodNotAllowed;
        case 406:
          return ApiErrorType.notAcceptable;
        case 408:
          return ApiErrorType.requestTimeout;
        case 409:
          return ApiErrorType.conflict;
        case 412:
          return ApiErrorType.preconditionFailed;
      }
    } else if (statusCode >= 500 && statusCode < 600) {
      return ApiErrorType.serverError;
    }
    return ApiErrorType.unspecified;
  }

  static String _getErrorStringFromType(DioExceptionType errorType) {
    switch (errorType) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out.\n';
      case DioExceptionType.sendTimeout:
        return 'Request timed out.\n';
      case DioExceptionType.receiveTimeout:
        return 'Response timed out.\n';
      case DioExceptionType.connectionError:
        return 'Connection error occurred.\n';
      case DioExceptionType.cancel:
        return 'Operation canceled.\n';
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
        return 'Request completed with a status error.\n';
      case DioExceptionType.unknown:
        return 'Unexpected error occurred.\n';
    }
  }
  // - Helpers
}

class NetworkUnavailableException implements Exception {
  @override
  String toString() => 'Network connection is unavailable.';
}

class InvalidResponseException implements Exception {
  @override
  String toString() => 'Response is not in expected format.';
}
