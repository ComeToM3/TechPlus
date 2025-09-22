// coverage_helper.dart
// Helper file to ensure all files are included in coverage reports

// Core
import 'package:techplus_frontend/core/constants/app_constants.dart';
import 'package:techplus_frontend/core/constants/theme_constants.dart';
import 'package:techplus_frontend/core/theme/app_theme.dart';
import 'package:techplus_frontend/core/network/api_client.dart';
import 'package:techplus_frontend/core/providers/app_providers.dart';
import 'package:techplus_frontend/core/providers/theme_provider.dart';
import 'package:techplus_frontend/core/providers/locale_provider.dart';
import 'package:techplus_frontend/core/navigation/app_router.dart';
import 'package:techplus_frontend/core/accessibility/accessibility_constants.dart';
import 'package:techplus_frontend/core/accessibility/accessibility_utils.dart';
import 'package:techplus_frontend/core/accessibility/screen_reader_service.dart';

// Features
import 'package:techplus_frontend/features/auth/presentation/providers/auth_providers.dart';
import 'package:techplus_frontend/features/reservation/presentation/providers/reservation_providers.dart';

// Shared
import 'package:techplus_frontend/shared/widgets/layouts/bento_card.dart';
import 'package:techplus_frontend/shared/widgets/buttons/animated_button.dart';
import 'package:techplus_frontend/shared/widgets/accessibility/accessible_button.dart';
import 'package:techplus_frontend/shared/widgets/accessibility/accessible_text_field.dart';
import 'package:techplus_frontend/shared/widgets/accessibility/keyboard_navigation.dart';

// Pages
import 'package:techplus_frontend/core/pages/splash_page.dart';
import 'package:techplus_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:techplus_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:techplus_frontend/features/reservation/presentation/pages/reservation_list_page.dart';
import 'package:techplus_frontend/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:techplus_frontend/features/reservation/presentation/pages/create_reservation_page.dart';

// Main
import 'package:techplus_frontend/main.dart';

void main() {
  // This file is only used to ensure all files are included in coverage reports
  // It doesn't need to do anything else
}
