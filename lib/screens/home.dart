import 'dart:async';
import 'dart:ui';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  String _city = "London";
  Map<String, dynamic>? _currentWeather;
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.fetchCurrentWeather(_city);
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void _showCitySelectionDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter City Name'),
            content: TypeAheadField(
              suggestionsCallback: (pattern) async {
                return await _weatherService.fetchCitySuggestions(pattern);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'City Name',
                  ),
                );
                
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['name']),
                );
              },
              onSelected: (city) {
                setState(() {
                  _city = city['name'];
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _fetchWeather();
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _currentWeather == null
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1A2344),
                        Color.fromARGB(255, 35, 119, 27),
                        Color.fromARGB(255, 55, 250, 81),
                        Color.fromARGB(255, 63, 207, 50),
                      ]),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 18, 53, 15),
                        Color.fromARGB(255, 15, 128, 15),
                        Color.fromARGB(255, 44, 134, 56),
                        Color.fromARGB(255, 45, 145, 36),
                      ]),
                ),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: _showCitySelectionDialog,
                      child: Text(
                        _city,
                        style:
                            GoogleFonts.lato(fontSize: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                            'http:${_currentWeather!['current']['condition']['icon']}',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            '${_currentWeather!['current']['temp_c'].round()} °C',
                            style: GoogleFonts.lato(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_currentWeather!['current']['condition']['text']} ',
                            style: GoogleFonts.lato(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Max: ${_currentWeather!['forecast']['forecastday'][0]['day']['maxtemp_c'].round()} °C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Min: ${_currentWeather!['forecast']['forecastday'][0]['day']['mintemp_c'].round()} °C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetail(
                            "Sunrise",
                            Icons.wb_sunny,
                            _currentWeather!['forecast']['forecastday'][0]
                                ['astro']['sunrise']),
                        _buildWeatherDetail(
                            "Sunset",
                            Icons.brightness_3,
                            _currentWeather!['forecast']['forecastday'][0]
                                ['astro']['sunrise'])
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetail("Humidity", Icons.opacity,
                            _currentWeather!['current']['humidity']),
                        _buildWeatherDetail("Wind(KPH)", Icons.wind_power,
                            _currentWeather!['current']['wind_kph']),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWeatherDetail(String Label, IconData icon, dynamic value) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                const Color(0xFF1A2344).withOpacity(0.5),
                const Color(0xFF1A2344).withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                Label,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                value is String ? value : value.toString(),
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
