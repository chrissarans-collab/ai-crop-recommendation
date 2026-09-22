 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CropApp());
}

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Recommendation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CropHomePage(),
    );
  }
}

class CropHomePage extends StatefulWidget {
  const CropHomePage({super.key});

  @override
  State<CropHomePage> createState() => _CropHomePageState();
}

class _CropHomePageState extends State<CropHomePage> {
  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final temperatureController = TextEditingController();
  final humidityController = TextEditingController();
  final phController = TextEditingController();
  final rainfallController = TextEditingController();

  String result = '';
  bool loading = false;

  Future<void> recommendCrop() async {
    setState(() {
      loading = true;
      result = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5001/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'N': double.parse(nController.text),
          'P': double.parse(pController.text),
          'K': double.parse(kController.text),
          'temperature': double.parse(temperatureController.text),
          'humidity': double.parse(humidityController.text),
          'ph': double.parse(phController.text),
          'rainfall': double.parse(rainfallController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          result = '🌱 Recommended Crop: ${data['crop']}';
        });
      } else {
        setState(() {
          result = '❌ Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        result = '❌ Could not connect to the AI server.';
      });
    }

    setState(() {
      loading = false;
    });
  }

  Widget inputBox(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Crop Recommendation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Soil & Weather Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            inputBox('Nitrogen (N)', nController),
            inputBox('Phosphorus (P)', pController),
            inputBox('Potassium (K)', kController),
            inputBox('Temperature (°C)', temperatureController),
            inputBox('Humidity (%)', humidityController),
            inputBox('pH', phController),
            inputBox('Rainfall (mm)', rainfallController),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loading ? null : recommendCrop,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Recommend Crop',
                      style: TextStyle(fontSize: 18),
                    ),
            ),

            const SizedBox(height: 25),

            if (result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}