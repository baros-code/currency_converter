import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:currency_converter/core/api_manager_helpers.dart';
import 'package:currency_converter/core/logger.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:uuid/uuid.dart';

import 'connectivity_manager.dart';

/// An advanced http client to manage api operations such as get, post etc.
abstract class ApiManager {
  void setup(ApiSetupParams setupParams);

  void setBearerAuthToken(String? token);

  Future<ApiResult<TOutput>> call<TOutput extends Object>(
    ApiCall<TOutput> api, {
    ApiCancelToken? cancelToken,
  });

  /// Called when an API error occurres for any call.
  Stream<ApiError> get onApiError;
}

/// ApiManager Implementation
class ApiManagerImpl implements ApiManager {
  ApiManagerImpl(
    this._logger,
    this._connectivityManager,
  );

  final _defaultTimeout = const Duration(milliseconds: 10000);

  final Logger _logger;
  final ConnectivityManager _connectivityManager;

  late Dio _client;
  late HttpClientAdapter _initialHttpClientAdapter;
  late StreamController<ApiError> _onApiErrorController;

  @override
  void setup(ApiSetupParams setupParams) {
    // Initialize dio client.
    _client = Dio(
      BaseOptions(
        baseUrl: setupParams.baseUrl,
        headers: setupParams.baseHeaders,
        queryParameters: setupParams.baseQueryParams,
        connectTimeout: setupParams.connectTimeout ?? _defaultTimeout,
        sendTimeout: setupParams.requestTimeout ?? _defaultTimeout,
        receiveTimeout: setupParams.responseTimeout ?? _defaultTimeout,
      ),
    );
    // Add retry interceptor with the given retry count and delays.
    if (setupParams.retryCount != null) {
      _addRetryInterceptor(setupParams.retryCount!, setupParams.retryDelays);
    }
    // Save the initial HttpClientAdapter for a backup.
    _initialHttpClientAdapter = _client.httpClientAdapter;
    // Initialize onApiError stream controller.
    _onApiErrorController = StreamController.broadcast();
  }

  @override
  void setBearerAuthToken(String? token) {
    if (token != null) {
      _client.options.headers['authorization'] = 'Bearer $token';
    }
  }

  @override
  Future<ApiResult<TOutput>> call<TOutput extends Object>(
    ApiCall<TOutput> api, {
    ApiCancelToken? cancelToken,
  }) async {
    // Save old base url to revert at the end.
    final oldBaseUrl = _client.options.baseUrl;
    // Generate a uuid for logging purpose.
    final uuid = const Uuid().v4().toUpperCase();

    try {
      // Update dio client's properties as per needs.
      _updateClientByApiCallParams(api);
      // Log the api request.
      _logRequest(uuid, api, api.canLogContent);
      // Check network connectivity.
      await _checkInternetConnection();
      // Call the given api.
      final response = await _callApi(api, cancelToken);
      // Log the api response.
      _logResponse(uuid, response, api.canLogContent);
      // Return with success if response mapper is not provided
      // and the response is successful.
      if (api.responseMapper == null && _isSuccessful(response)) {
        if (TOutput == String || TOutput == Uint8List) {
          return ApiResult.success(value: response.data);
        }
        return ApiResult.success();
      }
      // Validate response data by the expected response type.
      _validateResponseData(response, api.responseType);
      // Return result after mapping with the given mapper.
      if (api.responseType == ApiResponseType.json) {
        return ApiResult.success(
          value: api.responseMapper!(response.data),
        );
      }
      return ApiResult.success(value: response.data);
    } on Exception catch (ex) {
      final apiError = _getApiError(ex, cancelToken, uuid);
      return ApiResult.failure(apiError);
    } finally {
      // Revert the old base url in case it's changed.
      _client.options.baseUrl = oldBaseUrl;
    }
  }

  @override
  Stream<ApiError> get onApiError => _onApiErrorController.stream;

  // Helpers
  void _updateClientByApiCallParams(ApiCall<dynamic> api) {
    // Ignore base url to use endpoint only if specified by the api.
    if (api.ignoreBaseUrl == true) _client.options.baseUrl = '';
    // Ignore bad certificate if specified.
    if (api.ignoreBadCertificate == true) {
      _ignoreBadCertificate();
    } else {
      // Revert ignore bad certificate.
      _client.httpClientAdapter = _initialHttpClientAdapter;
    }
  }

