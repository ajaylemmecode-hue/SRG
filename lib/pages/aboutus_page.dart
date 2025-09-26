import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 Header Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Suvarnraj Group Cleaning Services",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "Founded in 2010, Premium Cleaning Services has established itself "
                        "as the leading provider of professional cleaning solutions for homes and businesses. "
                        "With our team of highly trained professionals and state-of-the-art equipment, "
                        "we deliver spotless results that exceed expectations.",
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our comprehensive range of services includes Furnished & Unfurnished Home Cleaning, "
                        "Commercial cleaning, Deep cleaning, Bathroom cleaning, Office cleaning, "
                        "and specialized services tailored to your specific needs.",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Mission & Vision
            const Text("Our Mission & Vision",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            _infoCard(
              title: "Our Mission",
              description:
              "To provide exceptional cleaning services that enhance the quality of life for our clients by creating cleaner, healthier, and more comfortable environments while maintaining the highest standards of professionalism and reliability.\n\n"
                  "Our goal is to build lasting relationships grounded in trust, excellence, and satisfaction.",
            ),
            const SizedBox(height: 12),
            _infoCard(
              title: "Our Vision",
              description:
              "We have been in this business since 2005, serving clients for more than a decade. "
                  "We understand your hectic schedule and ensure that you feel relaxed when your environment stays clean and healthy.\n\n"
                  "All we can say is: 'Hold my broom, and see me eradicate your discomfort.'",
            ),

            const SizedBox(height: 20),

            // 🔹 Why Choose Us
            const Text("Why Choose Us?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _bulletPoint("Trained Professionals",
                "Verified and experienced cleaning experts"),
            _bulletPoint("Punctual Service", "Always on time, every time"),
            _bulletPoint("Quality Guaranteed",
                "100% satisfaction or money back"),
            _bulletPoint("Eco-Friendly Products",
                "Safe for your family and environment"),

            const SizedBox(height: 20),

            // 🔹 Call to Action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.red]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Ready to Get Started?",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Contact us today for a free consultation and quote",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {},
                        icon: const Icon(Icons.call, color: Colors.red),
                        label: const Text("Call Now",
                            style: TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () {},
                        icon: const Icon(Icons.message, color: Colors.red),
                        label: const Text("Message",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ✅ Helper Widget for Info Cards
  static Widget _infoCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // ✅ Helper Widget for Bullet Points
  static Widget _bulletPoint(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
    );
  }
}
