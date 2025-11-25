import 'package:flutter/material.dart';
import 'package:good_news/features/articles/presentation/screens/home_screen.dart';
import 'package:good_news/widgets/bottom_navigation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 👇 AdHelper तुमच्या main.dart मधून कॉपी करा किंवा तेथे ठेवा
class AdHelper {
  static String get bannerAdUnitId => 'ca-app-pub-4875158489726472/5190373225';
}

class ResponsiveApp extends StatefulWidget {
  const ResponsiveApp({Key? key}) : super(key: key);

  @override
  State<ResponsiveApp> createState() => _ResponsiveAppState();
}

class _ResponsiveAppState extends State<ResponsiveApp> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Banner Ad failed: $err');
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeScreen(),
          if (_isAdLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }
}