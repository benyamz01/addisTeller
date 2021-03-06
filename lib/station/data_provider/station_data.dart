import 'dart:convert';
import 'dart:io';

import 'package:addis_teller_app/constants.dart';
import 'package:addis_teller_app/station/station.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StationDataProvider {
  // final _baseUrl = 'http://192.168.122.1:6002';
  final http.Client httpClient;

  StationDataProvider({@required this.httpClient}) : assert(httpClient != null);

  Future<String> pref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token");
    return token;
  }

  Future<Station> createStation(Station station) async {
    final token = await pref();
    final response = await httpClient.post(
      Uri.http('192.168.122.1:6002', '/stations'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'name': station.name,
        'latLong': station.latLong,
        'stations': station.stations
      }),
    );

    if (response.statusCode == 201) {
      return Station.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('${jsonDecode(response.body).message}');
    }
  }

  Future<List<Station>> getStations() async {
    final token = await pref();
    final response =
        await httpClient.get('${Constants.baseUrl}/stations', headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer $token'
    });
    if (response.statusCode == 200) {
      final stations = jsonDecode(response.body) as List;
      // print(stations);
      return stations.map((station) => Station.fromJson(station)).toList();
    } else {
      throw Exception('${jsonDecode(response.body).message}');
    }
  }

  Future<void> deleteStation(String id) async {
    final token = await pref();
    final response = await httpClient.delete(
      '${Constants.baseUrl}/stations/$id',
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
    );
    if (response.statusCode != 204) {
      throw Exception('error deleting station');
    }
  }

  Future<void> updateStation(Station station) async {
    final token = await pref();
    final http.Response response = await httpClient.put(
      '${Constants.baseUrl}/stations/${station.id}',
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        'name': station.name,
        'latLong': station.latLong,
        'stations': station.stations
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update station.');
    }
  }
}
