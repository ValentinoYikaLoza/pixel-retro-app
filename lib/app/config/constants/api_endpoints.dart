/// Rutas HTTP del backend, centralizadas para evitar strings mágicos
/// dispersos por los datasources.
class ApiEndpoints {
  const ApiEndpoints._();

  // User
  static const String getUser = '/getUser';
  static const String updateCoins = '/updateCoins';
  static const String updateLives = '/updateLives';
  static const String updateStreak = '/updateStreak';
  static const String updateExp = '/updateExp';

  // Home
  static const String listGames = '/listGames';

  // Leaderboard
  static const String listUsers = '/listUsers';
  static const String listDivisions = '/listDivisions';

  // Mission
  static const String listMissions = '/listMissions';
  static const String updateProgress = '/updateProgress';

  // Shop
  static const String listAdvertisements = '/listAdvertisements';
  static const String listCoinShop = '/listCoinShop';
  static const String listLiveShop = '/listLiveShop';
  static const String purchaseAdvertisement = '/purchaseAdvertisement';
  static const String purchaseCoinShopItem = '/purchaseCoinShopItem';
  static const String purchaseLiveShopItem = '/purchaseLiveShopItem';

  // Time
  static const String getTime = '/getTime';
}
