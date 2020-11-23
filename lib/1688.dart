import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:faker/faker.dart';
import 'package:html/parser.dart' show parse;

class Parser1688 {
  static const String proxyHost = 'zproxy.lum-superproxy.io';
  static const int proxyPort = 22225;
  static const String proxyLogin = 'lum-customer-hl_9ea4f251-zone-static';
  static const String proxyPass = 'z9yry68vii4f';

  Future<List> getSupplier(String supplierId, {int page = 1}) async {
    var userAgent =
        Faker().internet.userAgent(osName: 'Windows'); //Random User-Agents

    var headers = {'User-Agent': userAgent};

    /* Начинается запрос */
    var dioRequest = dio.Dio();
    dioRequest.options.baseUrl = 'https://$supplierId.1688.com';

    dioRequest.options.headers = headers;
    dioRequest.options.followRedirects = false;
    dioRequest.options.validateStatus = (int status) {
      return status < 400;
    };

    //Proxy settings
    (dioRequest.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      client.findProxy = (uri) {
        return 'PROXY $proxyHost:$proxyPort';
      };

      //Proxy Auth
      client.addProxyCredentials(proxyHost, proxyPort, 'http://$proxyHost',
          HttpClientBasicCredentials(proxyLogin, proxyPass));
    };
    var products = [];

    try {
      var response = await dioRequest.get('/page/offerlist.htm?pageNum=$page');
      products = await getDom(response.data, supplierId);
    } on dio.DioError catch (error) {
      if (error.type == dio.DioErrorType.RESPONSE ||
          error.response == null ||
          error.response.statusCode == 302 ||
          error.response.statusCode == 301) {
        //sleep(Duration(seconds: 6));
        await getSupplier(supplierId);
        exit(0);
      }
    }

    return products;
  }

  Future<List> getDom(String html, String supplierId) async {
    var products = [];

    var productsBlock = parse(html).getElementById('search-bar');

    if (productsBlock != null) {
      productsBlock
          .getElementsByClassName('offer-list-row-offer')
          .forEach((element) {
        var images = [];
        element.getElementsByTagName('img').forEach((imageElement) {
          images.add(imageElement.attributes['data-lazy-load-src']);
        });

        var price =
            element.getElementsByClassName('price-container').first.text;

        var link = element.getElementsByTagName('a').first.attributes['href'];

        var name = element.getElementsByTagName('a').first.attributes['title'];

        var product = {
          'link': link,
          'name': name,
          'price': price,
          'images': images
        };

        products.add(product);
      });
    } else {
      products = await getSupplier(supplierId);
    }

    return products;
  }
}
