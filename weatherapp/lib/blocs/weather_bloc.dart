import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/events/weather_event.dart';
import 'package:weatherapp/models/watchlog.dart';
import 'package:weatherapp/models/weather.dart';
import 'package:weatherapp/repositories/weather_repository.dart';
import 'package:weatherapp/states/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;
  WeatherBloc({@required this.weatherRepository}):
      assert(weatherRepository != null),
      super(WeatherStateInitial());
  @override
  Stream<WeatherState> mapEventToState(WeatherEvent weatherEvent) async*{
    if(weatherEvent is WeatherEventRequested) {
      yield WeatherStateLoading();
      try {
        final Weather weather = await weatherRepository.getWeatherFromCity(weatherEvent.city, weatherEvent.lat, weatherEvent.logn);
        yield WeatherStateSuccess(weather: weather);
      }catch(exception, stacktrace) {
        WatchLogs.err = stacktrace.toString();
        WatchLogs.e = exception.toString();
        yield WeatherStateFailure();
      }
    } else if(weatherEvent is WeatherEventRefresh) {
      try {
        final Weather weather = await weatherRepository.getWeatherFromCity(weatherEvent.city, 0.0, 0.0);
        yield WeatherStateSuccess(weather: weather);
      }catch(exception, stacktrace) {
        WatchLogs.err = stacktrace.toString();
        WatchLogs.e = exception.toString();
        yield WeatherStateFailure();
      }
    }
  }
}