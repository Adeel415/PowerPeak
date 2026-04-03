import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _navigationCount = 0;
  bool _firstOpenDone = false;

  /// Call once at app startup
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Load an interstitial ad in advance
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              loadInterstitial(); // Pre-load next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Call on each module navigation. Won't show on first app open.
  void tryShowInterstitial() {
    if (!_firstOpenDone) {
      _firstOpenDone = true;
      return;
    }
    _navigationCount++;
    if (_navigationCount % AppConstants.interstitialFrequency == 0 &&
        _isInterstitialLoaded &&
        _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  /// Create a banner ad widget
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

/// Banner widget — place at top or bottom of screens
class PPBannerAd extends StatefulWidget {
  const PPBannerAd({super.key});

  @override
  State<PPBannerAd> createState() => _PPBannerAdState();
}

class _PPBannerAdState extends State<PPBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdsService.instance.createBannerAd()
      ..load().then((_) {
        if (mounted) setState(() => _isLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
