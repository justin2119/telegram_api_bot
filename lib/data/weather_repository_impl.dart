import '../domain/weather.dart';
import 'weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl(this.remoteDataSource);

  @override
  Future<Weather> getWeather(String city) async {
    return await remoteDataSource.getCityWeather(city);
  }
}
