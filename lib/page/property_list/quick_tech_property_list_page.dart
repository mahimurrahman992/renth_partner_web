import 'package:flutter/cupertino.dart';
import 'package:renth_manager/consts/consts.dart';

class QuickTechPropertyListPage extends StatefulWidget {
  final bool showAppBar;
  const QuickTechPropertyListPage({super.key, this.showAppBar = false});

  @override
  State<QuickTechPropertyListPage> createState() =>
      _QuickTechPropertyListPageState();
}

class _QuickTechPropertyListPageState extends State<QuickTechPropertyListPage> {
  final dashboardController = locator.get<DashboardController>();
  final commonController = locator.get<CommonController>();
  final editPropertyController = locator.get<EditPropertyController>();

  // ---------------------------------------------------------------------------
  // ACTIONS (same logic for mobile / tablet / desktop)
  // ---------------------------------------------------------------------------

  Future<void> _onAddProperty() async {
    await commonController.fetchPropertyCategories();
    Get.toNamed(AppRoutes.addNewProperty);
  }

  void _onAddRoom() {
    final properties =
        editPropertyController.propertyList.value.properties ?? [];
    if (properties.isNotEmpty) {
      Get.toNamed(AppRoutes.addRoom);
    } else {
      Get.snackbar(
        'Action Required',
        'Please register a property first before adding individual rooms.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  void _onAddVehicle() {
    Get.snackbar(
      'Upcoming Feature',
      'Vehicle rental management will be released in an upcoming update.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  // ---------------------------------------------------------------------------
  // BODY (mobile < 600, tablet 600-1023, desktop >= 1024)
  // ---------------------------------------------------------------------------

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileBody();
        }
        return _buildTabletDesktopBody(isDesktop: constraints.maxWidth >= 1024);
      },
    );
  }

  // ===========================================================================
  // ONBOARDING GUIDE (premium on tablet/desktop, compact on mobile)
  // ===========================================================================

  Widget _buildOnboardingGuide({bool premium = false}) {
    const steps = [
      (
        Icons.apartment_rounded,
        'Add Property',
        'Register your hotel, apartment or guest house.',
      ),
      (
        Icons.bed_rounded,
        'Add Rooms',
        'Add rentable rooms or flats under your property.',
      ),
      (
        Icons.payments_outlined,
        'Get Bookings',
        'Receive bookings and manage your earnings.',
      ),
    ];

    final double circle = premium ? 52 : 40.w;
    final double iconSize = premium ? 26 : 20.sp;

    return Container(
      width: double.infinity,
      padding: premium ? const EdgeInsets.all(28) : EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor.withValues(alpha: 0.25), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Get started in 3 easy steps',
            style: QuickTechAppTextStyle.headline4().copyWith(
              fontSize: premium ? 20 : 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (premium) ...[
            const SizedBox(height: 6),
            Text(
              'Follow these steps to start earning with Renth Partner.',
              style: QuickTechAppTextStyle.subtitle().copyWith(
                fontSize: 13,
                color: textMuted,
              ),
            ),
          ],
          SizedBox(height: premium ? 28 : 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                SizedBox(
                  width: premium ? 170 : null,
                  child: Column(
                    children: [
                      Container(
                        width: circle,
                        height: circle,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? mainColor : white,
                          border:
                              premium
                                  ? Border.all(
                                    color: i == 0
                                        ? mainColorDark
                                        : Colors.grey.shade300,
                                  )
                                  : null,
                        ),
                        child: Icon(
                          steps[i].$1,
                          size: iconSize,
                          color: i == 0 ? Colors.black : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: premium ? 10 : 6.h),
                      Text(
                        '${i + 1}. ${steps[i].$2}',
                        textAlign: TextAlign.center,
                        style: QuickTechAppTextStyle.bodyText4().copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: premium ? 15 : null,
                          color: i == 0 ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      if (premium) ...[
                        const SizedBox(height: 4),
                        Text(
                          steps[i].$3,
                          textAlign: TextAlign.center,
                          style: QuickTechAppTextStyle.subtitle().copyWith(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.only(
                        top: premium ? 25 : 19.w,
                        left: 4,
                        right: 4,
                      ),
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE
  // ===========================================================================

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'List Your Property',
            style: QuickTechAppTextStyle.headline3().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          40.verticalSpace,

          _buildMobileActionButton(
            label: 'Add New Property',
            icon: Icons.add_home_rounded,
            onTap: _onAddProperty,
          ),

          14.verticalSpace,

          _buildMobileActionButton(
            label: 'Add New Room',
            icon: Icons.home_work_rounded,
            onTap: _onAddRoom,
          ),

          14.verticalSpace,

          _buildMobileActionButton(
            label: 'Add New Vehicle',
            icon: CupertinoIcons.car_detailed,
            onTap: _onAddVehicle,
          ),

          20.verticalSpace,

          _buildOnboardingGuide(),

          40.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildMobileActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: mainColor,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 78,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: mainColor),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TABLET / DESKTOP
  // ===========================================================================

  Widget _buildTabletDesktopBody({required bool isDesktop}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 960 : 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List & Manage Your Assets',
                style: QuickTechAppTextStyle.headline3().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
              4.verticalSpace,
              Text(
                'Expand your portfolio by registering new properties, rooms, or vehicles.',
                style: QuickTechAppTextStyle.subtitle().copyWith(
                  color: textMuted,
                  fontSize: 13,
                ),
              ),
              28.verticalSpace,

              _buildFeatureCard(
                title: 'Add New Property',
                description:
                    'Register an entire hotel, apartment building, family home, or guest house.',
                icon: Icons.add_business_rounded,
                accentColor: mainColor,
                onTap: _onAddProperty,
              ),

              16.verticalSpace,

              _buildFeatureCard(
                title: 'Add New Room / Flat',
                description:
                    'Add individual rentable rooms, suites, or flats to your registered properties.',
                icon: Icons.meeting_room_rounded,
                accentColor: const Color(0xFF3B82F6),
                onTap: _onAddRoom,
              ),

              16.verticalSpace,

              _buildFeatureCard(
                title: 'Add New Vehicle (Upcoming)',
                description:
                    'Car, bike, and microbus rental service integration coming soon to Renth Partner.',
                icon: CupertinoIcons.car_detailed,
                accentColor: const Color(0xFF8B5CF6),
                isComingSoon: false,
                onTap: _onAddVehicle,
              ),

              28.verticalSpace,

              _buildOnboardingGuide(premium: true),

              40.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: mainColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: black),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: QuickTechAppTextStyle.headline4().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isComingSoon) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SOON',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: QuickTechAppTextStyle.subtitle().copyWith(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return _buildBody(context);
    }

    return Scaffold(
      drawer: const CustomDrawer(isPermanentSidebar: false),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            customAppbar(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }
}