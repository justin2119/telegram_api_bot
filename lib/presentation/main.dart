import 'dart:async';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import '../core/network_client.dart';
import '../data/weather_remote_data_source.dart';
import '../data/weather_repository_impl.dart';
import '../domain/weather.dart';

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

  // Store active alerts: Map<chatId, Map<city, Timer>>
  final Map<int, Map<String, Timer>> activeAlerts = {};

  teledart.start();

  // /weather command
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

  // /alert command
  teledart.onCommand('alert').listen((message) async {
    final city = message.text?.replaceFirst('/alert', '').trim();
    final chatId = message.chat.id;

    if (city == null || city.isEmpty) {
      message.reply('Please provide a city name for the alert. Usage: /alert <city>');
      return;
    }

    // Check if alert already exists for this city in this chat
    if (activeAlerts[chatId]?.containsKey(city) ?? false) {
      message.reply('You already have an active alert for $city.');
      return;
    }

    try {
      // Verify city exists first
      final initialWeather = await repository.getWeather(city);
      
      message.reply('Alert set! I will send you weather updates for ${initialWeather.cityName} every hour.');

      // Setup periodic timer (e.g., every 1 hour)
      final timer = Timer.periodic(const Duration(hours: 1), (timer) async {
        try {
          final weather = await repository.getWeather(city);
          teledart.sendMessage(chatId, 
            '🔔 Periodic Alert for ${weather.cityName}:\n'
            'Temperature: ${weather.temperature}°C\n'
            'Condition: ${weather.description}'
          );
        } catch (e) {
          print('Error fetching alert for $city: $e');
        }
      });

      // Save timer to memory
      activeAlerts.putIfAbsent(chatId, () => {});
      activeAlerts[chatId]![city] = timer;

    } catch (e) {
      message.reply('Could not set alert for "$city". Please check the city name.');
    }
  });

  // /stopalert command
  teledart.onCommand('stopalert').listen((message) {
    final city = message.text?.replaceFirst('/stopalert', '').trim();
    final chatId = message.chat.id;

    if (city == null || city.isEmpty) {
      message.reply('Please specify the city to stop alerts for. Usage: /stopalert <city>');
      return;
    }

    if (activeAlerts[chatId]?.containsKey(city) ?? false) {
      activeAlerts[chatId]![city]!.cancel();
      activeAlerts[chatId]!.remove(city);
      message.reply('Alerts for $city have been stopped.');
    } else {
      message.reply('No active alert found for $city.');
    }
  });

  print('Bot is running...');
}
