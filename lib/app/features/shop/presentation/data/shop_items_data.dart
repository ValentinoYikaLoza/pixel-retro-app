import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';

final List<ShopItemModel> shopItemsData = [
  // Monedas por USD - Mejor relación en paquetes más grandes
  ShopItemModel(
    id: 'coins_1',
    quantity: 100,
    price: 1.99,
    imagePath: 'assets/icons/chest-shop-first.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.monedas,
  ),
  ShopItemModel(
    id: 'coins_2',
    quantity: 300,
    price: 4.99, // Mejor precio por moneda
    imagePath: 'assets/icons/chest-shop-second.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.monedas,
  ),
  ShopItemModel(
    id: 'coins_3',
    quantity: 650,
    price: 9.99, // Mejor relación precio/cantidad
    imagePath: 'assets/icons/chest-shop-third.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.monedas,
  ),
  ShopItemModel(
    id: 'coins_4',
    quantity: 1400,
    price: 19.99, // Mejor oferta
    imagePath: 'assets/icons/chest-shop-third.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.monedas,
  ),

  // Vidas por USD - Precios más atractivos
  ShopItemModel(
    id: 'lives_usd_1',
    quantity: 5,
    price: 1.99,
    imagePath: 'assets/icons/heart.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_usd_2',
    quantity: 15,
    price: 4.99, // Mejor precio por vida
    imagePath: 'assets/icons/group-hearts-second.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_usd_3',
    quantity: 30,
    price: 8.99, // Mejor relación
    imagePath: 'assets/icons/group-hearts-third.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_usd_4',
    quantity: 50,
    price: 14.99,
    imagePath: 'assets/icons/group-hearts-third.svg',
    unit: ShopItemUnit.usd,
    category: ShopItemCategory.vidas,
  ),
  // Vidas por Monedas - Precios consistentes
  ShopItemModel(
    id: 'lives_coins_1',
    quantity: 5,
    price: 120, // 5 vidas * ($0.40/vida) * (60 monedas/$) = 120 monedas
    imagePath: 'assets/icons/heart.svg',
    unit: ShopItemUnit.coins,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_coins_2',
    quantity: 15,
    price: 300, // 15 vidas * ($0.33/vida) * (60 monedas/$) = 300 monedas
    imagePath: 'assets/icons/group-hearts-second.svg',
    unit: ShopItemUnit.coins,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_coins_3',
    quantity: 30,
    price: 540, // 30 vidas * ($0.30/vida) * (60 monedas/$) = 540 monedas
    imagePath: 'assets/icons/group-hearts-third.svg',
    unit: ShopItemUnit.coins,
    category: ShopItemCategory.vidas,
  ),
  ShopItemModel(
    id: 'lives_coins_4',
    quantity: 50,
    price: 900, // 50 vidas * ($0.30/vida) * (60 monedas/$) = 900 monedas
    imagePath: 'assets/icons/group-hearts-third.svg',
    unit: ShopItemUnit.coins,
    category: ShopItemCategory.vidas,
  ),
];
