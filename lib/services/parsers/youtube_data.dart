import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/parsers/url_parser.dart';
import '../extensions.dart';

class YoutubeData {
  static Future<Link> getDetails(Link link) async {
    String id = _getVideoID(link.url);
    if (id.isEmpty) {
      link.title = await UrlParser.getUrlTitle(link.url);
      return link;
    }
    String rawDetails = await _getDataFromApi(id);
    Map<String, dynamic> details = json.decode(rawDetails);

    String title, channelTitle, duration;

    try {
      duration =
          _parseDuration(details['items'][0]['contentDetails']['duration'])
              .toDurationString();
    } catch (e) {
      duration = "Live";
    }

    try {
      title = details['items'][0]['snippet']['title'];
      channelTitle = details['items'][0]['snippet']['channelTitle'];
    } catch (e) {
      link.title = await UrlParser.getUrlTitle(link.url);
      return link;
    }

    link.title = title.trim();
    link.subtitle = channelTitle.trim();
    link.message = duration.trim();

    return link;
  }

  static Future<String> _getDataFromApi(String id) async {
    var request = http.Request(
        'GET',
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/videos?id=$id&key=AIzaSyDOAca4V6Nll2OcJKVDl7n74VN5n_SzbrI&part=contentDetails&part=snippet',
        ));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception();
    }
  }

  static String _getVideoID(String url) {
    String pattern =
        r"http(?:s)?:\/\/(?:m.)?(?:w{3}\.)?youtu(?:\.be\/|be\.com\/(?:(?:shorts\/)|(?:watch\?(?:feature=youtu.be\&)?v=|v\/|embed\/|user\/(?:[\w#]+\/)+)))([^&#?\n]+)";
    RegExp exp = RegExp(pattern);
    Iterable<RegExpMatch> matches = exp.allMatches(url);
    if (matches.isEmpty) {
      return '';
    }
    return matches.first.group(1) ?? '';
  }

  static Duration _parseDuration(String rawDuration) {
    List<int> duration = [0, 0, 0];
    String pattern = "PT(?:([0-9]+)H)?(?:([0-9]+)M)?(?:([0-9]+)S)?";
    RegExp exp = RegExp(pattern);
    Iterable<RegExpMatch> matches = exp.allMatches(rawDuration);
    for (int i = 0; i < duration.length; i++) {
      duration[i] = int.parse(matches.first.group(i + 1) ?? '0');
    }
    return Duration(
        hours: duration[0], minutes: duration[1], seconds: duration[2]);
  }
}
