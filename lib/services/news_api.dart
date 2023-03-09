import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proj45_restapi_newsapp/consts/http_exception.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:proj45_restapi_newsapp/models/news_model.dart';

import '../consts/api_consts.dart';

class NewsApiServices {
  static Future<List<NewsModel>> getAllNews(
      {required int page, required String sortBy}) async {
    // List<NewsModel>
    // var url = Uri.parse(
    //     'https://newsapi.org/v2/everything?q=bitcoin&pageSize=5&apiKey=ab8a30ec6b1e441eaa258af6aa14fb9a');

    try {
      var uri = Uri.https(BASEURL, "v2/everything", {
        "q": "bitcoin",
        "pageSize": "5",
        "domains": "bbc.co.uk,techcrunch.com,engadget.com",
        "page": page.toString(),
        "sortBy": sortBy,
        // "apiKey": API_KEY,
      });
      var response = await http.get(
        uri,
        headers: {"X-Api-Key": API_KEY},
      );
      log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');
      // print(await http.read(Uri.https('example.com', 'foobar.txt')));
      Map data = jsonDecode(response.body);
      List newsTempList = [];

      if (data['code'] != null) {
        throw HttpException(data['code']);
      }
      for (var v in data["articles"]) {
        newsTempList.add(v);
        // log(v.toString());
        // print(data["articles"].length);
      }
      return NewsModel.newsFromSnapshot(newsTempList);
    } catch (error) {
      throw error.toString();
    }

    // todo
  }
// List<NewsModel>.org/v2/everything?q=bitcoin&pageSize=5&apiKey=ab8a30ec6b1e441eaa258af6aa14fb9a');

  static Future<List<NewsModel>> getTopHeadlines() async {
    try {
      var uri = Uri.https(BASEURL, "v2/top-headlines", {
        "country": "us"
        // "apiKey": API_KEY,
      });
      var response = await http.get(
        uri,
        headers: {"X-Api-Key": API_KEY},
      );
      log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');
      // print(await http.read(Uri.https('example.com', 'foobar.txt')));
      Map data = jsonDecode(response.body);
      List newsTempList = [];

      if (data['code'] != null) {
        throw HttpException(data['code']);
      }
      for (var v in data["articles"]) {
        newsTempList.add(v);
        // log(v.toString());
        // print(data["articles"].length);
      }
      return NewsModel.newsFromSnapshot(newsTempList);
    } catch (error) {
      throw error.toString();
    }
  }

  // search function
  static Future<List<NewsModel>> searchNews({required String query}) async {
    try {
      var uri = Uri.https(BASEURL, "v2/everything", {
        "q": query,
        "pageSize": "10",
        "domains": "bbc.co.uk,techcrunch.com,engadget.com",
      });
      var response = await http.get(
        uri,
        headers: {"X-Api-Key": API_KEY},
      );
      log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');
      // print(await http.read(Uri.https('example.com', 'foobar.txt')));
      Map data = jsonDecode(response.body);
      List newsTempList = [];

      if (data['code'] != null) {
        throw HttpException(data['code']);
      }
      for (var v in data["articles"]) {
        newsTempList.add(v);
        // log(v.toString());
        // print(data["articles"].length);
      }
      return NewsModel.newsFromSnapshot(newsTempList);
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<List<BookmarksModel>?> getBookmarks() async {
    try {
      var uri = Uri.https(BASEURL_FIREBASE, "bookmarks.json", {
        "country": "us"
        // "apiKey": API_KEY,
      });
      var response = await http.get(
        uri,
      );
      // log('Response status: ${response.statusCode}');
      // log('Response body: ${response.body}');
      ///////1
      Map data = jsonDecode(response.body);
      List allKeys = [];

      if (data['code'] != null) {
        throw HttpException(data['code']);
      }
      for (String key in data.keys) {
        allKeys.add(key);
      }
      log("allKeys $allKeys");
      return BookmarksModel.bookmarksFromSnapshot(json: data, allKeys: allKeys);
    } catch (error) {
      rethrow;
    }
    ///////2
  }
}
