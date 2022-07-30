import 'dart:convert';

import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/parsers/url_parser.dart';
import 'package:seamlink/services/utils.dart';

class RedditData {
  static Future<Link> getDetails(Link link) async {
    String query = _getRedditQuery(link.url);
    if (query.isEmpty) {
      link.title = await UrlParser.getUrlTitle(link.url);
      return link;
    }
    String rawData = await _getDataFromApi(query);
    Map data = json.decode(rawData);
    String title = data["data"]["children"][0]["data"]['title'];
    String subreddit = 'r/' + data["data"]["children"][0]["data"]['subreddit'];
    String author = 'u/' + data["data"]["children"][0]["data"]['author'];
    link.title = title.trim();
    link.subtitle = author.trim();
    link.message = subreddit.trim();
    return link;
  }

  static String _getRedditQuery(String url) {
    if (url.contains('://redd.it/')) {
      String substring = url.substring(16, url.length);
      if (substring.isEmpty) return '';
      return 'id=t3_' + substring;
    } else if (url.contains('reddit.com/')) {
      String pattern =
          r"https\://(w{3}.)?reddit\.com/r/.*/comments/([a-z0-9]*)/.*";
      RegExp exp = RegExp(pattern);
      Iterable<RegExpMatch> matches = exp.allMatches(url);
      if (matches.isEmpty) return '';
      return 'id=t3_' + matches.first.group(2)!;
    } else {
      return 'url=' + Uri.encodeFull(url);
    }
  }

  static Future<String> _getDataFromApi(String query) async {
    String apiUrl = 'https://api.reddit.com/api/info/?$query';
    return await getDataFromApi(apiUrl);
  }
}
