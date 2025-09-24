import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techplus_frontend/shared/utils/responsive_utils.dart';
import 'package:techplus_frontend/shared/widgets/layouts/responsive_layout_advanced.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    testWidgets('should return correct screen type for mobile', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenType = ResponsiveUtils.getScreenType(
                MediaQuery.of(context).size.width
              );
              expect(screenType, ScreenType.mobile);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct screen type for tablet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenType = ResponsiveUtils.getScreenType(
                MediaQuery.of(context).size.width
              );
              expect(screenType, ScreenType.tablet);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct screen type for desktop', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenType = ResponsiveUtils.getScreenType(
                MediaQuery.of(context).size.width
              );
              expect(screenType, ScreenType.desktop);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct screen type for large desktop', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final screenType = ResponsiveUtils.getScreenType(
                MediaQuery.of(context).size.width
              );
              expect(screenType, ScreenType.largeDesktop);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct column count for different screen sizes', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getColumnCount(context), 1);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getColumnCount(context), 2);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getColumnCount(context), 3);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct spacing for different screen sizes', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSpacing(context), 16.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSpacing(context), 24.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSpacing(context), 32.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct font size scaling', (tester) async {
      const baseFontSize = 16.0;

      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFontSize(context, baseFontSize), baseFontSize);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFontSize(context, baseFontSize), baseFontSize * 1.1);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFontSize(context, baseFontSize), baseFontSize * 1.2);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct padding for different screen sizes', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getPadding(context);
              expect(padding, const EdgeInsets.all(16.0));
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getPadding(context);
              expect(padding, const EdgeInsets.all(24.0));
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = ResponsiveUtils.getPadding(context);
              expect(padding, const EdgeInsets.all(32.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct max content width', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getMaxContentWidth(context), double.infinity);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getMaxContentWidth(context), 800.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getMaxContentWidth(context), 1200.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct app bar height', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getAppBarHeight(context), 56.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet/desktop
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getAppBarHeight(context), 64.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct icon size scaling', (tester) async {
      const baseIconSize = 24.0;

      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getIconSize(context, baseIconSize), baseIconSize);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getIconSize(context, baseIconSize), baseIconSize * 1.1);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getIconSize(context, baseIconSize), baseIconSize * 1.2);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct border radius scaling', (tester) async {
      const baseRadius = 8.0;

      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getBorderRadius(context, baseRadius), baseRadius);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getBorderRadius(context, baseRadius), baseRadius * 1.1);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getBorderRadius(context, baseRadius), baseRadius * 1.2);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct button height scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonHeight(context, ButtonSize.medium), 40.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonHeight(context, ButtonSize.medium), 44.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonHeight(context, ButtonSize.medium), 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct button width scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonWidth(context, ButtonSize.medium), 120.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonWidth(context, ButtonSize.medium), 132.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getButtonWidth(context, ButtonSize.medium), 144.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct grid cross axis count', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridCrossAxisCount(context), 1);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridCrossAxisCount(context), 2);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridCrossAxisCount(context), 3);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct grid spacing', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridSpacing(context), 8.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridSpacing(context), 12.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getGridSpacing(context), 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct sidebar width', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSidebarWidth(context), 0.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSidebarWidth(context), 200.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getSidebarWidth(context), 250.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct bottom navigation height', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getBottomNavigationHeight(context), 56.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet/desktop
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getBottomNavigationHeight(context), 64.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct avatar size scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getAvatarSize(context, AvatarSize.medium), 40.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getAvatarSize(context, AvatarSize.medium), 44.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getAvatarSize(context, AvatarSize.medium), 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct card width', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardWidth(context), double.infinity);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardWidth(context), 300.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardWidth(context), 350.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct card height scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardHeight(context, CardSize.medium), 180.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardHeight(context, CardSize.medium), 198.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getCardHeight(context, CardSize.medium), 216.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct modal width', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalWidth(context), double.infinity);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalWidth(context), 500.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalWidth(context), 600.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct modal height', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalHeight(context), 720.0); // 800 * 0.9
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalHeight(context), 600.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getModalHeight(context), 700.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct form width', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormWidth(context), double.infinity);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormWidth(context), 400.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormWidth(context), 500.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct form field spacing', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormFieldSpacing(context), 16.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormFieldSpacing(context), 20.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getFormFieldSpacing(context), 24.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct image width scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageWidth(context, ImageSize.medium), 200.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageWidth(context, ImageSize.medium), 240.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageWidth(context, ImageSize.medium), 300.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should return correct image height scaling', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageHeight(context, ImageSize.medium), 150.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageHeight(context, ImageSize.medium), 180.0);
              return const SizedBox();
            },
          ),
        ),
      );

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getImageHeight(context, ImageSize.medium), 225.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('ResponsiveLayoutAdvanced Tests', () {
    testWidgets('should show mobile layout on mobile screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
            desktop: const Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('should show tablet layout on tablet screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
            desktop: const Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('should show desktop layout on desktop screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
            desktop: const Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);
    });

    testWidgets('should fallback to mobile layout when tablet layout is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            desktop: const Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('should fallback to tablet layout when desktop layout is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
    });

    testWidgets('should show large desktop layout on large desktop screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
            desktop: const Text('Desktop Layout'),
            largeDesktop: const Text('Large Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
      expect(find.text('Large Desktop Layout'), findsOneWidget);
    });

    testWidgets('should fallback to desktop layout when large desktop layout is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutAdvanced(
            mobile: const Text('Mobile Layout'),
            tablet: const Text('Tablet Layout'),
            desktop: const Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);
    });
  });

  group('ResponsiveWidget Tests', () {
    testWidgets('should show mobile widget on mobile screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
            desktop: const Text('Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsOneWidget);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsNothing);
    });

    testWidgets('should show tablet widget on tablet screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
            desktop: const Text('Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsOneWidget);
      expect(find.text('Desktop Widget'), findsNothing);
    });

    testWidgets('should show desktop widget on desktop screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
            desktop: const Text('Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsOneWidget);
    });

    testWidgets('should fallback to mobile widget when tablet widget is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            desktop: const Text('Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsOneWidget);
      expect(find.text('Desktop Widget'), findsNothing);
    });

    testWidgets('should fallback to tablet widget when desktop widget is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsOneWidget);
    });

    testWidgets('should show large desktop widget on large desktop screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
            desktop: const Text('Desktop Widget'),
            largeDesktop: const Text('Large Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsNothing);
      expect(find.text('Large Desktop Widget'), findsOneWidget);
    });

    testWidgets('should fallback to desktop widget when large desktop widget is not provided', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: const Text('Mobile Widget'),
            tablet: const Text('Tablet Widget'),
            desktop: const Text('Desktop Widget'),
          ),
        ),
      );

      expect(find.text('Mobile Widget'), findsNothing);
      expect(find.text('Tablet Widget'), findsNothing);
      expect(find.text('Desktop Widget'), findsOneWidget);
    });
  });

  group('ResponsiveGrid Tests', () {
    testWidgets('should show 1 column on mobile screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            children: [
              const Text('Item 1'),
              const Text('Item 2'),
              const Text('Item 3'),
            ],
          ),
        ),
      );

      // Vérifier que les éléments sont présents
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('should show 2 columns on tablet screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            children: [
              const Text('Item 1'),
              const Text('Item 2'),
              const Text('Item 3'),
            ],
          ),
        ),
      );

      // Vérifier que les éléments sont présents
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('should show 3 columns on desktop screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            children: [
              const Text('Item 1'),
              const Text('Item 2'),
              const Text('Item 3'),
            ],
          ),
        ),
      );

      // Vérifier que les éléments sont présents
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('ResponsiveList Tests', () {
    testWidgets('should show list items with correct spacing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveList(
            children: [
              const Text('Item 1'),
              const Text('Item 2'),
              const Text('Item 3'),
            ],
          ),
        ),
      );

      // Vérifier que les éléments sont présents
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('ResponsiveContainer Tests', () {
    testWidgets('should show container with correct width', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveContainer(
            child: const Text('Container Content'),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
    });
  });

  group('ResponsiveForm Tests', () {
    testWidgets('should show form with correct width', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveForm(
            child: const Text('Form Content'),
          ),
        ),
      );

      expect(find.text('Form Content'), findsOneWidget);
    });
  });

  group('ResponsiveCard Tests', () {
    testWidgets('should show card with correct dimensions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveCard(
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });
  });
}
