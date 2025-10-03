import 'package:intl/intl.dart';

/// Utilitaires de formatage pour le Canada (Québec)
class CanadianFormatters {
  // Formatage de la devise canadienne
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fr_CA',
    symbol: '\$ CAD',
    decimalDigits: 2,
  );

  // Formatage des dates pour le Québec
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'fr_CA');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'fr_CA');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_CA');

  /// Formate un montant en dollars canadiens
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formate un montant en dollars canadiens (version compacte)
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M \$ CAD';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K \$ CAD';
    } else {
      return '${amount.toStringAsFixed(0)} \$ CAD';
    }
  }

  /// Formate une date au format québécois
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formate une heure au format québécois
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Formate une date et heure au format québécois
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formate un pourcentage au format québécois
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)} %';
  }

  /// Formate un nombre avec séparateurs de milliers
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'fr_CA').format(number);
  }

  /// Formate un nombre décimal avec séparateurs
  static String formatDecimal(double number, {int decimals = 2}) {
    return NumberFormat('#,###.${'#' * decimals}', 'fr_CA').format(number);
  }
}
