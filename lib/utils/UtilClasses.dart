class Pack {
  String _msg;
  bool _isError;
  dynamic _data;
  Pack(this._msg, this._isError, this._data) {}

  String getMessage() => _msg;
  bool isError() => _isError;
  dynamic getData() => _data;
}

class DataPack extends Pack {
  bool isSuccess;
  bool shouldPop;
  DataPack(
      String msg, bool isError, bool isSuccess, bool shouldPop, dynamic data)
      : super(msg, isError, data) {
    this.isSuccess = isSuccess;
    this.shouldPop = shouldPop;
  }
}

class ResponsePack extends Pack {
  ResponsePack(String msg, bool isError, dynamic data)
      : super(msg, isError, data) {}
}
