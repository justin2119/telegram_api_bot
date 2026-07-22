class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
  });
}

abstract class WeatherRepository {
  Future<Weather> getWeather(String city);
}
