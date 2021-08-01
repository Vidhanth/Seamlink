import 'package:http/http.dart';
import 'package:html/parser.dart';

class UrlParser {
  static Future<String> getUrlTitle(url) async {
    final client = Client();
    String? title;
    try {
      final response = await client.get(Uri.parse(url));
      final document = parse(response.body);

      var elements = document.getElementsByTagName('meta');

      elements.forEach((tmp) {
        if (tmp.attributes['property'] == 'og:title') {
          title = tmp.attributes['content'];
        }
        if (title?.isEmpty ?? true) {
          title = document.getElementsByTagName('title')[0].text;
        }
      });
    } catch (e) {}
    return title ?? '';
  }
}
