import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdType { rewardedCoins, rewardedLives }

class AdsService {
  AdsService._private();

  static final AdsService instance = AdsService._private();

  // ---------------------------------------------------------
  // AD UNIT IDs
  //
  // En modo debug se usan los IDs de prueba oficiales de Google para no
  // infringir las políticas de AdMob. En release se usan los reales.
  //
  // Los formatos que aún no creaste en AdMob quedan con "" en producción:
  // simplemente no se mostrarán en release hasta que pegues su ID real
  // (en debug sí se ven con anuncios de prueba).
  // ---------------------------------------------------------
  static const _prodBannerId = "ca-app-pub-1038083716527611/4373727060";
  static const _prodInterstitialId = "ca-app-pub-1038083716527611/2941333691";
  static const _prodRewardedCoinsId = "ca-app-pub-1038083716527611/4905044257";
  static const _prodRewardedLivesId = "ca-app-pub-1038083716527611/3060645398";
  static const _prodRewardedInterstitialId =
      "ca-app-pub-1038083716527611/6802417922";
  static const _prodNativeId = "ca-app-pub-1038083716527611/2072835429";

  static const _testBannerId = "ca-app-pub-3940256099942544/6300978111";
  static const _testInterstitialId = "ca-app-pub-3940256099942544/1033173712";
  static const _testRewardedId = "ca-app-pub-3940256099942544/5224354917";
  static const _testRewardedInterstitialId =
      "ca-app-pub-3940256099942544/5354046379";
  static const _testNativeId = "ca-app-pub-3940256099942544/2247696110";

  /// Devuelve el ID de prueba en debug, el de producción en release, o `null`
  /// si aún no se configuró (para no servir anuncios de prueba a usuarios
  /// reales ni romper la app).
  static String? _resolveId(String prodId, String testId) {
    if (kDebugMode) return testId;
    return prodId.isEmpty ? null : prodId;
  }

  /// ID del banner (siempre disponible), usado por [InlineBannerAd].
  static String get bannerAdUnitId => _resolveId(_prodBannerId, _testBannerId)!;

  /// ID del nativo, usado por [NativeAdWidget]. Puede ser `null` en release.
  static String? get nativeAdUnitId => _resolveId(_prodNativeId, _testNativeId);

  static String? get _interstitialId =>
      _resolveId(_prodInterstitialId, _testInterstitialId);
  static String? get _rewardedCoinsId =>
      _resolveId(_prodRewardedCoinsId, _testRewardedId);
  static String? get _rewardedLivesId =>
      _resolveId(_prodRewardedLivesId, _testRewardedId);
  static String? get _rewardedInterstitialId =>
      _resolveId(_prodRewardedInterstitialId, _testRewardedInterstitialId);

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ---------------------------------------------------------
  // INTERSTITIAL (pantalla completa en transiciones)
  //
  // Se precarga y se cachea. Al mostrarlo se respeta un límite de frecuencia
  // para que NO aparezca en cada salida ni dos veces seguidas.
  // ---------------------------------------------------------
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  DateTime? _lastInterstitialAt;
  int _interstitialExitCount = 0;

  /// Cada cuántas salidas del juego se permite un interstitial.
  static const _interstitialEveryNExits = 2;

  /// Tiempo mínimo entre dos interstitials.
  static const _interstitialMinGap = Duration(seconds: 60);

  void preloadInterstitial() {
    final id = _interstitialId;
    if (id == null || _interstitial != null || _loadingInterstitial) return;

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Muestra un interstitial en una transición respetando el límite de
  /// frecuencia. SIEMPRE llama a [onDismissed] (se haya mostrado o no), para
  /// que el flujo de navegación continúe.
  void maybeShowInterstitial({required VoidCallback onDismissed}) {
    _interstitialExitCount++;

    final ad = _interstitial;
    final now = DateTime.now();
    final gapOk =
        _lastInterstitialAt == null ||
        now.difference(_lastInterstitialAt!) >= _interstitialMinGap;
    final countOk = _interstitialExitCount % _interstitialEveryNExits == 0;

    if (ad == null || !gapOk || !countOk) {
      preloadInterstitial(); // que esté listo la próxima vez
      onDismissed();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _lastInterstitialAt = DateTime.now();
        preloadInterstitial();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
        onDismissed();
      },
    );

    ad.show();
  }

  // ---------------------------------------------------------
  // REWARDED INTERSTITIAL (premio opcional en una transición)
  // ---------------------------------------------------------
  RewardedInterstitialAd? _rewardedInterstitial;
  bool _loadingRewardedInterstitial = false;

  bool get isRewardedInterstitialReady => _rewardedInterstitial != null;

  void preloadRewardedInterstitial() {
    final id = _rewardedInterstitialId;
    if (id == null ||
        _rewardedInterstitial != null ||
        _loadingRewardedInterstitial) {
      return;
    }

    _loadingRewardedInterstitial = true;
    RewardedInterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitial = ad;
          _loadingRewardedInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          _rewardedInterstitial = null;
          _loadingRewardedInterstitial = false;
        },
      ),
    );
  }

  /// Muestra el rewarded interstitial si está listo. Devuelve `true` si se
  /// mostró. [onReward] se invoca con la cantidad ganada; [onClosed] al cerrar.
  Future<bool> showRewardedInterstitial({
    required void Function(num amount) onReward,
    VoidCallback? onClosed,
  }) async {
    final ad = _rewardedInterstitial;
    if (ad == null) {
      preloadRewardedInterstitial();
      return false;
    }
    _rewardedInterstitial = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewardedInterstitial();
        onClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        preloadRewardedInterstitial();
        onClosed?.call();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onReward(reward.amount);
      },
    );
    return true;
  }

  // ---------------------------------------------------------
  // REWARDED (monedas / vidas) — bajo demanda desde la tienda
  // ---------------------------------------------------------
  Future<RewardedAd?> loadRewardedCoins() => _loadRewarded(_rewardedCoinsId);

  Future<RewardedAd?> loadRewardedLives() => _loadRewarded(_rewardedLivesId);

  Future<RewardedAd?> _loadRewarded(String? id) async {
    if (id == null) return null;

    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (err) => completer.complete(null),
      ),
    );
    return completer.future;
  }

  // ---------------------------------------------------------
  // MÉTODO GENERAL: recibe un tipo y carga el anuncio recompensado correcto
  // ---------------------------------------------------------
  Future<Object?> load(AdType type) {
    switch (type) {
      case AdType.rewardedCoins:
        return loadRewardedCoins();
      case AdType.rewardedLives:
        return loadRewardedLives();
    }
  }
}
