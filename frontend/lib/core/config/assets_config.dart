/// Configuration des assets et icônes
class AssetsConfig {
  // Images du restaurant
  static const String restaurantLogo = 'assets/images/restaurant_logo.png';
  static const String restaurantHero = 'assets/images/restaurant_hero.jpg';
  static const String restaurantInterior = 'assets/images/restaurant_interior.jpg';
  static const String restaurantExterior = 'assets/images/restaurant_exterior.jpg';
  
  // Icônes OAuth
  static const String googleIcon = 'assets/icons/google_icon.png';
  static const String facebookIcon = 'assets/icons/facebook_icon.png';
  static const String appleIcon = 'assets/icons/apple_icon.png';
  
  // Icônes de l'application
  static const String appIcon = 'assets/icons/app_icon.png';
  static const String adminIcon = 'assets/icons/admin_icon.png';
  static const String userIcon = 'assets/icons/user_icon.png';
  static const String reservationIcon = 'assets/icons/reservation_icon.png';
  static const String menuIcon = 'assets/icons/menu_icon.png';
  static const String tableIcon = 'assets/icons/table_icon.png';
  static const String paymentIcon = 'assets/icons/payment_icon.png';
  static const String notificationIcon = 'assets/icons/notification_icon.png';
  
  // Images du menu (exemples)
  static const String menuAppetizer = 'assets/images/menu/appetizer.jpg';
  static const String menuMainCourse = 'assets/images/menu/main_course.jpg';
  static const String menuDessert = 'assets/images/menu/dessert.jpg';
  static const String menuBeverage = 'assets/images/menu/beverage.jpg';
  
  // Images par défaut
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';
  static const String defaultFoodImage = 'assets/images/default_food.png';
  static const String defaultRestaurantImage = 'assets/images/default_restaurant.png';
  
  /// Obtenir tous les assets d'images
  static List<String> get allImageAssets {
    return [
      restaurantLogo,
      restaurantHero,
      restaurantInterior,
      restaurantExterior,
      menuAppetizer,
      menuMainCourse,
      menuDessert,
      menuBeverage,
      defaultUserAvatar,
      defaultFoodImage,
      defaultRestaurantImage,
    ];
  }
  
  /// Obtenir tous les assets d'icônes
  static List<String> get allIconAssets {
    return [
      googleIcon,
      facebookIcon,
      appleIcon,
      appIcon,
      adminIcon,
      userIcon,
      reservationIcon,
      menuIcon,
      tableIcon,
      paymentIcon,
      notificationIcon,
    ];
  }
  
  /// Obtenir tous les assets
  static List<String> get allAssets {
    return [...allImageAssets, ...allIconAssets];
  }
}
