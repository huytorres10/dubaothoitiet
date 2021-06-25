import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/blocs/theme_bloc.dart';
import 'package:weatherapp/blocs/weather_bloc.dart';
import 'package:weatherapp/events/theme_event.dart';
import 'package:weatherapp/events/weather_event.dart';
import 'package:weatherapp/models/Information.dart';
import 'package:weatherapp/models/watchlog.dart';
import 'package:weatherapp/screens/city_search_screen.dart';
import 'package:weatherapp/screens/settings_screen.dart';
import 'package:weatherapp/screens/temperature_widget.dart';
import 'package:weatherapp/states/theme_state.dart';
import 'package:weatherapp/states/weather_state.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeatherScreenState();
}
class _WeatherScreenState extends State<WeatherScreen> {
  Position _currentPosition;
  Completer<void> _completer;
  @override
  Future<void> initState(){
    super.initState();
    _completer = Completer<void>();
    _getCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App using Flutter Bloc'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              //Navigate to SettingsScreen
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                )
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              //Navigate to CitySearchScreen
              final typedCity = await Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => CitySearchScreen()
                  ),
              );
              final double lat = 0;
              final double logn = 0;
              if(typedCity != null) {
                BlocProvider.of<WeatherBloc>(context).add(
                  WeatherEventRequested(city: typedCity, lat: 0, logn: 0)
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, weatherState) {
            if(weatherState is WeatherStateSuccess) {
              BlocProvider.of<ThemeBloc>(context).add(
                ThemeEventWeatherChanged(
                    weatherCondition: weatherState.weather.weatherCondition)
              );
              _completer?.complete();
              _completer = Completer();
            }
          },
          builder: (context, weatherState) {
            if(weatherState is WeatherStateLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if(weatherState is WeatherStateSuccess) {
              final weather = weatherState.weather;
              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState){
                  return RefreshIndicator(
                    onRefresh: (){
                      BlocProvider.of<WeatherBloc>(context).add(
                        WeatherEventRefresh(city: weather.location)
                      );
                      //return a "Completer object"
                      return _completer.future;
                    },
                    child: Container(
                      color: themeState.backgroundColor,
                      child: ListView(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                InformationManh.Name,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),
                              ),
                              Text(
                                InformationManh.Id,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),
                              ),
                              Text(
                                weather.location
                                ,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeState.textColor
                                ),
                              ),
                              Padding(padding: EdgeInsets.symmetric(vertical: 2),),
                              Center(
                                child: Text(
                                  'Updated: ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: themeState.textColor
                                  ),
                                ),
                              ),
                              //show more here, put together inside a Widget
                              TemperatureWidget(
                                weather: weather,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if(weatherState is WeatherStateFailure) {
              return Text(
                'Something went wrong',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              );
            }
            return Center(child: CircularProgressIndicator());
          }
        ),
      ),
    );

  }
  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getWeatherOnYourCity();
      });
    }).catchError((e) {
      print(e);
    });
  }
  _getWeatherOnYourCity() async{
    final String typedCity = '';
    BlocProvider.of<WeatherBloc>(context).add(
        WeatherEventRequested(city: typedCity, lat: _currentPosition.latitude, logn: _currentPosition.longitude)
    );
  }
}