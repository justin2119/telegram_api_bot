import 'dart:convert';
import '../core/network_client.dart';
import 'weather_model.dart';

class WeatherRemoteDataSource {
  final NetworkClient client;
  final String apiKey;

  WeatherRemoteDataSource({required this.client, required this.apiKey});

  Future<WeatherModel> getCityWeather(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
