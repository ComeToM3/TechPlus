// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TechPlus';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeUser(String userName) {
    return 'Welcome $userName';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get logout => 'Logout';

  @override
  String get myReservations => 'My Reservations';

  @override
  String get newReservation => 'New Reservation';

  @override
  String get reservations => 'Reservations';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get partySize => 'Party Size';

  @override
  String get createReservation => 'Create Reservation';

  @override
  String get reservationDetails => 'Reservation Details';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get systemOperational => 'System Operational';

  @override
  String get backendFrontendConfigured => 'Backend and Frontend configured';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get selectDate => 'Select a date';

  @override
  String get selectTime => 'Select a time';

  @override
  String get noReservationsFound => 'No reservations found.';

  @override
  String get reservationCreatedSuccessfully =>
      'Reservation created successfully!';

  @override
  String get error => 'Error';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get passwordMinLength => 'Password must contain at least 6 characters';

  @override
  String get pleaseEnterRestaurantName => 'Please enter the restaurant name';

  @override
  String get pleaseSelectDateAndTime => 'Please select a date and time';

  @override
  String get noAccountYet => 'No account yet? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get seeAndManage => 'See and manage';

  @override
  String get createReservationDesc => 'Create a reservation';

  @override
  String get modifyReservation => 'Modify Reservation';

  @override
  String get cancelReservation => 'Cancel Reservation';

  @override
  String get modifyFeatureComing => 'Modification feature coming soon';

  @override
  String get cancelFeatureComing => 'Cancellation feature coming soon';

  @override
  String get loading => 'Loading...';

  @override
  String get restaurantReservationSystem => 'Restaurant reservation system';
}
