import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

/// Banner publicitario reutilizable, no intrusivo y claramente etiquetado.
///
/// Sigue las prácticas que usan las apps profesionales:
/// - Usa un banner **adaptable** ("anchored adaptive") que se ajusta al ancho
///   disponible en lugar de un tamaño fijo pequeño.
/// - Muestra una etiqueta "ANUNCIO" para ser transparente con el usuario
///   (recomendado por las políticas de AdMob y de las tiendas).
/// - Si el anuncio no carga, el widget se **colapsa** y no deja huecos vacíos.
/// - Gestiona su propio ciclo de vida (carga y `dispose`), por lo que se puede
///   colocar en cualquier pantalla de forma independiente.
class InlineBannerAd extends StatefulWidget {
  const InlineBannerAd({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  /// Margen externo del contenedor del anuncio.
  final EdgeInsetsGeometry margin;

  @override
  State<InlineBannerAd> createState() => _InlineBannerAdState();
}

class _InlineBannerAdState extends State<InlineBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se carga una sola vez, cuando ya hay un MediaQuery disponible.
    if (!_requested) {
      _requested = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final double horizontalMargin = widget.margin
        .resolve(TextDirection.ltr)
        .horizontal;

    // Restamos el margen y el borde para que el banner quepa dentro del
    // contenedor sin desbordarse.
    final int adWidth =
        (MediaQuery.of(context).size.width - horizontalMargin - 4).truncate();

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);

    if (size == null || !mounted) return;

    final banner = BannerAd(
      adUnitId: AdsService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;

    // Mientras no haya anuncio cargado, no ocupa espacio.
    if (!_isLoaded || ad == null) return const SizedBox.shrink();

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: AppColors.selector,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Etiqueta "ANUNCIO" para transparencia con el usuario.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ANUNCIO',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
