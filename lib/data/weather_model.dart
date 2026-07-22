import '../domain/weather.dart';

class WeatherModel extends Weather {
  WeatherModel({
    required String cityName,
    required double temperature,
    required String description,
    required int humidity,
  }) : super(
          cityName: cityName,
          temperature: temperature,
          description: description,
          humidity: humidity,
        );

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
    );
  }
}
