import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}
class WeatherEventRequested extends WeatherEvent {
  final String city;
  final double lat;
  final double logn;
  const WeatherEventRequested({String this.city, double this.lat, double this.logn}): assert(city != null, lat != null);
  @override
  // TODO: implement props
  List<Object> get props => [lat, logn, city];
}
class WeatherEventRefresh extends WeatherEvent {
  final String city;
  const WeatherEventRefresh({String this.city})
      : assert(city != null);
  @override
  List<Object> get props => [city];
}