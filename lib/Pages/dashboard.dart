

import 'package:flutter/material.dart';
import 'WelcomePage.dart'; // Import the existing WelcomePage
import 'ColorizeSARPage.dart'; // Import the new ColorizeSARPage

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a background image (optional)
    final backgroundImage = AssetImage(
        'assets/images/dashboard_bg.jpg'); // Ensure you have this image in your assets

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundImage,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1), BlendMode.dstATop),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome to RemSenseAI Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildDashboardCard(
                      context,
                      title: 'Predict Crops',
                      subtitle: 'Identify the crops',
                      icon: Icons.agriculture,
                      color: Colors.green,
                      image: 'assets/images/predict_crops.jpg',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomePage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Colorize SAR',
                      subtitle: 'Colorize SAR Images',
                      icon: Icons.image,
                      color: Colors.blue,
                      image: 'assets/images/colorize_sar.jpg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ColorizeSARPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String image,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(
                  image), // Ensure you have this image in your assets
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4), BlendMode.darken),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 30,
                  child: Icon(
                    icon,
                    size: 30,
                    color: color,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 30,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 10,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