  Future<void> _checkInternetConnection() async {
    // Throw an exception if internet connection is not available.
    if (!(await _connectivityManager.hasConnection)) {
      throw NetworkUnavailableException();
    }
  }

  Future<Response<dynamic>> _callApi<TOutput extends Object>(
    ApiCall<TOutput> api,
    ApiCancelToken? cancelToken,
  ) {
    // Call the api with the generic request method.
    return _client.request(
      api.path,
      data: api.body,
      options: Options(
        // Parse http method from the method enum.
        method: api.method.name,
        // Set content type as per the configured content type.
        contentType: api.contentType == ApiContentType.json
            ? 'application/json'
            : 'charset=utf-8',
        // Set response type as per the configured response type.
        responseType: api.responseType == ApiResponseType.json
            ? ResponseType.json
            : api.responseType == ApiResponseType.bytes
                ? ResponseType.bytes
                : ResponseType.plain,
      ),
      queryParameters: api.queryParams,
      cancelToken: cancelToken?.token,
    );
  }

  void _logRequest(
    String uuid,
    ApiCall<dynamic> request,
    bool canLogContent,
  ) {
    final method = request.method.name.toUpperCase();
    _logger.debug(
      '[$uuid] Request: $method ${request.path}',
      callerType: runtimeType,
    );

    if (canLogContent &&
        (request.queryParams != null || request.body != null)) {
      // Log request params if provided.
      final encodedParams = jsonEncode(request.queryParams);
      if (request.queryParams != null && encodedParams.isNotEmpty) {
        _logger.debug(
          '[$uuid] RequestParams: $encodedParams',
          callerType: runtimeType,
        );
      }
      // Log request body if provided.
      final encodedBody =
          request.body is Map ? jsonEncode(request.body) : request.body;
      if ((encodedBody is String || encodedBody is List) &&
          encodedBody.isNotEmpty) {
        _logger.debug(
          '[$uuid] RequestBody: $encodedBody',
          callerType: runtimeType,
        );
      }
    }
  }

  void _logResponse(
    String uuid,
    Response<dynamic> response,
    bool canLogContent,
  ) {
    final isSuccessful = _isSuccessful(response);
    final responseText = '${response.statusCode} ${response.statusMessage}';
    isSuccessful
        ? _logger.debug(
            '[$uuid] Response: $responseText',
            callerType: runtimeType,
          )
        : _logger.error(
            '[$uuid] Response: $responseText',
            callerType: runtimeType,
          );

    if (canLogContent && response.data != null) {
      isSuccessful
          ? _logger.debug(
              '[$uuid] ResponseBody: ${response.toString()}',
              callerType: runtimeType,
            )
          : _logger.error(
              '[$uuid] ResponseBody: ${response.toString()}',
              callerType: runtimeType,
            );
    }
  }

  void _addRetryInterceptor(int retryCount, List<Duration>? retryDelays) {
    _client.interceptors.add(
      RetryInterceptor(
        dio: _client,
        logPrint: (message) {
          _logger.error(message, callerType: runtimeType);
        },
        retries: retryCount,
        retryDelays: retryDelays ??
            const [
              Duration(seconds: 1),
              Duration(seconds: 2),
              Duration(seconds: 3),
            ],
      ),
    );
  }

  void _ignoreBadCertificate() {
    _client.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        // Ignore bad certificate.
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );
  }

  void _validateResponseData(
    Response<dynamic> response,
    ApiResponseType responseType,
  ) {
    // Throw an exception if response is not in valid format.
    if (responseType == ApiResponseType.text && response.data is! String) {
      throw InvalidResponseException();
    }
  }

  bool _isSuccessful(Response<dynamic> response) {
    if (response.statusCode == null) return false;
    return response.statusCode! >= 200 && response.statusCode! < 300;
  }

  ApiError _getApiError(
    Exception ex,
    ApiCancelToken? cancelToken,
    String uuid,
  ) {
    // Refresh cancel token to be able to use again.
    cancelToken?.refresh();
    // Log error and return in ApiResult.
    final apiError = ApiError.fromException(ex);
    _logger.error(
      '[$uuid] Error: ${apiError.toString()}',
      callerType: runtimeType,
    );
    _onApiErrorController.add(apiError);
    return apiError;
  }
  // - Helpers
}
