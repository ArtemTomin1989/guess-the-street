import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Map Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Map Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Вітаємо у грі!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Почати гру'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final MapController _mapController;
  LatLng _currentLocation = LatLng(50.4501, 30.5234); // Київ, Україна
  String _hint = 'Натисніть на карту, щоб знайти наступну підказку';
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadScore();
  }

  Future<void> _loadScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('score') ?? 0;
    });
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', _score);
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _currentLocation = location;
      _hint = 'Чудово! Ви знайшли нову підказку!';
      _score += 10;
    });
    _saveScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 13.0,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 50.0,
                      height: 50.0,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _hint,
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ваш рахунок: $_score',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
