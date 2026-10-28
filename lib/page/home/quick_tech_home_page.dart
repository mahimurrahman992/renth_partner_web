import 'dart:developer';

import 'package:renth_manager/consts/consts.dart';

import 'package:renth_manager/model/property_list_model.dart';

class QuickTechHomePage extends StatefulWidget {
  const QuickTechHomePage({super.key});

  @override
  State<QuickTechHomePage> createState() => _QuickTechHomePageState();
}

class _QuickTechHomePageState extends State<QuickTechHomePage> {
  final dashboardController = locator.get<DashboardController>();
  final editPropertyController = locator.get<EditPropertyController>();
  final roomController = locator.get<QuickTechRoomController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    await dashboardController.getManagerDashboard();
    await dashboardController.getAllPages();

    // Fetch all properties and load selected property's room records
    await editPropertyController.fetchAllProperties().then((_) {
      final savedId = editPropertyController.box.read(
        EditPropertyController.selectedPropertyId,
      );

      final properties =
          editPropertyController.propertyList.value.properties ?? [];

      if (savedId != null && properties.isNotEmpty) {
        try {
          final selected = properties.firstWhere((e) => e.id == savedId);
          editPropertyController.selectedProperty.value = selected;
          roomController.fetchRoomRecords(propertyId: savedId);
        } catch (e) {
          log(e.toString());
        }
      } else if (properties.isNotEmpty) {
        editPropertyController.selectedProperty.value = properties.first;
        if (properties.first.id != null) {
          roomController.fetchRoomRecords(propertyId: properties.first.id!);
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    final propertyId = GetStorage().read(StorageKeys.selectedPropertyId);
    await dashboardController.getManagerDashboard();

    if (propertyId != null) {
      await roomController.fetchRoomRecords(propertyId: propertyId);
    }
    await editPropertyController.fetchAllProperties();
  }

  @override
  void dispose() {
    dashboardController.shouldAnimate.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: mainColorDark,
          child: SingleChildScrollView(
            controller: dashboardController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
            ),
            child:
                isDesktop
                    ? QuickTechHomeDesktopView(onRefresh: _onRefresh)
                    : isTablet
                    ? QuickTechHomeTabletView(onRefresh: _onRefresh)
                    : const QuickTechHomeMobileView(),
          ),
        );
      },
    );
  }
}

// =============================================================================
// MOBILE VIEW
// =============================================================================

class QuickTechHomeMobileView extends StatelessWidget {
  const QuickTechHomeMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = locator.get<DashboardController>();
    final editPropertyController = locator.get<EditPropertyController>();
    final roomController = locator.get<QuickTechRoomController>();

