sealed class ResultApi<T> {}

class SuccessApi<T> extends ResultApi<T> {
  SuccessApi(this.data);
  final T data;
}

class ErrorApi<T> extends ResultApi<T> {
  ErrorApi(this.errorMessage, {this.isNetworkError = false});
  final String errorMessage;
  final bool isNetworkError;
}
