import 'dart:convert';

import 'package:aniflix/config/enum.dart';
import 'package:aniflix/models/anime.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnimeProvider with ChangeNotifier {
  final List<Anime> _animes = [];
  final Set<int> _wishlist = {};

  DataStatus _datastatus = DataStatus.loading;

  AnimeProvider() {
    fetchAnimes();
  }

  DataStatus get datastatus => _datastatus;
  List<Anime> get animes => [..._animes];

  bool isSaved(int id) => _wishlist.contains(id);

  Future<void> fetchAnimes() async {
    final url = Uri.parse("https://api.aniapi.com/v1/anime");
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) throw "Something went wrong!!";
      final result = json.decode(response.body);
      result['data']['documents'].forEach((value) {
        _animes.add(Anime(
            id: value["id"] ?? 0,
            title: value['titles']['en'] ?? "",
            description: value['descriptions']['en'] ?? "",
            season: value['season_period'] ?? 0,
            episode: value['episodes_count'] ?? 0,
            image: value["cover_image"] ?? "",
            score: value['score'] ?? 0,
            genres: value['genres'] ?? [],
            trailer: value['trailer_url'] ?? "",
            year: value['season_year'] ?? 0,
            duration: value['episode_duration'] ?? 0));
      });
      _datastatus = DataStatus.loaded;
      notifyListeners();
    } catch (err) {
      throw err.toString();
    }
  }

  List<Anime> getAnimeByGnera(String gnera) {
    List<Anime> result = [];
    for (var element in _animes) {
      if (element.genres.contains(gnera)) result.add(element);
    }
    result.shuffle();
    return result;
  }

  Anime getAnimeById(int id) {
    return _animes.firstWhere((element) => element.id == id);
  }
}
