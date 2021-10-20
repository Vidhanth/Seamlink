import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seamlink/models/link.dart';
import 'package:seamlink/services/parsers/url_parser.dart';
import '../extensions.dart';

class YoutubeData {
  static Future<Link> getDetails(Link link) async {
    bool playlist = link.url.contains('playlist');

    String id = _getVideoID(link.url);

    if (id.isEmpty) {
      link.title = await UrlParser.getUrlTitle(link.url);
      return link;
    }
    String rawDetails = await _getDataFromApi(id, playlist: playlist);
    Map<String, dynamic> details = json.decode(rawDetails);

    String title, channelTitle, extra;
    String? thumbnail;

    try {
      extra = playlist
          ? details['items'][0]['contentDetails']['itemCount'].toString()
          : _parseDuration(details['items'][0]['contentDetails']['duration'])
              .toDurationString();
    } catch (e) {
      extra = playlist ? "0" : "Live";
    }

    try {
      title = details['items'][0]['snippet']['title'];
      channelTitle = details['items'][0]['snippet']['channelTitle'];
      try {
        thumbnail =
            details['items'][0]['snippet']['thumbnails']['maxres']['url'];
      } catch (e) {
        thumbnail = details['items'][0]['snippet']['thumbnails']['high']['url'];
      }
    } catch (e) {
      link.title = await UrlParser.getUrlTitle(link.url);
      return link;
    }

    link.title = title.trim();
    link.subtitle = channelTitle.trim();
    link.message = extra.trim();
    link.thumbnail = thumbnail;

    return link;
  }

  static Future<String> _getDataFromApi(
    String id, {
    bool playlist = false,
  }) async {
    String url = playlist
        ? 'https://www.googleapis.com/youtube/v3/playlists?id=$id&key=AIzaSyDOAca4V6Nll2OcJKVDl7n74VN5n_SzbrI&part=snippet&part=contentDetails&fields=items(snippet(title,channelTitle,thumbnails(maxres/url,high/url)),contentDetails/itemCount)'
        : 'https://www.googleapis.com/youtube/v3/videos?id=$id&key=AIzaSyDOAca4V6Nll2OcJKVDl7n74VN5n_SzbrI&part=snippet&part=contentDetails&fields=items(snippet(title,channelTitle,thumbnails(maxres/url,high/url)),contentDetails/duration)';

    var request = http.Request(
        'GET',
        Uri.parse(
          url,
        ));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      throw Exception();
    }
  }

  static String _getVideoID(String url) {
    if (url.contains('playlist')) {
      return url.split('list=').last;
    }

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
