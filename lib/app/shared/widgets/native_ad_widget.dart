import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

/// Anuncio **nativo**: se renderiza con una plantilla del SDK estilizada con
/// los colores de la app, así se mezcla con el contenido como un ítem más.
///
/// - `TemplateType.small`: formato compacto, ideal como fila en una lista.
/// - `TemplateType.medium`: formato grande con imagen, ideal como bloque.
///
/// La plantilla incluye su propia insignia "Ad". Si no carga (o no hay ID
/// configurado en release), el widget se colapsa y no deja huecos.
class NativeAdWidget extends StatefulWidget {
  /// Formato compacto (fila de lista).
  const NativeAdWidget.small({super.key, this.margin = _defaultMargin})
    : templateType = TemplateType.small;

  /// Formato grande con imagen (bloque).
  const NativeAdWidget.medium({super.key, this.margin = _defaultMargin})
    : templateType = TemplateType.medium;

  static const _defaultMargin = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  final TemplateType templateType;
  final EdgeInsetsGeometry margin;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  double get _height => widget.templateType == TemplateType.small ? 110 : 320;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final id = AdsService.nativeAdUnitId;
    if (id == null) return; // sin ID en release → no se muestra

    final ad = NativeAd(
      adUnitId: id,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: AppColors.backgroundDark,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.white,
          backgroundColor: AppColors.emerald,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.white,
          size: 14,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.gray,
          size: 12,
        ),
      ),
      listener: NativeAdListener(
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

    _nativeAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _nativeAd;
    if (!_isLoaded || ad == null) return const SizedBox.shrink();

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: _height,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