    final steps = [
      {
        'title': 'Add a Property',
        'description': 'Create your first property to manage.',
        'icon': Icons.domain_add,
        'active': true,
      },
      {
        'title': 'Add Rooms',
        'description': 'Add rooms under your newly created property.',
        'icon': Icons.meeting_room,
        'active': false,
      },
      {
        'title': 'Manage Rooms',
        'description': 'Control bookings, tenants, and payments easily.',
        'icon': Icons.manage_accounts,
        'active': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. AVAILABLE BALANCE CARD
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [mainColor, Color(0xFFFFD500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Soft highlight circle (top right)
                Positioned(
                  top: -50,
                  right: -40,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ),

                // Big taka watermark
                Positioned(
                  right: 20,
                  bottom: -14,
                  child: Text(
                    '৳',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB89A00).withValues(alpha: 0.35),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      dashboardController
                                              .isBalanceVisible
                                              .value =
                                          !dashboardController
                                              .isBalanceVisible
                                              .value,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                child: Obx(
                                  () => Icon(
                                    dashboardController.isBalanceVisible.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 22,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Obx(() {
                              final isVisible =
                                  dashboardController.isBalanceVisible.value;
                              final revenue =
                                  dashboardController
                                      .dashboard
                                      .value
                                      .totalRevenue ??
                                  '0';

                              return Text(
                                isVisible ? '৳ $revenue' : '৳ ••••••',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.1,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BDT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 2. SELECT PROPERTY DROPDOWN
        Obx(() {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          final selected = editPropertyController.selectedProperty.value;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: mainColorDark.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Properties>(
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                value:
                    properties.any((e) => e.id == selected?.id)
                        ? selected
                        : null,
                hint: const Text(
                  'Select Property',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.black87,
                  size: 36,
                ),
                selectedItemBuilder: (context) {
                  return properties.map((prop) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        prop.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList();
                },
                items:
                    properties.map((prop) {
                      return DropdownMenuItem<Properties>(
                        value: prop,
                        child: Text(
                          prop.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (Properties? prop) async {
                  if (prop == null) return;
                  editPropertyController.selectedProperty.value = prop;
                  GetStorage().write(StorageKeys.selectedPropertyId, prop.id);
                  if (prop.id != null) {
                    await roomController.fetchRoomRecords(propertyId: prop.id!);
                  }
                },
              ),
            ),
          );
        }),

        const SizedBox(height: 22),

        Obx(() {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          final isLoading = dashboardController.isLoading.value;

          // ONBOARDING GUIDE
          if (properties.isEmpty && !isLoading) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome! \uD83D\uDC4B",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    "Let's get started by setting up your property and rooms.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  20.verticalSpace,
                  for (int i = 0; i < steps.length; i++) ...[
                    if (i != 0)
                      Padding(
                        padding: EdgeInsets.only(
                          left: 19.w,
                          top: 4.h,
                          bottom: 4.h,
                        ),
                        child: Container(
                          height: 20.h,
                          width: 2.w,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40.w,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color:
                                steps[i]['active'] as bool
                                    ? mainColor
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              steps[i]['icon'] as IconData,
                              color:
                                  steps[i]['active'] as bool
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              size: 20.w,
                            ),
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                steps[i]['title'] as String,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      steps[i]['active'] as bool
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                steps[i]['description'] as String,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  24.verticalSpace,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => QuickTechAddNewPropertyScreen());
                      },
                      child: Text(
                        "Add First Property",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 3. DASHBOARD OVERVIEW
              Text(
                'Dashboard Overview',
                style: QuickTechAppTextStyle.headline3().copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              const QuickTechHomeDashboardOverview(),

              const SizedBox(height: 28),

              // 4. RECENT BOOKINGS SECTION & TABLE
              QuickTechRecentBookingTable(),

              const SizedBox(height: 16),

              // PAGINATION LOADER
              Obx(() {
                if (dashboardController.isMoreLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: mainColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 40),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// TABLET VIEW
// =============================================================================

class QuickTechHomeTabletView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const QuickTechHomeTabletView({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final dashboardController = locator.get<DashboardController>();
    final editPropertyController = locator.get<EditPropertyController>();
    final roomController = locator.get<QuickTechRoomController>();
    final profileController = Get.find<ProfileController>();

    final steps = [
      {
        'title': 'Add a Property',
        'description': 'Create your first property to manage.',
        'icon': Icons.domain_add,
        'active': true,
      },
      {
        'title': 'Add Rooms',
        'description': 'Add rooms under your newly created property.',
        'icon': Icons.meeting_room,
        'active': false,
      },
      {
        'title': 'Manage Rooms',
        'description': 'Control bookings, tenants, and payments easily.',
        'icon': Icons.manage_accounts,
        'active': false,
      },
    ];

    final actions = [
      {
        'icon': Icons.domain_add_rounded,
        'label': 'New Property',
        'isPrimary': false,
        'accentColor': null,
        'onTap': () => Get.toNamed(AppRoutes.addNewProperty),
      },
      {
        'icon': Icons.add_home_work_rounded,
        'label': 'Add Room',
        'isPrimary': true,
        'accentColor': null,
        'onTap': () {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          if (properties.isNotEmpty) {
            Get.toNamed(AppRoutes.addRoom);
          } else {
            Get.snackbar(
              'Notice',
              'Please add a property first before adding rooms',
            );
          }
        },
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Withdraw',
        'isPrimary': false,
        'accentColor': successColor,
        'onTap': () => Get.toNamed(AppRoutes.withdraw),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TOP HERO GREETING & QUICK ACTION BAR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor.withValues(alpha: 0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mainColor.withValues(alpha: 0.3)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 800;

              final welcomeInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final userName =
                        profileController.profile.value.user?.name ??
                        'Property Partner';
                    return Text(
                      'Welcome back, $userName 👋',
                      style: QuickTechAppTextStyle.headline2().copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: textColor,
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor reservations, update room vacancies, and manage your property earnings.',
                    style: QuickTechAppTextStyle.subtitle().copyWith(
                      fontSize: 13,
                      color: textMuted,
                    ),
                  ),
                ],
              );

              final quickActions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final action in actions)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color:
                            action['isPrimary'] as bool
                                ? mainColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: action['isPrimary'] as bool ? 2 : 0,
                        shadowColor: mainColor.withValues(alpha: 0.3),
                        child: InkWell(
                          onTap: action['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    action['isPrimary'] as bool
                                        ? mainColorDark.withValues(alpha: 0.4)
                                        : ((action['accentColor'] as Color?)
                                                ?.withValues(alpha: 0.4) ??
                                            borderColor),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  action['icon'] as IconData,
                                  size: 16,
                                  color:
                                      action['isPrimary'] as bool
                                          ? Colors.black87
                                          : ((action['accentColor'] as Color?) ??
                                              textColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  action['label'] as String,
                                  style: QuickTechAppTextStyle.button().copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        action['isPrimary'] as bool
                                            ? Colors.black87
                                            : ((action['accentColor'] as Color?) ??
                                                textColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );

              if (isStacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    welcomeInfo,
                    const SizedBox(height: 14),
                    quickActions,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: welcomeInfo),
                  const SizedBox(width: 16),
                  quickActions,
                ],
              );
            },
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 18),

        // 2. FINANCIAL & PROPERTY SWITCHER ROW
        LayoutBuilder(
          builder: (context, constraints) {
            final isRow = constraints.maxWidth >= 880;

            final propertySelectorCard = Obx(() {
              final properties =
                  editPropertyController.propertyList.value.properties ?? [];
              final selected = editPropertyController.selectedProperty.value;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: mainColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Property',
                                      style: QuickTechAppTextStyle.caption()
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: textMuted,
                                          ),
                                    ),
                                    Text(
                                      selected?.title ?? 'No Property Selected',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: QuickTechAppTextStyle.headline4()
                                          .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected?.district?.name != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              selected!.district!.name!,
                              style: QuickTechAppTextStyle.caption().copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Properties>(
                          isExpanded: true,
                          value:
                              properties.any((e) => e.id == selected?.id)
                                  ? selected
                                  : null,
                          hint: Text(
                            'Switch Selected Property',
                            style: QuickTechAppTextStyle.bodyText3().copyWith(
                              color: textMuted,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black87,
                          ),
                          items:
                              properties.map((prop) {
                                return DropdownMenuItem<Properties>(
                                  value: prop,
                                  child: Text(
                                    prop.title ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (Properties? prop) async {
                            if (prop == null) return;
                            editPropertyController.selectedProperty.value =
                                prop;
                            GetStorage().write(
                              StorageKeys.selectedPropertyId,
                              prop.id,
                            );
                            if (prop.id != null) {
                              await roomController.fetchRoomRecords(
                                propertyId: prop.id!,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });

            final balanceQuickCard = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFFFFBEB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: mainColor.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: successColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: successColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Balance',
                            style: QuickTechAppTextStyle.caption().copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap:
                              () =>
                                  dashboardController.isBalanceVisible.value =
                                      !dashboardController
                                          .isBalanceVisible
                                          .value,
                          child: Obx(
                            () => Icon(
                              dashboardController.isBalanceVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final isVisible =
                              dashboardController.isBalanceVisible.value;
                          final revenue =
                              dashboardController
                                  .dashboard
                                  .value
                                  .totalRevenue ??
                              '0';

                          return Text(
                            isVisible ? '৳ $revenue' : '৳ ••••••',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QuickTechAppTextStyle.headline1().copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: textColor,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(AppRoutes.withdraw),
                          icon: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Withdraw',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isRow) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: propertySelectorCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: balanceQuickCard),
                ],
              );
            }

            return Column(
              children: [
                propertySelectorCard,
                const SizedBox(height: 12),
                balanceQuickCard,
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        Obx(() {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          final isLoading = dashboardController.isLoading.value;

          // ONBOARDING GUIDE
          if (properties.isEmpty && !isLoading) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome! \uD83D\uDC4B",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let's get started by setting up your property and rooms.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i != 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 21,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Container(
                              height: 20,
                              width: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color:
                                    steps[i]['active'] as bool
                                        ? mainColor
                                        : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  steps[i]['icon'] as IconData,
                                  color:
                                      steps[i]['active'] as bool
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    steps[i]['title'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          steps[i]['active'] as bool
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    steps[i]['description'] as String,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Get.toNamed(AppRoutes.addNewProperty),
                          child: const Text(
                            "Add First Property",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3. DASHBOARD METRICS / KPI GRID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: mainColorDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Overview',
                        style: QuickTechAppTextStyle.headline3().copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: textMuted,
                    ),
                    tooltip: 'Refresh Metrics',
                    onPressed: onRefresh,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const QuickTechHomeDashboardOverview(),

              const SizedBox(height: 28),

              // 4. RECENT BOOKINGS SECTION & TABLE
              QuickTechRecentBookingTable(),

              const SizedBox(height: 16),

              // PAGINATION LOADER
              Obx(() {
                if (dashboardController.isMoreLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: mainColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 40),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// DESKTOP VIEW
// =============================================================================

class QuickTechHomeDesktopView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const QuickTechHomeDesktopView({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final dashboardController = locator.get<DashboardController>();
    final editPropertyController = locator.get<EditPropertyController>();
    final roomController = locator.get<QuickTechRoomController>();
    final profileController = Get.find<ProfileController>();

    final steps = [
      {
        'title': 'Add a Property',
        'description': 'Create your first property to manage.',
        'icon': Icons.domain_add,
        'active': true,
      },
      {
        'title': 'Add Rooms',
        'description': 'Add rooms under your newly created property.',
        'icon': Icons.meeting_room,
        'active': false,
      },
      {
        'title': 'Manage Rooms',
        'description': 'Control bookings, tenants, and payments easily.',
        'icon': Icons.manage_accounts,
        'active': false,
      },
    ];

    final actions = [
      {
        'icon': Icons.domain_add_rounded,
        'label': 'New Property',
        'isPrimary': false,
        'accentColor': null,
        'onTap': () => Get.toNamed(AppRoutes.addNewProperty),
      },
      {
        'icon': Icons.add_home_work_rounded,
        'label': 'Add Room',
        'isPrimary': true,
        'accentColor': null,
        'onTap': () {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          if (properties.isNotEmpty) {
            Get.toNamed(AppRoutes.addRoom);
          } else {
            Get.snackbar(
              'Notice',
              'Please add a property first before adding rooms',
            );
          }
        },
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Withdraw',
        'isPrimary': false,
        'accentColor': successColor,
        'onTap': () => Get.toNamed(AppRoutes.withdraw),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TOP HERO GREETING & QUICK ACTION BAR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor.withValues(alpha: 0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mainColor.withValues(alpha: 0.3)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 800;

              final welcomeInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final userName =
                        profileController.profile.value.user?.name ??
                        'Property Partner';
                    return Text(
                      'Welcome back, $userName 👋',
                      style: QuickTechAppTextStyle.headline2().copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: textColor,
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor reservations, update room vacancies, and manage your property earnings.',
                    style: QuickTechAppTextStyle.subtitle().copyWith(
                      fontSize: 13,
                      color: textMuted,
                    ),
                  ),
                ],
              );

              final quickActions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final action in actions)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color:
                            action['isPrimary'] as bool
                                ? mainColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: action['isPrimary'] as bool ? 2 : 0,
                        shadowColor: mainColor.withValues(alpha: 0.3),
                        child: InkWell(
                          onTap: action['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    action['isPrimary'] as bool
                                        ? mainColorDark.withValues(alpha: 0.4)
                                        : ((action['accentColor'] as Color?)
                                                ?.withValues(alpha: 0.4) ??
                                            borderColor),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  action['icon'] as IconData,
                                  size: 16,
                                  color:
                                      action['isPrimary'] as bool
                                          ? Colors.black87
                                          : ((action['accentColor'] as Color?) ??
                                              textColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  action['label'] as String,
                                  style: QuickTechAppTextStyle.button().copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        action['isPrimary'] as bool
                                            ? Colors.black87
                                            : ((action['accentColor'] as Color?) ??
                                                textColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );

              if (isStacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    welcomeInfo,
                    const SizedBox(height: 14),
                    quickActions,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: welcomeInfo),
                  const SizedBox(width: 16),
                  quickActions,
                ],
              );
            },
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 18),

        // 2. FINANCIAL & PROPERTY SWITCHER ROW
        LayoutBuilder(
          builder: (context, constraints) {
            final isRow = constraints.maxWidth >= 880;

            final propertySelectorCard = Obx(() {
              final properties =
                  editPropertyController.propertyList.value.properties ?? [];
              final selected = editPropertyController.selectedProperty.value;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: mainColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.business_rounded,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Property',
                                      style: QuickTechAppTextStyle.caption()
                                          .copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: textMuted,
                                          ),
                                    ),
                                    Text(
                                      selected?.title ?? 'No Property Selected',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: QuickTechAppTextStyle.headline4()
                                          .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected?.district?.name != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              selected!.district!.name!,
                              style: QuickTechAppTextStyle.caption().copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Properties>(
                          isExpanded: true,
                          value:
                              properties.any((e) => e.id == selected?.id)
                                  ? selected
                                  : null,
                          hint: Text(
                            'Switch Selected Property',
                            style: QuickTechAppTextStyle.bodyText3().copyWith(
                              color: textMuted,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black87,
                          ),
                          items:
                              properties.map((prop) {
                                return DropdownMenuItem<Properties>(
                                  value: prop,
                                  child: Text(
                                    prop.title ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (Properties? prop) async {
                            if (prop == null) return;
                            editPropertyController.selectedProperty.value =
                                prop;
                            GetStorage().write(
                              StorageKeys.selectedPropertyId,
                              prop.id,
                            );
                            if (prop.id != null) {
                              await roomController.fetchRoomRecords(
                                propertyId: prop.id!,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });

            final balanceQuickCard = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFFFFBEB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: mainColor.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: successColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: successColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Balance',
                            style: QuickTechAppTextStyle.caption().copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap:
                              () =>
                                  dashboardController.isBalanceVisible.value =
                                      !dashboardController
                                          .isBalanceVisible
                                          .value,
                          child: Obx(
                            () => Icon(
                              dashboardController.isBalanceVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final isVisible =
                              dashboardController.isBalanceVisible.value;
                          final revenue =
                              dashboardController
                                  .dashboard
                                  .value
                                  .totalRevenue ??
                              '0';

                          return Text(
                            isVisible ? '৳ $revenue' : '৳ ••••••',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QuickTechAppTextStyle.headline1().copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: textColor,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(AppRoutes.withdraw),
                          icon: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Withdraw',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isRow) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: propertySelectorCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: balanceQuickCard),
                ],
              );
            }

            return Column(
              children: [
                propertySelectorCard,
                const SizedBox(height: 12),
                balanceQuickCard,
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        Obx(() {
          final properties =
              editPropertyController.propertyList.value.properties ?? [];
          final isLoading = dashboardController.isLoading.value;

          // ONBOARDING GUIDE
          if (properties.isEmpty && !isLoading) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome! \uD83D\uDC4B",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let's get started by setting up your property and rooms.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i != 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 21,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Container(
                              height: 20,
                              width: 2,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color:
                                    steps[i]['active'] as bool
                                        ? mainColor
                                        : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  steps[i]['icon'] as IconData,
                                  color:
                                      steps[i]['active'] as bool
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    steps[i]['title'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          steps[i]['active'] as bool
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    steps[i]['description'] as String,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Get.toNamed(AppRoutes.addNewProperty),
                          child: const Text(
                            "Add First Property",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3. DASHBOARD METRICS / KPI GRID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: mainColorDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Overview',
                        style: QuickTechAppTextStyle.headline3().copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: textMuted,
                    ),
                    tooltip: 'Refresh Metrics',
                    onPressed: onRefresh,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const QuickTechHomeDashboardOverview(),

              const SizedBox(height: 28),

              // 4. RECENT BOOKINGS SECTION & TABLE
              QuickTechRecentBookingTable(),

              const SizedBox(height: 16),

              // PAGINATION LOADER
              Obx(() {
                if (dashboardController.isMoreLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: mainColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 40),
            ],
          );
        }),
      ],
    );
  }
}