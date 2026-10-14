class SonarrException implements Exception {
  final String message;
  SonarrException(this.message);

  @override
  String toString() => 'SonarrException: $message';
}

class SonarrUnauthorizedException extends SonarrException {
  SonarrUnauthorizedException([super.message = 'Unauthorized (401)']);
}

class SonarrBadRequestException extends SonarrException {
  SonarrBadRequestException(super.message);
}

class SonarrNotFoundException extends SonarrException {
  SonarrNotFoundException([super.message = 'Not Found (404)']);
}

class SonarrServerException extends SonarrException {
  SonarrServerException([super.message = 'Internal Server Error (500)']);
}

class SonarrConnectionException extends SonarrException {
  SonarrConnectionException([super.message = 'Connection Failed']);
}
