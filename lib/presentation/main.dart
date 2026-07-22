import 'dart:io';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import '../core/network_client.dart';
import '../data/weather_remote_data_source.dart';
import '../data/weather_repository_impl.dart';

void main() async {
  var env = DotEnv()..load();
  final String botToken = env['TELEGRAM_BOT_TOKEN'] ?? '';
  final String weatherApiKey = env['OPENWEATHER_API_KEY'] ?? '';

  if (botToken.isEmpty || weatherApiKey.isEmpty) {
    print('Error: TELEGRAM_BOT_TOKEN or OPENWEATHER_API_KEY not found in .env file');
    exit(1);
  }

  final username = (await Telegram(botToken).getMe()).username;
  var teledart = TeleDart(botToken, Event(username!));

  final networkClient = NetworkClient(http.Client());
  final remoteDataSource = WeatherRemoteDataSource(client: networkClient, apiKey: weatherApiKey);
  final repository = WeatherRepositoryImpl(remoteDataSource);

  teledart.start();

  teledart.onCommand('weather').listen((message) async {
    final city = message.text?.replaceFirst('/weather', '').trim();
    if (city == null || city.isEmpty) {
      message.reply('Please provide a city name. Usage: /weather <city>');
      return;
    }

    try {
      final weather = await repository.getWeather(city);
      message.reply(
        'Weather in ${weather.cityName}:\n'
        'Temperature: ${weather.temperature}°C\n'
        'Humidity: ${weather.humidity}%\n'
        'Condition: ${weather.description}',
      );
    } catch (e) {
      message.reply('Could not find weather for "$city". Please check the city name and try again.');
    }
  });

  print('Bot is running...');
}
