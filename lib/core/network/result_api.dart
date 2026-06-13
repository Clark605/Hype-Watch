sealed class ResultApi<T> {}

class SuccessApi<T> extends ResultApi<T> {
  SuccessApi({this.data});
  T? data;
}

class ErrorApi<T> extends ResultApi<T> {
  ErrorApi(this.errorMessage);
  String errorMessage;
}
