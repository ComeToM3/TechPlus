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
  String get newReservation => 'New reservation';

  @override
  String get reservations => 'Reservations';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get restaurantSlogan => 'An exceptional culinary experience';

  @override
  String get bookNow => 'Book now';

  @override
  String get ourServices => 'Our Services';

  @override
  String get onlineReservation => 'Online reservation';

  @override
  String get onlineReservationDescription =>
      'Book your table 24/7 from our website';

  @override
  String get diverseMenu => 'Diverse menu';

  @override
  String get diverseMenuDescription =>
      'Discover our menu with exceptional dishes';

  @override
  String get premiumService => 'Premium service';

  @override
  String get premiumServiceDescription =>
      'A personalized service for your comfort';

  @override
  String get menuPreview => 'Menu Preview';

  @override
  String get viewFullMenu => 'View full menu';

  @override
  String get readyForUniqueExperience =>
      'Ready for a unique culinary experience?';

  @override
  String get bookTableNow =>
      'Book your table now and discover our exceptional cuisine';

  @override
  String get bookTable => 'Book a table';

  @override
  String get menu => 'Menu';

  @override
  String get about => 'About';

  @override
  String get contact => 'Contact';

  @override
  String get copyright => '© 2025 TechPlus Restaurant. All rights reserved.';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get dashboardOverview => 'Overview of your restaurant';

  @override
  String get viewReservations => 'View reservations';

  @override
  String get refresh => 'Refresh';

  @override
  String get settings => 'Settings';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get retry => 'Retry';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noDataDescription =>
      'Metrics will appear here once you have reservations';

  @override
  String get mainMetrics => 'Main Metrics';

  @override
  String get todayReservations => 'Today\'s reservations';

  @override
  String get todayRevenue => 'Today\'s revenue';

  @override
  String get tableOccupancy => 'Table occupancy';

  @override
  String get pendingReservations => 'Pending reservations';

  @override
  String get additionalMetrics => 'Additional metrics';

  @override
  String get totalReservations => 'Total Reservations';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalCustomers => 'Total customers';

  @override
  String get newCustomers => 'New customers';

  @override
  String get trendsAndAnalytics => 'Trends and analytics';

  @override
  String get chartsComingSoon => 'Charts coming soon';

  @override
  String get tableStatus => 'Table status';

  @override
  String get viewAll => 'View all';

  @override
  String get tableMapComingSoon => 'Table map coming soon';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get pending => 'Pending';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get total => 'Total';

  @override
  String get reservationsTodaySummary => 'Today\'s reservations summary';

  @override
  String get occupied => 'Occupied';

  @override
  String get available => 'Available';

  @override
  String get highOccupancy => 'High occupancy - Consider adding tables';

  @override
  String get goodOccupancy => 'Good occupancy - Optimal performance';

  @override
  String get moderateOccupancy => 'Moderate occupancy - Room for improvement';

  @override
  String get lowOccupancy => 'Low occupancy - Marketing actions recommended';

  @override
  String get revenue => 'Revenue';

  @override
  String revenueGrowthPositive(String percentage) {
    return 'Growth of $percentage% compared to average';
  }

  @override
  String revenueGrowthNegative(String percentage) {
    return 'Decrease of $percentage% compared to average';
  }

  @override
  String get revenueSummary => 'Revenue analysis and trends';

  @override
  String get topTables => 'Popular tables';

  @override
  String get seats => 'seats';

  @override
  String get topTablesSummary => 'Ranking of most requested tables';

  @override
  String get detailedMetrics => 'Detailed Metrics';

  @override
  String get totalTables => 'Total Tables';

  @override
  String get averageRevenue => 'Average revenue';

  @override
  String get reservationCalendar => 'Reservation Calendar';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get daily => 'Daily';

  @override
  String reservationsForDate(String day, String month) {
    return 'Reservations for $day/$month';
  }

  @override
  String get noReservationsForDate => 'No reservations for this date';

  @override
  String get people => 'people';

  @override
  String get table => 'Table';

  @override
  String get reservationManagement => 'Reservation Management';

  @override
  String get filters => 'Filters';

  @override
  String get confirmedReservations => 'Confirmed Reservations';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get export => 'Export';

  @override
  String get close => 'Close';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get searchReservations => 'Search reservations...';

  @override
  String get status => 'Status';

  @override
  String get tables => 'Tables';

  @override
  String get dateRange => 'Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String selectedItems(String count) {
    return '$count items selected';
  }

  @override
  String get changeStatus => 'Change Status';

  @override
  String get assignTable => 'Assign Table';

  @override
  String get unassignTable => 'Unassign Table';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get sendConfirmation => 'Send Confirmation';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get selectAll => 'Select All';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete this reservation?';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csvDescription => 'Excel Compatible';

  @override
  String get excelDescription => 'Excel File';

  @override
  String get pdfDescription => 'PDF Document';

  @override
  String get exportPeriod => 'Export Period';

  @override
  String get includeFields => 'Include Fields';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get includeCancelled => 'Include Cancelled';

  @override
  String get includeCompleted => 'Include Completed';

  @override
  String get preview => 'Preview';

  @override
  String get reservationList => 'Reservation List';

  @override
  String get errorLoadingReservations => 'Error loading reservations';

  @override
  String get noReservations => 'No Reservations';

  @override
  String get noReservationsDescription =>
      'Start by creating your first reservation';

  @override
  String get view => 'View';

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get editReservation => 'Edit Reservation';

  @override
  String get deleteReservation => 'Delete Reservation';

  @override
  String get clientInformation => 'Client Information';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get noContactInfo => 'No contact information';

  @override
  String get noContactInfoDescription => 'No email or phone provided';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get call => 'Call';

  @override
  String get modificationHistory => 'Modification History';

  @override
  String get noHistory => 'No History';

  @override
  String get noHistoryDescription => 'No modifications recorded';

  @override
  String get by => 'By';

  @override
  String get now => 'Now';

  @override
  String get internalNotes => 'Internal Notes';

  @override
  String get noNotes => 'No Notes';

  @override
  String get noNotesDescription => 'Add notes to track details';

  @override
  String get addNote => 'Add Note';

  @override
  String get noteType => 'Note Type';

  @override
  String get noteContent => 'Note Content';

  @override
  String get noteContentHint => 'Enter your note...';

  @override
  String get privateNote => 'Private Note';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirmation =>
      'Are you sure you want to delete this note?';

  @override
  String get noteContentRequired => 'Note content is required';

  @override
  String get availableActions => 'Available Actions';

  @override
  String get mainActions => 'Main Actions';

  @override
  String get statusActions => 'Status Actions';

  @override
  String get communication => 'Communication';

  @override
  String get management => 'Management';

  @override
  String get sendSms => 'Send SMS';

  @override
  String get changeTime => 'Change Time';

  @override
  String get selectClient => 'Select Client';

  @override
  String get searchClient => 'Search Client';

  @override
  String get searchClientHint => 'Name, email or phone...';

  @override
  String get selected => 'Selected';

  @override
  String get noClients => 'No Clients';

  @override
  String get noClientsDescription => 'Start by adding clients';

  @override
  String get noClientsFound => 'No clients found';

  @override
  String get noClientsFoundDescription => 'Try with other keywords';

  @override
  String get newClient => 'New Client';

  @override
  String get selectAvailability => 'Select Availability';

  @override
  String get selectDate => 'Select a date';

  @override
  String get availableSlots => 'Available Slots';

  @override
  String get noSlotsAvailable => 'No slots available';

  @override
  String get noSlotsAvailableDescription => 'Try another date';

  @override
  String availabilityInfo(String partySize) {
    return 'Available slots for $partySize people';
  }

  @override
  String get reservationInformation => 'Reservation Information';

  @override
  String get valid => 'Valid';

  @override
  String get incomplete => 'Incomplete';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientNameHint => 'Full client name';

  @override
  String get clientNameRequired => 'Client name is required';

  @override
  String get partySizeHint => 'Number of people';

  @override
  String get partySizeRequired => 'Party size is required';

  @override
  String get partySizeInvalid => 'Invalid party size (1-20)';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get emailInvalid => 'Invalid email format';

  @override
  String get phoneHint => '+1 555 123 4567';

  @override
  String get specialRequestsHint => 'Client special requests...';

  @override
  String get adminNotes => 'Admin Notes';

  @override
  String get adminNotesHint => 'Internal notes for team...';

  @override
  String get validate => 'Validate';

  @override
  String get clear => 'Clear';

  @override
  String get formValidated => 'Form validated';

  @override
  String get formValidationFailed => 'Form validation failed';

  @override
  String get createReservationDescription =>
      'Create a new reservation for a client';

  @override
  String get fillInformation => 'Fill Information';

  @override
  String get finalActions => 'Final Actions';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get formIncomplete => 'Form incomplete';

  @override
  String get reservationCreated => 'Reservation created successfully';

  @override
  String get cancelConfirmation => 'Are you sure you want to cancel?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get tableManagement => 'Table Management';

  @override
  String get scheduleManagement => 'Gestion des Créneaux';

  @override
  String get scheduleConfiguration => 'Configuration des Créneaux';

  @override
  String get scheduleConfigurationDescription =>
      'Configurez les créneaux horaires de votre restaurant pour chaque jour de la semaine';

  @override
  String get schedule => 'Créneaux';

  @override
  String get timeSlots => 'Créneaux horaires';

  @override
  String get addTimeSlot => 'Ajouter un créneau';

  @override
  String get editTimeSlot => 'Modifier le créneau';

  @override
  String get timeSlotCreated => 'Créneau créé avec succès';

  @override
  String get timeSlotUpdated => 'Créneau modifié avec succès';

  @override
  String get time => 'Time';

  @override
  String get capacity => 'Capacité';

  @override
  String get recommended => 'Recommandé';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Notes internes pour l\'équipe';

  @override
  String get slotConfiguration => 'Configuration du créneau';

  @override
  String get durationSettings => 'Paramètres de durée';

  @override
  String get bookingSettings => 'Paramètres de réservation';

  @override
  String get bookingOptions => 'Options de réservation';

  @override
  String get slotDuration => 'Durée des créneaux';

  @override
  String get slotDurationDescription =>
      'Durée standard d\'un créneau en minutes';

  @override
  String get bufferTime => 'Temps de pause';

  @override
  String get bufferTimeDescription =>
      'Temps de pause entre les créneaux en minutes';

  @override
  String get maxAdvanceBooking => 'Réservation avancée max';

  @override
  String get maxAdvanceBookingDescription =>
      'Nombre maximum de jours à l\'avance pour réserver';

  @override
  String get minAdvanceBooking => 'Réservation minimale';

  @override
  String get minAdvanceBookingDescription =>
      'Nombre minimum d\'heures à l\'avance pour réserver';

  @override
  String get allowSameDayBooking => 'Autoriser les réservations du jour';

  @override
  String get allowSameDayBookingDescription =>
      'Permettre aux clients de réserver le jour même';

  @override
  String get allowWeekendBooking => 'Autoriser les réservations weekend';

  @override
  String get allowWeekendBookingDescription =>
      'Permettre aux clients de réserver le weekend';

  @override
  String get scheduleSaved => 'Configuration sauvegardée';

  @override
  String get settingsSaved => 'Paramètres sauvegardés';

  @override
  String get errorLoadingSchedule =>
      'Erreur lors du chargement de la configuration';

  @override
  String get totalDays => 'Jours total';

  @override
  String get openDays => 'Jours ouverts';

  @override
  String get totalSlots => 'Créneaux total';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get copySchedule => 'Copier la configuration';

  @override
  String get resetSchedule => 'Réinitialiser la configuration';

  @override
  String get resetScheduleConfirmation =>
      'Êtes-vous sûr de vouloir réinitialiser la configuration ? Cette action est irréversible.';

  @override
  String get exportSchedule => 'Exporter la configuration';

  @override
  String get importSchedule => 'Importer la configuration';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get invalidTimeFormat => 'Format d\'heure invalide (HH:MM)';

  @override
  String get invalidCapacity => 'Capacité invalide';

  @override
  String get capacityTooHigh => 'Capacité trop élevée (max 100)';

  @override
  String get invalidValue => 'Valeur invalide';

  @override
  String get actions => 'Actions';

  @override
  String get all => 'Tous';

  @override
  String get interactiveLayout => 'Plan interactif';

  @override
  String get viewMode => 'Mode consultation';

  @override
  String get editMode => 'Mode édition';

  @override
  String get resetView => 'Réinitialiser la vue';

  @override
  String get addTable => 'Ajouter une table';

  @override
  String get entrance => 'Entrée';

  @override
  String get noPosition => 'Aucune position';

  @override
  String get reserved => 'Réservée';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get outOfOrder => 'Hors service';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get activeTables => 'Tables actives';

  @override
  String get tablePerformance => 'Performance des tables';

  @override
  String get usageCharts => 'Graphiques d\'utilisation';

  @override
  String get chartsDescription =>
      'Visualisation des données d\'utilisation des tables';

  @override
  String get tableCreated => 'Table créée avec succès';

  @override
  String get tableUpdated => 'Table modifiée avec succès';

  @override
  String get tableNumber => 'Numéro de table';

  @override
  String get invalidNumber => 'Numéro invalide';

  @override
  String get position => 'Position';

  @override
  String get positionHint => 'Ex: A1, B2, Terrasse';

  @override
  String get statusAndConfiguration => 'Statut et configuration';

  @override
  String get activeTable => 'Table active';

  @override
  String get availabilityStatus => 'Statut de disponibilité';

  @override
  String get create => 'Créer';

  @override
  String get createTable => 'Create Table';

  @override
  String get editTable => 'Edit Table';

  @override
  String get deleteTable => 'Delete Table';

  @override
  String deleteTableConfirmation(String number) {
    return 'Are you sure you want to delete table $number?';
  }

  @override
  String get searchTables => 'Search tables...';

  @override
  String get noTables => 'No Tables';

  @override
  String get noTablesDescription => 'Start by creating tables';

  @override
  String get noTablesFound => 'No tables found';

  @override
  String get noTablesFoundDescription => 'Try with other criteria';

  @override
  String get errorLoadingTables => 'Loading Error';

  @override
  String get restaurantLayout => 'Restaurant Layout';

  @override
  String get layoutActions => 'Layout Actions';

  @override
  String get editLayout => 'Edit Layout';

  @override
  String get resetLayout => 'Reset Layout';

  @override
  String get errorLoadingLayout => 'Layout loading error';

  @override
  String get noLayout => 'No Layout';

  @override
  String get noLayoutDescription => 'Create a layout for your restaurant';

  @override
  String get layoutSaved => 'Layout saved';

  @override
  String get generalStatistics => 'General Statistics';

  @override
  String get tableStatistics => 'Table Statistics';

  @override
  String get availableTables => 'Available Tables';

  @override
  String get occupiedTables => 'Occupied Tables';

  @override
  String get totalCapacity => 'Total Capacity';

  @override
  String get occupancy => 'Occupancy';

  @override
  String get noStatistics => 'No statistics available';

  @override
  String get bulkActions => 'Bulk Actions';

  @override
  String get list => 'List';

  @override
  String get layout => 'Layout';

  @override
  String get statistics => 'Statistics';

  @override
  String get menuManagement => 'Menu Management';

  @override
  String get createMenuItem => 'Create Menu Item';

  @override
  String get editMenuItem => 'Edit Menu Item';

  @override
  String get deleteMenuItem => 'Delete Menu Item';

  @override
  String deleteMenuItemConfirmation(String name) {
    return 'Are you sure you want to delete menu item $name?';
  }

  @override
  String get searchMenuItems => 'Search menu items...';

  @override
  String get noMenuItems => 'No Menu Items';

  @override
  String get noMenuItemsDescription => 'Start by creating menu items';

  @override
  String get noMenuItemsFound => 'No menu items found';

  @override
  String get noMenuItemsFoundDescription => 'Try with other criteria';

  @override
  String get errorLoadingMenuItems => 'Loading Error';

  @override
  String get makeAvailable => 'Make Available';

  @override
  String get makeUnavailable => 'Make Unavailable';

  @override
  String get availableOnly => 'Available only';

  @override
  String get allCategories => 'All Categories';

  @override
  String get menuItems => 'Menu Items';

  @override
  String get categories => 'Categories';

  @override
  String get images => 'Images';

  @override
  String get createCategory => 'Create Category';

  @override
  String get categoryActions => 'Category Actions';

  @override
  String get reorderCategories => 'Reorder Categories';

  @override
  String get noCategories => 'No Categories';

  @override
  String get noCategoriesDescription => 'Start by creating categories';

  @override
  String get imageManagement => 'Image Management';

  @override
  String get imageManagementDescription => 'Manage your menu images';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get optimizeImages => 'Optimize Images';

  @override
  String get popularItems => 'Popular Items';

  @override
  String get popularCategories => 'Popular Categories';

  @override
  String get noPopularItems => 'No popular items';

  @override
  String get noPopularCategories => 'No popular categories';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get markNoShow => 'Mark No-Show';

  @override
  String get reopen => 'Reopen';

  @override
  String get restore => 'Restore';

  @override
  String get specialRequests => 'Special requests';

  @override
  String get completed => 'Completed';

  @override
  String get noShow => 'No show';

  @override
  String get search => 'Search';

  @override
  String get phone => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get restaurantConfiguration => 'Restaurant Configuration';

  @override
  String get generalInformation => 'General Information';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get paymentSettings => 'Payment Settings';

  @override
  String get cancellationPolicy => 'Cancellation Policy';

  @override
  String get description => 'Description';

  @override
  String get address => 'Address';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get country => 'Country';

  @override
  String get website => 'Website';

  @override
  String get requiredField => 'Required field';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get configurationSaved => 'Configuration saved';

  @override
  String get configureOpeningHours => 'Configure opening hours';

  @override
  String get openTime => 'Opening time';

  @override
  String get closeTime => 'Closing time';

  @override
  String get lunchBreak => 'Lunch break';

  @override
  String get breakStart => 'Break start';

  @override
  String get breakEnd => 'Break end';

  @override
  String get openingHoursSaved => 'Opening hours saved';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get stripe => 'Stripe';

  @override
  String get stripeDescription => 'Card payment via Stripe';

  @override
  String get stripePublicKey => 'Stripe public key';

  @override
  String get stripeSecretKey => 'Stripe secret key';

  @override
  String get paypal => 'PayPal';

  @override
  String get paypalDescription => 'Payment via PayPal';

  @override
  String get paypalClientId => 'PayPal client ID';

  @override
  String get cash => 'Cash';

  @override
  String get cashDescription => 'Cash payment';

  @override
  String get card => 'Card';

  @override
  String get cardDescription => 'Card payment';

  @override
  String get financialSettings => 'Financial Settings';

  @override
  String get depositPercentage => 'Deposit percentage';

  @override
  String get taxRate => 'Tax rate';

  @override
  String get taxIncluded => 'Tax included';

  @override
  String get taxIncludedDescription => 'Tax is included in the price';

  @override
  String get currency => 'Currency';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get invalidPercentage => 'Invalid percentage';

  @override
  String get paymentSettingsSaved => 'Payment settings saved';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get refundable => 'Refundable';

  @override
  String get refundableDescription => 'Reservations can be refunded';

  @override
  String get freeCancellationHours => 'Free cancellation (hours)';

  @override
  String get hours => 'hours';

  @override
  String get invalidHours => 'Invalid number of hours';

  @override
  String get cancellationFeePercentage => 'Cancellation fee percentage';

  @override
  String get policyDescription => 'Policy description';

  @override
  String get cancellationRules => 'Cancellation Rules';

  @override
  String get addRule => 'Add rule';

  @override
  String get noRules => 'No rules defined';

  @override
  String get rule => 'Rule';

  @override
  String get hoursBeforeReservation => 'Hours before reservation';

  @override
  String get feePercentage => 'Fee percentage';

  @override
  String get cancellationPolicySaved => 'Cancellation policy saved';

  @override
  String get analytics => 'Analytics';

  @override
  String get mainKPIs => 'Main KPIs';

  @override
  String get mainKPIsDescription => 'Key performance indicators';

  @override
  String get averageOrderValue => 'Average Order Value';

  @override
  String get occupancyRate => 'Occupancy Rate';

  @override
  String get cancellationRate => 'Cancellation Rate';

  @override
  String get noShowRate => 'No-Show Rate';

  @override
  String get viewDetails => 'View Details';

  @override
  String get loadingKPIs => 'Loading KPIs...';

  @override
  String get errorLoadingKPIs => 'Error loading KPIs';

  @override
  String get evolutionMetrics => 'Evolution Metrics';

  @override
  String get evolutionMetricsDescription => 'Metrics evolution over time';

  @override
  String get viewMore => 'View More';

  @override
  String get loadingEvolution => 'Loading evolution...';

  @override
  String get errorLoadingEvolution => 'Error loading evolution';

  @override
  String get comparisonData => 'Comparison Data';

  @override
  String get comparisonDataDescription => 'Performance comparison';

  @override
  String get comparisonDetails => 'Comparison Details';

  @override
  String get loadingComparison => 'Loading comparison...';

  @override
  String get errorLoadingComparison => 'Error loading comparison';

  @override
  String get predictions => 'Predictions';

  @override
  String get predictionsDescription => 'Predictions based on historical data';

  @override
  String get predictionDetails => 'Prediction Details';

  @override
  String get loadingPredictions => 'Loading predictions...';

  @override
  String get errorLoadingPredictions => 'Error loading predictions';

  @override
  String get analyticsOverview => 'Analytics Overview';

  @override
  String get analyticsOverviewDescription =>
      'Complete restaurant performance analysis';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get configureFilters => 'Configure Filters';

  @override
  String get exportInProgress => 'Export in progress...';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get apply => 'Apply';

  @override
  String get saving => 'Saving...';

  @override
  String get date => 'Date';

  @override
  String get partySize => 'Party Size';

  @override
  String get createReservation => 'Create Reservation';

  @override
  String get reservationDetails => 'Reservation Details';

  @override
  String get systemOperational => 'System Operational';

  @override
  String get backendFrontendConfigured => 'Backend and Frontend configured';

  @override
  String get toggleTheme => 'Toggle theme';

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

  @override
  String get reports => 'Reports';

  @override
  String get reportFilters => 'Report Filters';

  @override
  String get reportFiltersDescription =>
      'Configure filters to generate your report';

  @override
  String get reportType => 'Report Type';

  @override
  String get custom => 'Custom';

  @override
  String get reservationStatus => 'Reservation Status';

  @override
  String get options => 'Options';

  @override
  String get includeNoShow => 'Include No-Show';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get reportMetrics => 'Report Metrics';

  @override
  String get reportMetricsDescription => 'Detailed report metrics';

  @override
  String get cancelledReservations => 'Cancelled Reservations';

  @override
  String get noShowReservations => 'No-Show Reservations';

  @override
  String get totalGuests => 'Total Guests';

  @override
  String get averageReservationValue => 'Average Reservation Value';

  @override
  String get reservationsChart => 'Reservations Chart';

  @override
  String get reservationsChartDescription => 'Evolution of reservation count';

  @override
  String get revenueChart => 'Revenue Chart';

  @override
  String get revenueChartDescription => 'Revenue evolution';

  @override
  String get tablesChart => 'Tables Chart';

  @override
  String get tablesChartDescription => 'Performance by table';

  @override
  String get reportActions => 'Report Actions';

  @override
  String get saveReport => 'Save Report';

  @override
  String get exportPDF => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportCSV => 'Export CSV';

  @override
  String get generatingReport => 'Generating report...';

  @override
  String get errorGeneratingReport => 'Error generating report';

  @override
  String get reportSaved => 'Report saved';

  @override
  String get averagePartySize => 'Average party size';
}
