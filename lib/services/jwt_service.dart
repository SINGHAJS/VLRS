import 'package:logger/logger.dart';
import 'package:vlrs/constants/jwt_constants.dart';
import 'package:dio/dio.dart';

class JwtService {
  final Logger _logger = Logger();

  final _authenticationData = {
    'username': JWTConstants.THINGSBOARD_USERNAME,
    'password': JWTConstants.THINGSBOARD_PASSWORD,
  };

  // send request to thingsboard server to get jwt token

  ///
  /// Uses Dio to send a POST request to get a new JWT token.
  ///
  /// * If the toke is received successfully,
  ///   * return the token.
  /// * Otherwise,
  ///   * Log the status code or the error message.
  ///
  Future<String?> fetchJwtToken() async {
    final dio = Dio();

    try {
      // Send a POST request to the ThingsBoard server with the auth data.
      final response = await dio.post(
        JWTConstants.JWT_URL,
        data: _authenticationData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // If successful, extract and return the JWT token from the response data.
        return response.data['token'];
      } else {
        // If the response status code is not 200, log the status code.
        _logger.i('Error: ${response.statusCode}');
      }
    } catch (e) {
      // If an execption occured, log the error.
      _logger.e(e);
    }

    return null;
  }
}
