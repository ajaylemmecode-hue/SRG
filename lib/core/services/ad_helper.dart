import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static const String appID = 'ca-app-pub-4875158489726472~8095722259';
  static const String bannerAdUnitId = 'ca-app-pub-4875158489726472/5190373225';
  static const String interstitialAdUnitId = 'ca-app-pub-4875158489726472/6224129584';
  static const String rewardedInterstitialAdUnitId = 'ca-app-pub-4875158489726472/7792469928';

  static InterstitialAd? _interstitialAd;
  static RewardedInterstitialAd? _rewardedInterstitialAd;

  // 🔹 Interstitial Ad
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (err) => print('❌ Interstitial Ad Load Failed: $err'),
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('⚠️ Interstitial Ad not ready. Loading...');
      loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        print('❌ Interstitial Show Failed: $err');
        ad.dispose();
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // 🔹 Rewarded Interstitial Ad
  static void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewardedInterstitialAd = ad,
        onAdFailedToLoad: (err) => print('❌ Rewarded Interstitial Load Failed: $err'),
      ),
    );
  }

  static void showRewardedInterstitialAd(Function() onUserEarnedReward) {
    if (_rewardedInterstitialAd == null) {
      print('⚠️ Rewarded Interstitial Ad not ready. Loading...');
      loadRewardedInterstitialAd();
      return;
    }

    // // ✅ Correct API for v4.0.0+
    // _rewardedInterstitialAd!.onUserEarnedRewardCallback = (RewardItem reward) {
    //   onUserEarnedReward(); // यूझरला इनाम द्या
    // };

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        print('❌ Rewarded Interstitial Show Failed: $err');
        ad.dispose();
        loadRewardedInterstitialAd();
      },
    );

    // ✅ Required: Pass onUserEarnedReward to show()
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onUserEarnedReward(); // यूझरला इनाम द्या
      },
    );

    _rewardedInterstitialAd = null;
  }
}