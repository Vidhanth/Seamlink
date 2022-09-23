import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:seamlink/controllers/UserController.dart';
import 'package:seamlink/models/result.dart';
import 'package:supabase/supabase.dart';

class Client {
  static const String linksTabel = 'SavedLinks';
  static const String usersTabel = 'Users';

  static UserController _userController = Get.find<UserController>();

  static late SupabaseClient client;

  static void initialize() {
    client = SupabaseClient(
      dotenv.get('SUPABASE_URL'),
      dotenv.get('SECRET_KEY'),
    );
  }

  static Future<dynamic> fetchLinks({
    String? sortBy,
    bool? ascending,
  }) async {
    final response = await client
        .from('SavedLinks')
        .select('*')
        .eq('user', _userController.username.value)
        .order(sortBy ?? 'timestamp', ascending: ascending ?? false)
        .execute();
    if (response.error == null) {
      return response.data;
    } else {
      return 'e';
    }
  }

  static Future<dynamic> fetchColumns(String columns) async {
    final response = await client
        .from(linksTabel)
        .select(columns)
        .eq('user', _userController.username.value)
        .execute();
    if (response.error == null) {
      return response.data;
    } else {
      return '';
    }
  }

  static Future<Result> getLabels(String user) async {
    final response =
        await client.from(usersTabel).select('labels').eq('id', user).execute();
    return Result(
      response.error == null,
      message: response.data?.first["labels"],
    );
  }

  static Future<Result> updateLabels(String user, List labels) async {
    final response = await client
        .from(usersTabel)
        .update({"labels": labels})
        .eq('id', user)
        .execute();
    return Result(
      response.error == null,
      message: response.data?.first["labels"],
    );
  }

  static Future<Result> doesUserExist(String user) async {
    final response =
        await client.from(usersTabel).select('id').eq('id', user).execute();
    return Result(response.error == null, message: response.data?.isNotEmpty);
  }

  static Future<Result> saveLink({
    String? uid,
    required String title,
    required String url,
    required int colorIndex,
    required List<int> labels,
    required bool autotitle,
  }) async {
    var response;
    if (uid != null) {
      String updatedAt = DateTime.now().toUtc().toIso8601String();
      response = await client.from(linksTabel).upsert([
        {
          "uid": uid,
          "url": url,
          "title": title,
          "color": colorIndex,
          "labels": labels,
          "user": _userController.username.value,
          "autotitle": autotitle,
          "updated_at": updatedAt,
        },
      ]).execute();
    } else {
      if (_userController.username.value.isEmpty) {
        return Result(
          false,
          message: 'Make sure you are logged in first.',
        );
      }
      response = await client.from(linksTabel).insert([
        {
          "url": url,
          "title": autotitle ? "" : title,
          "color": colorIndex,
          "labels": labels,
          "user": _userController.username.value,
          "autotitle": autotitle,
        },
      ]).execute();
    }
    return Result(
      response.error == null,
      message: response.data?.first,
    );
  }

  static Future<Result> updateLinks(requestData) async {
    if (requestData.isEmpty) {
      return Result(true);
    }
    var response = await client.from(linksTabel).upsert(requestData).execute();
    return Result(
      response.error == null,
      message: response.data?.first,
    );
  }

  static Future<Result> deleteLink(String uid) async {
    final response =
        await client.from(linksTabel).delete().eq('uid', uid).execute();
    Result result = Result(response.error == null,
        message: response.error == null ? response.data?.first["uid"] : null);
    return result;
  }
}
