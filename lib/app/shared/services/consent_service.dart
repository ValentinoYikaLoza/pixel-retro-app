import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

/// Gestiona el consentimiento de privacidad (UMP / User Messaging Platform) y,
/// una vez resuelto, inicializa el SDK de anuncios.
///
/// Cumple con GDPR (UE/Reino Unido) y leyes de privacidad de EE. UU.: si el
/// usuario está en una región regulada, muestra el formulario de consentimiento
/// ANTES de cargar anuncios. Para el resto de usuarios el formulario no aparece
/// y los anuncios se cargan con normalidad.
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  bool _adsInitialized = false;

  /// Pide la info de consentimiento, muestra el formulario si hace falta y
  /// luego inicializa los anuncios. No lanza excepciones: ante cualquier error
  /// igual intenta inicializar para no dejar la app sin anuncios.
  void gatherConsentThenInitAds() {
    final params = ConsentRequestParameters(
      // Solo en debug: simula estar en la UE para poder PROBAR el formulario.
      // Además necesitas registrar el ID de tu dispositivo de prueba en
      // [testIdentifiers] (lo imprime el log al correr la app); sin eso, el
      // formulario tampoco aparecerá en debug.
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: const [
                // 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // tu device id de prueba
              ],
            )
          : null,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        // Info de consentimiento actualizada: muestra el formulario si es
        // requerido (p. ej. usuarios de la UE en su primer arranque).
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          // El usuario respondió, no hacía falta el formulario, o hubo un
          // error al mostrarlo: en cualquier caso continuamos.
          _initAdsIfAllowed();
        });
      },
      (FormError error) {
        // Falló la petición de consentimiento: intentamos inicializar igual.
        _initAdsIfAllowed();
      },
    );
  }

  Future<void> _initAdsIfAllowed() async {
    if (_adsInitialized) return;

    // `canRequestAds` es true cuando no se requiere consentimiento o cuando el
    // usuario ya eligió una opción que permite pedir anuncios. Si el usuario
    // rechazó, será false y no inicializamos (no se mostrarán anuncios).
    final canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (!canRequestAds) return;

    _adsInitialized = true;
    await AdsService.instance.initialize();
  }

  /// Solo para pruebas: borra el consentimiento guardado para volver a ver el
  /// formulario en el próximo arranque.
  Future<void> resetForTesting() => ConsentInformation.instance.reset();
}
