import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/models/watchlog.dart';
import 'package:weatherapp/models/weather.dart';

const baseUrl = 'https://www.metaweather.com';
final locationUrl = (city) => '${baseUrl}/api/location/search/?query=${city}';
final weatherUrl = (locationId) => '${baseUrl}/api/location/${locationId}';
final latlongUrl = (lat, long) => '${baseUrl}/api/location/search/?lattlong=${lat},${long}';
class WeatherRepository {
  final http.Client httpClient;
  //constructor
  WeatherRepository({@required this.httpClient}): assert(httpClient != null);
  Future<int> getLocationIdFromCity(String city) async {
    WatchLogs.urlWeahter = locationUrl(city);
    final response = await this.httpClient.get(locationUrl(city));
    if(response.statusCode == 200) {
      WatchLogs.res_body = response.toString();
      print(response.bodyBytes);
      final cities = jsonDecode(response.body) as List;
      return (cities.first)['woeid'] ?? Map();
    } else {
      throw Exception('Error getting location id of : ${city}');
    }
  }

  Future<int> getNameCityFromLatLong(double lat, double long) async {
    final response = await this.httpClient.get(latlongUrl(lat, long));
    if(response.statusCode == 200) {
      WatchLogs.res_body = response.toString();
      final cities = jsonDecode(response.body) as List;
      return (cities.first)['woeid'] ?? Map();
    } else {
      throw Exception('Error getting location id of : ${lat}, ${long}');
    }
  }

  //LocationId => Weather
  Future<Weather> fetchWeather(int locationId) async {
    WatchLogs.urlLocation = weatherUrl(locationId);
    final response = await this.httpClient.get(weatherUrl(locationId));

    String res_body = utf8.decode(response.bodyBytes); //Them dong nay
    WatchLogs.code = response.statusCode.toString();

    if(response.statusCode != 200) {
      throw Exception('Error getting weather from locationId: ${locationId}');
    }
    final weatherJson = jsonDecode(res_body); //Sua dong nay
    return Weather.fromJson(weatherJson);
  }
  Future<Weather> getWeatherFromCity(String city, double lat, double long) async {
    int locationId = 0;
    if(city.length == 0){
      locationId = await getNameCityFromLatLong(lat, long);
    }else{
      locationId = await getLocationIdFromCity(city);
    }
    return fetchWeather(locationId);
  }
}