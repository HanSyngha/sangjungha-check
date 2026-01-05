import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 테스트 광고 ID (나중에 실제 ID로 교체)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // 실제 광고 ID (AdMob 콘솔에서 발급 후 교체)
  // static const String _bannerId = 'ca-app-pub-XXXX/YYYY';
  // static const String _interstitialId = 'ca-app-pub-XXXX/ZZZZ';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // 상담 횟수 카운터
  int _consultationCount = 0;

  int get consultationCount => _consultationCount;

  // AdMob SDK 초기화
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadInterstitialAd();
  }

  // 배너 광고 ID 반환
  String get bannerAdUnitId => _testBannerId;

  // 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _testInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // 상담 횟수 증가
  void incrementConsultationCount() {
    _consultationCount++;
  }

  // 10회마다 전면 광고 표시 여부 확인
  bool shouldShowInterstitialAd() {
    return _consultationCount > 0 && _consultationCount % 10 == 0;
  }

  // 전면 광고 표시 (10회마다)
  Future<bool> showInterstitialAdIfNeeded() async {
    if (shouldShowInterstitialAd() && _isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    return false;
  }

  // 전면 광고 강제 표시 (조건 무시)
  Future<bool> showInterstitialAd() async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    return false;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
