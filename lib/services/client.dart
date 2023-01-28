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
    try {
      final response = await client
          .from('SavedLinks')
          .select('*')
          .eq('user', _userController.username.value)
          .order(sortBy ?? 'timestamp', ascending: ascending ?? false);
      return response;
    } catch (e) {
      return 'e';
    }
  }

  static Future<Result> getLabels(String user) async {
    try {
      final response = await client.from(usersTabel).select('labels').eq('id', user);
      return Result(
        true,
        message: response.first["labels"],
      );
    } catch (e) {
      return Result(false);
    }
  }

  static Future<Result> updateLabels(String user, List labels) async {
    try {
      await client.from(usersTabel).update({"labels": labels}).eq('id', user);
      return Result(true);
    } catch (e) {
      return Result(false);
    }
  }

  static Future<Result> doesUserExist(String user) async {
    try {
      final response = await client.from(usersTabel).select('id').eq('id', user);
      return Result(true, message: response.isNotEmpty);
    } catch (e) {
      return Result(false);
    }
  }

  static Future<Result> saveLink({
    String? uid,
    required String title,
    required String url,
    required int colorIndex,
    required List<int> labels,
    required bool autotitle,
  }) async {
    try {
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
        ]).select();
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
        ]).select();
      }
      return Result(true, message: response.first);
    } catch (e) {
      return Result(false);
    }
  }

  static Future<Result> updateLinks(requestData) async {
    if (requestData.isEmpty) {
      return Result(true);
    }
    try {
      await client.from(linksTabel).upsert(requestData);
      return Result(true);
    } catch (e) {
      return Result(false);
    }
  }

  static Future<Result> deleteLink(String uid) async {
    try {
      await client.from(linksTabel).delete().eq('uid', uid);
      Result result = Result(true);
      return result;
    } catch (e) {
      return Result(false);
    }
  }
}
