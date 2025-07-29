class CustomException implements Exception {
  CustomException(this._errorCode, this._message, this._prefix);

  final dynamic _message;
  final int _errorCode;
  final String _prefix;

  String get errorMessage => "$_message";

  int get errorCode => _errorCode;

  @override
  String toString() {
    return '$_errorCode: $_prefix: $_message';
  }
}

class RequestCancelledException extends CustomException {
  RequestCancelledException(errorCode, [message])
      : super(errorCode, message, 'Request Cancelled Exception');
}

class RequestTimeoutException extends CustomException {
  RequestTimeoutException(errorCode, [message])
      : super(errorCode, message, 'Request Timeout Exception');
}

class ReceiveTimeoutException extends CustomException {
  ReceiveTimeoutException(errorCode, [message])
      : super(errorCode, message, 'Receive Timeout Exception');
}

class DefaultException extends CustomException {
  DefaultException(errorCode, [message])
      : super(errorCode, message, 'Default Exception');
}

class FetchDataException extends CustomException {
  FetchDataException(errorCode, [message])
      : super(errorCode, message, 'Fetch Data Exception');
}

class BadRequestException extends CustomException {
  BadRequestException(errorCode, [message])
      : super(errorCode, message, 'Invalid Request');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException(errorCode, [message])
      : super(errorCode, message, 'Unauthorised');
}

class NotFoundException extends CustomException {
  NotFoundException(errorCode, [message])
      : super(errorCode, message, 'Not Found Expection');
}

class ConflictException extends CustomException {
  ConflictException(errorCode, [message])
      : super(errorCode, message, 'Conflict Expection');
}

class InternalServerException extends CustomException {
  InternalServerException(errorCode, [message])
      : super(errorCode, message, 'Internal Server Expection');
}

class UnexpectedException extends CustomException {
  UnexpectedException(errorCode, [message])
      : super(errorCode, message, 'Unexpected Error');
}

class InvalidInputException extends CustomException {
  InvalidInputException(errorCode, [message])
      : super(errorCode, message, 'Invalid Input');
}
