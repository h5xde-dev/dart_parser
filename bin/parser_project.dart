import 'dart:convert';
import 'dart:io';
import 'package:parser_project/1688.dart';

void main(List<String> arguments) async {
  List result;

  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    80,
  );
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    await handleRequest(request);
  }

  print(result);
}

Future handleRequest(HttpRequest request) async {
  List result;

  try {
    if (request.method == 'GET' &&
        request.uri.path == '/supplier' &&
        request.uri.queryParameters.containsKey('id')) {
      result = await Parser1688().getSupplier(request.uri.queryParameters['id'],
          page: int.parse(request.uri.queryParameters['page']));

      var json = jsonEncode(result);

      request.response.write(json);
    } else {
      // ···
    }
  } catch (e) {
    print('Exception in handleRequest: $e');
  }

  await request.response.close();
}
