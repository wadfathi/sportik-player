import 'dart:io';

class Proxyservice {
  HttpServer? _server;
  static String token = '';
  static String host = '';
  static HttpClient? _httpClient;

  Future<void> start() async {
    if (_server != null) return;
    _httpClient ??= HttpClient();
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8087);
    _server!.listen((request) async {
      try {
        final base = host.endsWith('/') ? host.substring(0, host.length - 1) : host;
        final path = request.uri.path;
        final uri = Uri.parse('$base$path$token');
        final upstream = await _httpClient!.getUrl(uri);
        final response = await upstream.close();
        request.response.statusCode = response.statusCode;
        response.headers.forEach((name, values) {
          if (!['transfer-encoding','connection','content-length'].contains(name.toLowerCase())) {
            for (final value in values) { request.response.headers.add(name, value); }
          }
        });
        await response.pipe(request.response);
      } catch (_) {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
      }
    });
  }
  void updateToken(String value) => token = value;
  Future<void> stop() async { final server = _server; _server = null; await server?.close(force: true); }
  void sethost(String value) => host = value;
}
