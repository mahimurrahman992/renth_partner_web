import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:renth_manager/consts/color.dart';
import 'package:renth_manager/controller/quick_tech_dashboard_controller.dart';
import 'package:renth_manager/controller/quick_tech_post_property_controller.dart';
import 'package:renth_manager/controller/quick_tech_profile_controller.dart';
import 'package:renth_manager/locator.dart';
import 'package:renth_manager/page/home/quick_tech_home_page.dart';
import 'package:renth_manager/page/profile_page/quick_tech_profile_page.dart';
import 'package:renth_manager/page/property_list/quick_tech_property_list_page.dart';
import 'package:renth_manager/page/quick_tech_room_management/quick_tech_room_management_screen.dart';
import 'package:renth_manager/page/recent_booking/quick_tech_recent_booking_screen.dart';
import 'package:renth_manager/widgets/appar/quick_tech_custom_appbar.dart';
import 'package:renth_manager/widgets/custom_responsive_helper.dart';
import 'package:renth_manager/widgets/custom_welcome_popup.dart';
import 'package:renth_manager/widgets/drawer/quick_tech_custom_drawer.dart';

class QuickTechDashboard extends StatefulWidget {
  const QuickTechDashboard({super.key});

  @override
  State<QuickTechDashboard> createState() => _QuickTechDashboardState();
}

class _QuickTechDashboardState extends State<QuickTechDashboard> {
  final dashBoardController = locator.get<DashboardController>();
  final ProfileController profileController = Get.put(ProfileController());
  final PostPropertyController postPropertyController = Get.put(PostPropertyController());

  final List<Widget> navBody = [
    const QuickTechHomePage(),
    QuickTechRoomManagementScreen(),
    const QuickTechPropertyListPage(),
    const QuickTechRecentBookingScreen(),
    const QuickTechProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    profileController.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await dashBoardController.onWillPop(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = Responsive.isMobile(context) || constraints.maxWidth < 768;

          if (isMobile) {
            // =========================================================
            // MOBILE LAYOUT:
            // Top Appbar + Content + Curved Bottom Nav + Slide Drawer
            // =========================================================
            return CustomWelcomePopup(
              child: Scaffold(
                key: dashBoardController.scaffoldKey,
                drawer: const CustomDrawer(isPermanentSidebar: false),
                backgroundColor: backgroundColor,
                body: SafeArea(
                  child: Column(
                    children: [
                      customAppbar(context),
                      Expanded(
                        child: Obx(
                          () => navBody.elementAt(
                            dashBoardController.currentIndex.value,
                          ),
                        ).animate().fadeIn(duration: 250.ms),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Obx(() {
                  return QuickTechCurvedNavBar(
                    selectedIndex: dashBoardController.currentIndex.value,
                    icons: const [
                      Icons.grid_view_rounded,
                      Icons.bed_rounded,
                      Icons.add_home_rounded,
                      Icons.receipt_long_outlined,
                      Icons.person_pin_rounded,
                    ],
                    onTap: dashBoardController.onItemTapped,
                  );
                }),
              ),
            );
          } else {
            // =========================================================
            // TABLET & DESKTOP LAYOUT:
            // Permanent Left Sidebar + Top Bar with TextButtons (NO Bottom Nav)
            // =========================================================
            return CustomWelcomePopup(
              child: Scaffold(
                backgroundColor: backgroundColor,
                body: Row(
                  children: [
                    // Permanent Left Sidebar Drawer (Visible on all tabs)
                    const CustomDrawer(isPermanentSidebar: true),
              
                    // Main Content Canvas
                    Expanded(
                      child: Column(
                        children: [
                          // Professional Top App Bar with Navigation TextButtons
                          customAppbar(context),
              
                          // Active Tab View Content
                          Expanded(
                            child: Obx(
                              () => navBody.elementAt(
                                dashBoardController.currentIndex.value,
                              ),
                            ).animate().fadeIn(duration: 200.ms),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: null, // No bottom nav on desktop/tablet!
              ),
            );
          }
        },
      ),
    );
  }
}

// =============================================================================
// Custom Curved Bottom Navigation Widget (Mobile Only)
// =============================================================================
class QuickTechCurvedNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<IconData> icons;
  final Function(int) onTap;

  const QuickTechCurvedNavBar({
    super.key,
    required this.selectedIndex,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = 1.sw;
    final itemWidth = width / icons.length;
    const circleSize = 68.0;

    return Container(
      height: 76.h,
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size(width, 80.h),
              painter: CurvePainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: width,
              height: 58.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(icons.length, (index) {
                  final isSelected = index == selectedIndex;

                  double bottomPadding;
                  if (index == 0 || index == icons.length - 1) {
                    bottomPadding = 32.h;
                  } else if (index == icons.length ~/ 2) {
                    bottomPadding = 10.h;
                  } else {
                    bottomPadding = 18.h;
                  }

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                      width: itemWidth,
                      height: 76.h,
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Center(
                        child: Icon(
                          icons[index],
                          size: 26.sp,
                          color: isSelected ? Colors.transparent : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: _getFloatingIconLeft(selectedIndex, itemWidth, width, circleSize.w),
            bottom: _getFloatingIconBottom(selectedIndex, icons.length),
            child: Container(
              width: circleSize.w,
              height: circleSize.h,
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 8.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icons[selectedIndex],
                size: 26.sp,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getFloatingIconLeft(
    int index,
    double itemWidth,
    double totalWidth,
    double circleSize,
  ) {
    const edgeMargin = 8.0;
    final rawLeft = (itemWidth * index) + (itemWidth / 2) - (circleSize / 2);
    return rawLeft.clamp(edgeMargin.w, totalWidth - circleSize - edgeMargin.w);
  }

  double _getFloatingIconBottom(int index, int totalIcons) {
    if (index == 0 || index == totalIcons - 1) {
      return 38.h;
    } else if (index == totalIcons ~/ 2) {
      return 14.h;
    } else {
      return 24.h;
    }
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.cubicTo(
      size.width * 0.25, 14.h,
      size.width * 0.38, 18.h,
      size.width * 0.5, 18.h,
    );
    path.cubicTo(
      size.width * 0.62, 18.h,
      size.width * 0.75, 14.h,
      size.width, 0,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
