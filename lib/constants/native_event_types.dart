/// Native events emitted by the platform SDK.
enum NativeEventTypes {
  /// Fired when the flow completes successfully.
  onSuccess,

  /// Fired when the flow fails with an error.
  onError,

  /// Fired when the SDK generates or returns a request ID.
  onRequestId,
}

/// Helpers for converting native event values into Dart enums.
extension NativeEventTypesExt on NativeEventTypes {
  /// Parses a platform event name into a [NativeEventTypes] value.
  static NativeEventTypes? parse(String value) {
    switch (value) {
      case 'on_success':
        return NativeEventTypes.onSuccess;
      case 'on_error':
        return NativeEventTypes.onError;
      case 'on_request_id':
        return NativeEventTypes.onRequestId;
      default:
        return null;
    }
  }
}
