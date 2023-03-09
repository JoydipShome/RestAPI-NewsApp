import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:http/http.dart' as http;
import 'package:proj45_restapi_newsapp/models/news_model.dart';

import '../consts/api_consts.dart';
import '../services/news_api.dart';

class BookmarksProvider with ChangeNotifier {
  List<BookmarksModel> bookmarkList = [];

  List<BookmarksModel> get getBookmarkList {
    return bookmarkList;
  }

  Future<List<BookmarksModel>> fetchBookmarks() async {
    bookmarkList = (await NewsApiServices.getBookmarks()) ?? [];
    notifyListeners();
    return bookmarkList;
  }

  Future<void> addToBookmark({required NewsModel newsModel}) async {
    try {
      var uri = Uri.https(BASEURL_FIREBASE, "bookmarks.json", {
        "country": "us"
        // "apiKey": API_KEY,
      });
      var response = await http.post(
        uri,
        body: json.encode(newsModel.toJson()),
        // body: json.encode({"Test": "Anytest"}),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteBookMark({required String key}) async {
    try {
      var uri = Uri.https(BASEURL_FIREBASE, "bookmarks/$key.json", {
        "country": "us"
        // "apiKey": API_KEY,
      });
      var response = await http.delete(uri);
      notifyListeners();
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (error) {
      rethrow;
    }
  }
}
