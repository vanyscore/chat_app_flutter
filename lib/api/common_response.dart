class CommonResponse<T> {
  T? data;
  String? errorMessage;
  Map<String, String?>? validations;

  CommonResponse({this.data, this.errorMessage, this.validations});

  factory CommonResponse.unknown() =>
      CommonResponse(errorMessage: 'Unknown error');
}
