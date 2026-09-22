 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CropWiseApp());
}

class CropWiseApp extends StatelessWidget {
  const CropWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CropWise AI',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7F4A),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final n = TextEditingController();
  final p = TextEditingController();
  final k = TextEditingController();
  final temperature = TextEditingController();
  final humidity = TextEditingController();
  final ph = TextEditingController();
  final rainfall = TextEditingController();

  String crop = '';
  String error = '';
  bool loading = false;

  @override
  void dispose() {
    n.dispose();
    p.dispose();
    k.dispose();
    temperature.dispose();
    humidity.dispose();
    ph.dispose();
    rainfall.dispose();
    super.dispose();
  }

  Future<void> predictCrop() async {
    FocusScope.of(context).unfocus();

    if (n.text.trim().isEmpty ||
        p.text.trim().isEmpty ||
        k.text.trim().isEmpty ||
        temperature.text.trim().isEmpty ||
        humidity.text.trim().isEmpty ||
        ph.text.trim().isEmpty ||
        rainfall.text.trim().isEmpty) {
      setState(() {
        error = 'Please fill in all fields.';
        crop = '';
      });
      return;
    }

    double? nitrogen = double.tryParse(n.text);
    double? phosphorus = double.tryParse(p.text);
    double? potassium = double.tryParse(k.text);
    double? temp = double.tryParse(temperature.text);
    double? humid = double.tryParse(humidity.text);
    double? soilPh = double.tryParse(ph.text);
    double? rain = double.tryParse(rainfall.text);
    if (nitrogen == null ||
        phosphorus == null ||
        potassium == null ||
        temp == null ||
        humid == null ||
        soilPh == null ||
        rain == null) {
      setState(() {
        error = 'Please enter valid numbers.';
        crop = '';
      });
      return;
    }

    if (soilPh < 0 || soilPh > 14) {
      setState(() {
        error = 'Soil pH must be between 0 and 14.';
        crop = '';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      crop = '';
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://crop-recommendation-backend-uc5r.onrender.com/predict'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'N': nitrogen,
              'P': phosphorus,
              'K': potassium,
              'temperature': temp,
              'humidity': humid,
              'ph': soilPh,
              'rainfall': rain,
            }),
          )
          .timeout(const Duration(seconds: 10));
print('STATUS: ${response.statusCode}');
print('BODY: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          crop = data['crop'].toString();
          error = '';
        });
      } else {
        setState(() {
          error = 'The AI server returned an error.';
          crop = '';
        });
      }
    } catch (e) {
      setState(() {
        error =
            'Could not connect to the AI server.\n'
            'Make sure Flask is running on port 5001.';
        crop = '';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void clearAll() {
    n.clear();
    p.clear();
    k.clear();
    temperature.clear();
    humidity.clear();
    ph.clear();
    rainfall.clear();

    setState(() {
      crop = '';
      error = '';
    });
  }

  Widget inputCard({
    required String title,
    required String hint,
    required String unit,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EDE8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B7F4A),
            ),
          ),
          labelText: title,
          hintText: hint,
          suffixText: unit,
          labelStyle: const TextStyle(
            color: Color(0xFF66756C),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFB0BBB5),
          ),
          suffixStyle: const TextStyle(
            color: Color(0xFF6C7B73),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(
    String number,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B7F4A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number  $title',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17231D),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF77837C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget recommendationCard() {
    if (crop.isEmpty && error.isEmpty) {
      return const SizedBox.shrink();
    }

    if (error.isNotEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 22),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD8D2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD94C3D),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: Color(0xFF9C382E),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123F2A),
            Color(0xFF1B7F4A),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B7F4A).withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI RECOMMENDATION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            crop.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recommended based on your soil and weather conditions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 820,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1B7F4A),
                                Color(0xFF2FA866),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CropWise',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF17231D),
                                ),
                              ),
                              Text(
                                'AI-powered agriculture',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF718078),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6EF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(0xFF2FA866),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'AI ONLINE',
                                style: TextStyle(
                                  color: Color(0xFF1B7F4A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // HERO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF102F21),
                            Color(0xFF1B7F4A),
                            Color(0xFF29965B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B7F4A)
                                .withOpacity(0.20),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -25,
                            child: Icon(
                              Icons.eco,
                              size: 150,
                              color: Colors.white.withOpacity(0.055),
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  '✦ SMART FARMING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Grow smarter.\nHarvest better.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Use soil and weather conditions to discover '
                                'the crop your farm needs.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // INPUT SECTION
                    sectionTitle(
                      '01',
                      'Soil conditions',
                      'Tell us about the nutrients in your soil.',
                      Icons.terrain,
                    ),

                    inputCard(
                      title: 'Nitrogen',
                      hint: 'Enter nitrogen level',
                      unit: 'N',
                      icon: Icons.science_outlined,
                      controller: n,
                    ),

                    inputCard(
                      title: 'Phosphorus',
                      hint: 'Enter phosphorus level',
                      unit: 'P',
                      icon: Icons.water_drop_outlined,
                      controller: p,
                    ),

                    inputCard(
                      title: 'Potassium',
                      hint: 'Enter potassium level',
                      unit: 'K',
                      icon: Icons.grass_outlined,
                      controller: k,
                    ),

                    inputCard(
                      title: 'Soil pH',
                      hint: 'Enter soil pH',
                      unit: 'pH',
                      icon: Icons.analytics_outlined,
                      controller: ph,
                    ),

                    const SizedBox(height: 12),

                    sectionTitle(
                      '02',
                      'Weather conditions',
                      'Add the current environmental conditions.',
                      Icons.wb_sunny_outlined,
                    ),

                    inputCard(
                      title: 'Temperature',
                      hint: 'Enter temperature',
                      unit: '°C',
                      icon: Icons.thermostat_outlined,
                      controller: temperature,
                    ),

                    inputCard(
                      title: 'Humidity',
                      hint: 'Enter humidity',
                      unit: '%',
                      icon: Icons.water_outlined,
                      controller: humidity,
                    ),

                    inputCard(
                      title: 'Rainfall',
                      hint: 'Enter rainfall',
                      unit: 'mm',
                      icon: Icons.cloud_outlined,
                      controller: rainfall,
                    ),

                    const SizedBox(height: 8),

                    // ACTION BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: loading ? null : predictCrop,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              const Color(0xFF17231D),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF17231D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: loading
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 23,
                                    height: 23,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Analyzing your farm...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 21,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'Get AI Recommendation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: TextButton(
                        onPressed: loading ? null : clearAll,
                        child: const Text(
                          'Clear all fields',
                          style: TextStyle(
                            color: Color(0xFF6C7972),
                          ),
                        ),
                      ),
                    ),

                    // RESULT
                    recommendationCard(),

                    const SizedBox(height: 30),

                    // INFO CARDS
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5EDE8),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.psychology_outlined,
                                  color: Color(0xFF1B7F4A),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'AI Model',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Machine learning powered',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5EDE8),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.bolt_outlined,
                                  color: Color(0xFF1B7F4A),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Fast',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Instant crop prediction',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

      const Center(
  child: Column(
    children: [
      Text(
        'CROPWISE AI • SMART AGRICULTURE',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.5,
          color: Color(0xFF9AA59F),
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Developed by SARAN',
        style: TextStyle(
          fontSize: 11,
          color: Color(0xFF9AA59F),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
),             
        ],
    ),
  

),
),
),
),
),
);
}
}                       
                    
                  
                
              
            
          
       
      
    
 

