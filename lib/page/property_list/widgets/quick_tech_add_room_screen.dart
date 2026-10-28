import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:renth_manager/controller/quick_tech_property_room_store_controller.dart';
import 'package:renth_manager/model/response/quickech_get_room_data.dart';
import 'package:renth_manager/widgets/quick_tech_custom_dropdown.dart';
import 'package:renth_manager/widgets/web_image.dart';
import '../../../consts/consts.dart';

// =============================================================================
// SHARED HELPERS (category logic - same for mobile / tablet / desktop)
// Categories: Hotel, Flat Sale/Buy, Family Home, Bachelor, Hostel, Rider
// =============================================================================

String _categoryName(QuickTechPropertyRoomController c) {
  return (c.selectedProperty.value?.propertyCategory?.name ?? 'Hotel').trim();
}

void _onPropertyChanged(QuickTechPropertyRoomController c, Properties? value) {
  c.selectedProperty.value = value;
  final category = (value?.propertyCategory?.name ?? 'Hotel').trim();

  // Hotel only: amenities + children capacity
  if (category != 'Hotel') {
    c.selectedFacilities.clear();
    c.childCapacityController.clear();
  }

  // Bed type hidden for Flat Sale/Buy & Rider
  if (category == 'Flat Sale/Buy' || category == 'Rider') {
    c.selectedBedType.value = null;
  }

  // Adult capacity hidden for Rider
  if (category == 'Rider') {
    c.adultCapacityController.clear();
  }
}

class QuickTechAddRoomScreen extends StatefulWidget {
  const QuickTechAddRoomScreen({super.key});

  @override
  State<QuickTechAddRoomScreen> createState() => _QuickTechAddRoomScreenState();
}

class _QuickTechAddRoomScreenState extends State<QuickTechAddRoomScreen> {
  final dashboardController = locator.get<DashboardController>();
  final commonController = locator.get<CommonController>();
  final roomController = locator.get<QuickTechPropertyRoomController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((v) {
      roomController.selectedRoomType.value = null;
      roomController.selectedProperty.value = null;
      roomController.selectedBedType.value = null;
      roomController.clearRoomForm();

      commonController.fetchRoomCreateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              if (width < 600) {
                return AddRoomMobileView(
                  roomController: roomController,
                  commonController: commonController,
                );
              } else if (width < 1024) {
                return AddRoomTabletView(
                  roomController: roomController,
                  commonController: commonController,
                );
              } else {
                return AddRoomDesktopView(
                  roomController: roomController,
                  commonController: commonController,
                );
              }
            },
          ),

          // ---------------- LOADING OVERLAY ----------------
          Obx(() {
            if (!roomController.isLoading.value) return const SizedBox.shrink();

            return SizedBox.expand(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: mainColor),
                        16.verticalSpace,
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE VIEW
// =============================================================================

class AddRoomMobileView extends StatelessWidget {
  final QuickTechPropertyRoomController roomController;
  final CommonController commonController;

  const AddRoomMobileView({
    super.key,
    required this.roomController,
    required this.commonController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------- HEADER ----------------
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 24.w, 20.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 32.h,
                  width: 32.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mainColor,
                  ),
                  child: Icon(Icons.arrow_back_sharp, size: 24.h),
                ),
              ),
              14.horizontalSpace,
              Expanded(
                child: Text(
                  'Room Categories & Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---------------- BODY ----------------
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
                child: Column(
                  children: [
                    // ---------------- BASIC INFORMATION CARD ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      final isFlat = category == 'Flat Sale/Buy';
                      final isHome = category == 'Family Home';
                      final isRider = category == 'Rider';
                      final showBed = !isFlat && !isRider;

                      return Column(
                        children: [
                          customDropdownField(
                            hint: 'Select Property',
                            items:
                                commonController.properties.map((item) {
                                  return DropdownMenuItem<Properties>(
                                    value: item,
                                    child: Text(item.title ?? ''),
                                  );
                                }).toList(),
                            value: roomController.selectedProperty.value,
                            onChanged: (value) {
                              _onPropertyChanged(roomController, value);
                            },
                          ),
                          14.verticalSpace,
                          customTextField(
                            hint:
                                isFlat
                                    ? 'Flat Name'
                                    : isHome
                                    ? 'Home Name'
                                    : isRider
                                    ? 'Rider Name'
                                    : 'Room Name',
                            isSuffix: false,
                            isVisible: true,
                            controller: roomController.roomNameController,
                          ),
                          14.verticalSpace,
                          customDropdownField(
                            hint:
                                (isFlat || isHome)
                                    ? 'Type of Flat'
                                    : isRider
                                    ? 'Type of Rider'
                                    : 'Type of Room',
                            items:
                                commonController.roomTypes.map((item) {
                                  return DropdownMenuItem<Type>(
                                    value: item,
                                    child: Text(item.name ?? ''),
                                  );
                                }).toList(),
                            value: roomController.selectedRoomType.value,
                            onChanged: (value) {
                              roomController.selectedRoomType.value = value;
                            },
                          ),
                          if (showBed) ...[
                            14.verticalSpace,
                            customDropdownField(
                              hint: 'Type of Beds',
                              items:
                                  commonController.bedTypes.map((item) {
                                    return DropdownMenuItem<Type>(
                                      value: item,
                                      child: Text(item.name ?? ''),
                                    );
                                  }).toList(),
                              value: roomController.selectedBedType.value,
                              onChanged: (value) {
                                roomController.selectedBedType.value = value;
                              },
                            ),
                          ],
                        ],
                      );
                    }),

                    16.verticalSpace,

                    // ---------------- PRICING & CHARGES CARD ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      final isFlat = category == 'Flat Sale/Buy';
                      final isMonthly =
                          category == 'Family Home' ||
                          category == 'Rider' ||
                          category == 'Bachelor' ||
                          category == 'Hostel';

                      return customTextField(
                        hint:
                            isFlat
                                ? 'Sale Price'
                                : isMonthly
                                ? 'Monthly Rent'
                                : 'Room Price(Per Night)',
                        isSuffix: true,
                        isVisible: true,
                        controller: roomController.roomPriceController,
                        keyboard: TextInputType.number,
                        supColor: Colors.black,
                      );
                    }),

                    16.verticalSpace,

                    // ---------------- CAPACITY & SIZE CARD ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      final isHotel = category == 'Hotel';
                      final isFlat = category == 'Flat Sale/Buy';
                      final isHome = category == 'Family Home';
                      final isRider = category == 'Rider';

                      return Column(
                        children: [
                          if (!isRider) ...[
                            customTextField(
                              hint: 'Capacity of Adults',
                              isSuffix: true,
                              isVisible: true,
                              controller:
                                  roomController.adultCapacityController,
                              keyboard: TextInputType.number,
                              supColor: Colors.black,
                            ),
                            14.verticalSpace,
                          ],
                          if (isHotel) ...[
                            customTextField(
                              hint: 'Capacity of Children',
                              isSuffix: true,
                              isVisible: true,
                              controller:
                                  roomController.childCapacityController,
                              keyboard: TextInputType.number,
                              supColor: Colors.black,
                            ),
                            14.verticalSpace,
                          ],
                          customTextField(
                            hint:
                                isFlat
                                    ? 'Flat Size'
                                    : isHome
                                    ? 'Home Size'
                                    : 'Room Size',
                            isSuffix: true,
                            isVisible: true,
                            controller: roomController.roomSizeController,
                            supColor: Colors.black,
                          ),
                        ],
                      );
                    }),

                    16.verticalSpace,

                    // ---------------- AMENITIES CARD (HOTEL ONLY) ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      if (category != 'Hotel') return const SizedBox.shrink();

                      return QuickTechRoomAmenitiesWidget();
                    }),
                    10.verticalSpace,

                    // ---------------- DESCRIPTION CARD ----------------
                    customTextField(
                      hint: 'Room Description',
                      isSuffix: true,
                      maxline: 5,
                      isVisible: true,
                      controller: roomController.roomDescriptionController,
                      supColor: Colors.black,
                    ),
                    16.verticalSpace,
                    Obx(() {
                      final category = _categoryName(roomController);

                      final isFlat = category == 'Flat Sale/Buy';
                      final isHome = category == 'Family Home';

                      return customTextField(
                        hint:
                            isFlat
                                ? 'Total Flats'
                                : isHome
                                ? 'Total Homes'
                                : 'Total Rooms',
                        isSuffix: true,
                        keyboard: TextInputType.number,
                        isVisible: true,
                        controller: roomController.numberOfRoomController,
                        supColor: Colors.black,
                      );
                    }),
                    16.verticalSpace,

                    customTextField(
                      hint: 'Service Charge',
                      isSuffix: true,
                      isVisible: true,
                      controller: roomController.serviceChargeController,
                      keyboard: TextInputType.number,
                      supColor: Colors.black,
                    ),

                    16.verticalSpace,

                    // ---------------- IMAGES CARD ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      final isFlat = category == 'Flat Sale/Buy';
                      final isHome = category == 'Family Home';
                      final isRider = category == 'Rider';
                      final images = roomController.selectedImages;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Material(
                              color: white,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: mainColor.withValues(alpha: 0.6),
                                  width: 1.4,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => roomController.pickRoomImages(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal: 12.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isFlat
                                            ? 'Flat Images'
                                            : isHome
                                            ? 'Home Images'
                                            : isRider
                                            ? 'Rider Images'
                                            : 'Room Images',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      10.verticalSpace,
                                      Container(
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: mainColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              size: 24.w,
                                              color: Colors.black,
                                            ),
                                            8.horizontalSpace,
                                            Text(
                                              'Choose Images',
                                              style:
                                                  QuickTechAppTextStyle.bodyText4()
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (images.isNotEmpty) ...[
                            16.verticalSpace,
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(images.length, (index) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          kIsWeb
                                              ? WebSafeNetworkImage(
                                                imageUrl: images[index],
                                                width: 88,
                                                height: 88,
                                                fit: BoxFit.cover,
                                              )
                                              : Image.file(
                                                File(images[index]),
                                                width: 88,
                                                height: 88,
                                                fit: BoxFit.cover,
                                              ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap:
                                              () => roomController.removeImage(
                                                index,
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ],
                      );
                    }),

                    16.verticalSpace,

                    // ---------------- VIDEO CARD ----------------
                    Obx(() {
                      final category = _categoryName(roomController);
                      final isFlat = category == 'Flat Sale/Buy';
                      final isHome = category == 'Family Home';
                      final isRider = category == 'Rider';
                      final String? video = roomController.selectedVideo.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Material(
                              color: white,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: mainColor.withValues(alpha: 0.6),
                                  width: 1.4,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => roomController.pickRoomVideo(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal: 12.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isFlat
                                            ? 'Flat Video (Optional)'
                                            : isHome
                                            ? 'Home Video (Optional)'
                                            : isRider
                                            ? 'Rider Video (Optional)'
                                            : 'Room Video (Optional)',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      10.verticalSpace,
                                      Container(
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: mainColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              size: 24.w,
                                              color: Colors.black,
                                            ),
                                            8.horizontalSpace,
                                            Text(
                                              'Choose Video',
                                              style:
                                                  QuickTechAppTextStyle.bodyText4()
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (video != null && video.isNotEmpty) ...[
                            16.verticalSpace,
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.video_file_rounded,
                                    color: mainColor,
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      video.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => roomController.removeVideo(),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    }),

                    24.verticalSpace,

                    // ---------------- SAVE BUTTON ----------------
                    Obx(() {
                      return customButton2(
                        title: 'Save & Continue',
                        icon: Icons.save_rounded,
                        iconBackground: black,
                        iconColor: mainColor,
                        isLoading: roomController.isLoading.value,
                        onTap: () {
                          if (roomController.isLoading.value) return;
                          roomController.submitRoom();
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TABLET VIEW
// =============================================================================

class AddRoomTabletView extends StatelessWidget {
  final QuickTechPropertyRoomController roomController;
  final CommonController commonController;

  const AddRoomTabletView({
    super.key,
    required this.roomController,
    required this.commonController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ---------------- TOP BAR ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                16.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Room',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      'Fill in the details below to list a new room',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- BODY ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    children: [
                      // ---------------- BASIC INFORMATION CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    color: mainColor,
                                    size: 20,
                                  ),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'Basic Information',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            Obx(() {
                              final category = _categoryName(roomController);
                              final isFlat = category == 'Flat Sale/Buy';
                              final isHome = category == 'Family Home';
                              final isRider = category == 'Rider';
                              final showBed = !isFlat && !isRider;

                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: customDropdownField(
                                          hint: 'Select Property',
                                          items:
                                              commonController.properties.map((
                                                item,
                                              ) {
                                                return DropdownMenuItem<
                                                  Properties
                                                >(
                                                  value: item,
                                                  child: Text(item.title ?? ''),
                                                );
                                              }).toList(),
                                          value:
                                              roomController
                                                  .selectedProperty
                                                  .value,
                                          onChanged: (value) {
                                            _onPropertyChanged(
                                              roomController,
                                              value,
                                            );
                                          },
                                        ),
                                      ),
                                      16.horizontalSpace,
                                      Expanded(
                                        child: customTextField(
                                          hint:
                                              isFlat
                                                  ? 'Flat Name'
                                                  : isHome
                                                  ? 'Home Name'
                                                  : isRider
                                                  ? 'Rider Name'
                                                  : 'Room Name',
                                          isSuffix: false,
                                          isVisible: true,
                                          controller:
                                              roomController.roomNameController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  14.verticalSpace,
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: customDropdownField(
                                          hint:
                                              (isFlat || isHome)
                                                  ? 'Type of Flat'
                                                  : isRider
                                                  ? 'Type of Rider'
                                                  : 'Type of Room',
                                          items:
                                              commonController.roomTypes.map((
                                                item,
                                              ) {
                                                return DropdownMenuItem<Type>(
                                                  value: item,
                                                  child: Text(item.name ?? ''),
                                                );
                                              }).toList(),
                                          value:
                                              roomController
                                                  .selectedRoomType
                                                  .value,
                                          onChanged: (value) {
                                            roomController
                                                .selectedRoomType
                                                .value = value;
                                          },
                                        ),
                                      ),
                                      16.horizontalSpace,
                                      Expanded(
                                        child:
                                            showBed
                                                ? customDropdownField(
                                                  hint: 'Type of Beds',
                                                  items:
                                                      commonController.bedTypes
                                                          .map((item) {
                                                            return DropdownMenuItem<
                                                              Type
                                                            >(
                                                              value: item,
                                                              child: Text(
                                                                item.name ?? '',
                                                              ),
                                                            );
                                                          })
                                                          .toList(),
                                                  value:
                                                      roomController
                                                          .selectedBedType
                                                          .value,
                                                  onChanged: (value) {
                                                    roomController
                                                        .selectedBedType
                                                        .value = value;
                                                  },
                                                )
                                                : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      16.verticalSpace,

                      // ---------------- PRICING & CHARGES CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.payments_outlined,
                                    color: mainColor,
                                    size: 20,
                                  ),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'Pricing & Charges',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            Obx(() {
                              final category = _categoryName(roomController);
                              final isFlat = category == 'Flat Sale/Buy';
                              final isMonthly =
                                  category == 'Family Home' ||
                                  category == 'Rider' ||
                                  category == 'Bachelor' ||
                                  category == 'Hostel';

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: customTextField(
                                      hint:
                                          isFlat
                                              ? 'Sale Price'
                                              : isMonthly
                                              ? 'Monthly Rent'
                                              : 'Room Price(Per Night)',
                                      isSuffix: true,
                                      isVisible: true,
                                      controller:
                                          roomController.roomPriceController,
                                      keyboard: TextInputType.number,
                                      supColor: Colors.black,
                                    ),
                                  ),
                                  16.horizontalSpace,
                                  Expanded(
                                    child: customTextField(
                                      hint: 'Service Charge',
                                      isSuffix: true,
                                      isVisible: true,
                                      controller:
                                          roomController
                                              .serviceChargeController,
                                      keyboard: TextInputType.number,
                                      supColor: Colors.black,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      16.verticalSpace,

                      // ---------------- CAPACITY & SIZE CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.people_outline_rounded,
                                    color: mainColor,
                                    size: 20,
                                  ),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'Capacity & Size',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            Obx(() {
                              final category = _categoryName(roomController);
                              final isHotel = category == 'Hotel';
                              final isFlat = category == 'Flat Sale/Buy';
                              final isHome = category == 'Family Home';
                              final isRider = category == 'Rider';

                              return Column(
                                children: [
                                  // Hotel: (adult, child) + (size, count)
                                  if (isHotel) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Capacity of Adults',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .adultCapacityController,
                                            keyboard: TextInputType.number,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Capacity of Children',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .childCapacityController,
                                            keyboard: TextInputType.number,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    14.verticalSpace,
                                  ],
                                  // Others (not rider): (adult, size) + (count)
                                  if (!isHotel && !isRider) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Capacity of Adults',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .adultCapacityController,
                                            keyboard: TextInputType.number,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: customTextField(
                                            hint:
                                                isFlat
                                                    ? 'Flat Size'
                                                    : isHome
                                                    ? 'Home Size'
                                                    : 'Room Size',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .roomSizeController,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    14.verticalSpace,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint:
                                                isFlat
                                                    ? 'Total Flats'
                                                    : isHome
                                                    ? 'Total Homes'
                                                    : 'Total Rooms',
                                            isSuffix: true,
                                            keyboard: TextInputType.number,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .numberOfRoomController,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ],
                                  // Hotel / Rider: (size, count)
                                  if (isHotel || isRider)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint:
                                                isFlat
                                                    ? 'Flat Size'
                                                    : isHome
                                                    ? 'Home Size'
                                                    : 'Room Size',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .roomSizeController,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: customTextField(
                                            hint:
                                                isFlat
                                                    ? 'Total Flats'
                                                    : isHome
                                                    ? 'Total Homes'
                                                    : 'Total Rooms',
                                            isSuffix: true,
                                            keyboard: TextInputType.number,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .numberOfRoomController,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      16.verticalSpace,

                      // ---------------- AMENITIES CARD (HOTEL ONLY) ----------------
                      Obx(() {
                        final isHotel =
                            _categoryName(roomController) == 'Hotel';

                        if (!isHotel) return const SizedBox.shrink();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.checklist_rounded,
                                          color: mainColor,
                                          size: 20,
                                        ),
                                      ),
                                      12.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          'Amenities',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.verticalSpace,
                                  QuickTechRoomAmenitiesWidget(),
                                ],
                              ),
                            ),
                            16.verticalSpace,
                          ],
                        );
                      }),

                      // ---------------- DESCRIPTION CARD ----------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.notes_rounded,
                                    color: mainColor,
                                    size: 20,
                                  ),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            20.verticalSpace,
                            customTextField(
                              hint: 'Room Description',
                              isSuffix: true,
                              maxline: 5,
                              isVisible: true,
                              controller:
                                  roomController.roomDescriptionController,
                              supColor: Colors.black,
                            ),
                          ],
                        ),
                      ),

                      16.verticalSpace,

                      // ---------------- IMAGES CARD ----------------
                      Obx(() {
                        final category = _categoryName(roomController);
                        final isFlat = category == 'Flat Sale/Buy';
                        final isHome = category == 'Family Home';
                        final isRider = category == 'Rider';
                        final images = roomController.selectedImages;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: mainColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.photo_library_outlined,
                                      color: mainColor,
                                      size: 20,
                                    ),
                                  ),
                                  12.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      isFlat
                                          ? 'Flat Images'
                                          : isHome
                                          ? 'Home Images'
                                          : isRider
                                          ? 'Rider Images'
                                          : 'Room Images',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Material(
                                  color: mainColor.withValues(alpha: 0.06),
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: mainColor.withValues(alpha: 0.6),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap:
                                        () => roomController.pickRoomImages(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 22,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 30,
                                              color: mainColor,
                                            ),
                                            8.verticalSpace,
                                            Text(
                                              'Choose Images',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF111827),
                                              ),
                                            ),
                                            2.verticalSpace,
                                            Text(
                                              'Tap to browse',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (images.isNotEmpty) ...[
                                16.verticalSpace,
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: List.generate(images.length, (
                                    index,
                                  ) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              kIsWeb
                                                  ? WebSafeNetworkImage(
                                                    imageUrl: images[index],
                                                    width: 88,
                                                    height: 88,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.file(
                                                    File(images[index]),
                                                    width: 88,
                                                    height: 88,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap:
                                                  () => roomController
                                                      .removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      16.verticalSpace,

                      // ---------------- VIDEO CARD ----------------
                      Obx(() {
                        final category = _categoryName(roomController);
                        final isFlat = category == 'Flat Sale/Buy';
                        final isHome = category == 'Family Home';
                        final isRider = category == 'Rider';
                        final String? video =
                            roomController.selectedVideo.value;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: mainColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.videocam_outlined,
                                      color: mainColor,
                                      size: 20,
                                    ),
                                  ),
                                  12.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      isFlat
                                          ? 'Flat Video (Optional)'
                                          : isHome
                                          ? 'Home Video (Optional)'
                                          : isRider
                                          ? 'Rider Video (Optional)'
                                          : 'Room Video (Optional)',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Material(
                                  color: mainColor.withValues(alpha: 0.06),
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: mainColor.withValues(alpha: 0.6),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => roomController.pickRoomVideo(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 22,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.video_library_outlined,
                                              size: 30,
                                              color: mainColor,
                                            ),
                                            8.verticalSpace,
                                            Text(
                                              'Choose Video',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF111827),
                                              ),
                                            ),
                                            2.verticalSpace,
                                            Text(
                                              'Tap to browse',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (video != null && video.isNotEmpty) ...[
                                16.verticalSpace,
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.video_file_rounded,
                                        color: mainColor,
                                      ),
                                      10.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          video.split('/').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap:
                                              () =>
                                                  roomController.removeVideo(),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      24.verticalSpace,

                      // ---------------- SAVE BUTTON ----------------
                      Obx(() {
                        return customButton2(
                          title: 'Save & Continue',
                          icon: Icons.save_rounded,
                          isLoading: roomController.isLoading.value,
                          onTap: () {
                            if (roomController.isLoading.value) return;
                            roomController.submitRoom();
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP VIEW
// =============================================================================

class AddRoomDesktopView extends StatelessWidget {
  final QuickTechPropertyRoomController roomController;
  final CommonController commonController;

  const AddRoomDesktopView({
    super.key,
    required this.roomController,
    required this.commonController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ---------------- TOP BAR ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                16.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Room',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      'Fill in the details below to list a new room',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- BODY ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- LEFT COLUMN ----------------
                      Expanded(
                        child: Column(
                          children: [
                            // BASIC INFORMATION CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.apartment_rounded,
                                          color: mainColor,
                                          size: 20,
                                        ),
                                      ),
                                      12.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          'Basic Information',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.verticalSpace,
                                  Obx(() {
                                    final category = _categoryName(
                                      roomController,
                                    );
                                    final isFlat = category == 'Flat Sale/Buy';
                                    final isHome = category == 'Family Home';
                                    final isRider = category == 'Rider';
                                    final showBed = !isFlat && !isRider;

                                    return Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: customDropdownField(
                                                hint: 'Select Property',
                                                items:
                                                    commonController.properties
                                                        .map((item) {
                                                          return DropdownMenuItem<
                                                            Properties
                                                          >(
                                                            value: item,
                                                            child: Text(
                                                              item.title ?? '',
                                                            ),
                                                          );
                                                        })
                                                        .toList(),
                                                value:
                                                    roomController
                                                        .selectedProperty
                                                        .value,
                                                onChanged: (value) {
                                                  _onPropertyChanged(
                                                    roomController,
                                                    value,
                                                  );
                                                },
                                              ),
                                            ),
                                            16.horizontalSpace,
                                            Expanded(
                                              child: customTextField(
                                                hint:
                                                    isFlat
                                                        ? 'Flat Name'
                                                        : isHome
                                                        ? 'Home Name'
                                                        : isRider
                                                        ? 'Rider Name'
                                                        : 'Room Name',
                                                isSuffix: false,
                                                isVisible: true,
                                                controller:
                                                    roomController
                                                        .roomNameController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        14.verticalSpace,
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: customDropdownField(
                                                hint:
                                                    (isFlat || isHome)
                                                        ? 'Type of Flat'
                                                        : isRider
                                                        ? 'Type of Rider'
                                                        : 'Type of Room',
                                                items:
                                                    commonController.roomTypes
                                                        .map((item) {
                                                          return DropdownMenuItem<
                                                            Type
                                                          >(
                                                            value: item,
                                                            child: Text(
                                                              item.name ?? '',
                                                            ),
                                                          );
                                                        })
                                                        .toList(),
                                                value:
                                                    roomController
                                                        .selectedRoomType
                                                        .value,
                                                onChanged: (value) {
                                                  roomController
                                                      .selectedRoomType
                                                      .value = value;
                                                },
                                              ),
                                            ),
                                            16.horizontalSpace,
                                            Expanded(
                                              child:
                                                  showBed
                                                      ? customDropdownField(
                                                        hint: 'Type of Beds',
                                                        items:
                                                            commonController
                                                                .bedTypes
                                                                .map((item) {
                                                                  return DropdownMenuItem<
                                                                    Type
                                                                  >(
                                                                    value: item,
                                                                    child: Text(
                                                                      item.name ??
                                                                          '',
                                                                    ),
                                                                  );
                                                                })
                                                                .toList(),
                                                        value:
                                                            roomController
                                                                .selectedBedType
                                                                .value,
                                                        onChanged: (value) {
                                                          roomController
                                                              .selectedBedType
                                                              .value = value;
                                                        },
                                                      )
                                                      : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),

                            16.verticalSpace,

                            // PRICING & CHARGES CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.payments_outlined,
                                          color: mainColor,
                                          size: 20,
                                        ),
                                      ),
                                      12.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          'Pricing & Charges',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.verticalSpace,
                                  Obx(() {
                                    final category = _categoryName(
                                      roomController,
                                    );
                                    final isFlat = category == 'Flat Sale/Buy';
                                    final isMonthly =
                                        category == 'Family Home' ||
                                        category == 'Rider' ||
                                        category == 'Bachelor' ||
                                        category == 'Hostel';

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint:
                                                isFlat
                                                    ? 'Sale Price'
                                                    : isMonthly
                                                    ? 'Monthly Rent'
                                                    : 'Room Price(Per Night)',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .roomPriceController,
                                            keyboard: TextInputType.number,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Service Charge',
                                            isSuffix: true,
                                            isVisible: true,
                                            controller:
                                                roomController
                                                    .serviceChargeController,
                                            keyboard: TextInputType.number,
                                            supColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),

                            16.verticalSpace,

                            // CAPACITY & SIZE CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.people_outline_rounded,
                                          color: mainColor,
                                          size: 20,
                                        ),
                                      ),
                                      12.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          'Capacity & Size',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.verticalSpace,
                                  Obx(() {
                                    final category = _categoryName(
                                      roomController,
                                    );
                                    final isHotel = category == 'Hotel';
                                    final isFlat = category == 'Flat Sale/Buy';
                                    final isHome = category == 'Family Home';
                                    final isRider = category == 'Rider';

                                    return Column(
                                      children: [
                                        // Hotel: (adult, child) + (size, count)
                                        if (isHotel) ...[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: customTextField(
                                                  hint: 'Capacity of Adults',
                                                  isSuffix: true,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .adultCapacityController,
                                                  keyboard:
                                                      TextInputType.number,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                              16.horizontalSpace,
                                              Expanded(
                                                child: customTextField(
                                                  hint: 'Capacity of Children',
                                                  isSuffix: true,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .childCapacityController,
                                                  keyboard:
                                                      TextInputType.number,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          14.verticalSpace,
                                        ],
                                        // Others (not rider): (adult, size) + (count)
                                        if (!isHotel && !isRider) ...[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: customTextField(
                                                  hint: 'Capacity of Adults',
                                                  isSuffix: true,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .adultCapacityController,
                                                  keyboard:
                                                      TextInputType.number,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                              16.horizontalSpace,
                                              Expanded(
                                                child: customTextField(
                                                  hint:
                                                      isFlat
                                                          ? 'Flat Size'
                                                          : isHome
                                                          ? 'Home Size'
                                                          : 'Room Size',
                                                  isSuffix: true,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .roomSizeController,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          14.verticalSpace,
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: customTextField(
                                                  hint:
                                                      isFlat
                                                          ? 'Total Flats'
                                                          : isHome
                                                          ? 'Total Homes'
                                                          : 'Total Rooms',
                                                  isSuffix: true,
                                                  keyboard:
                                                      TextInputType.number,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .numberOfRoomController,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                              16.horizontalSpace,
                                              const Expanded(
                                                child: SizedBox.shrink(),
                                              ),
                                            ],
                                          ),
                                        ],
                                        // Hotel / Rider: (size, count)
                                        if (isHotel || isRider)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: customTextField(
                                                  hint:
                                                      isFlat
                                                          ? 'Flat Size'
                                                          : isHome
                                                          ? 'Home Size'
                                                          : 'Room Size',
                                                  isSuffix: true,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .roomSizeController,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                              16.horizontalSpace,
                                              Expanded(
                                                child: customTextField(
                                                  hint:
                                                      isFlat
                                                          ? 'Total Flats'
                                                          : isHome
                                                          ? 'Total Homes'
                                                          : 'Total Rooms',
                                                  isSuffix: true,
                                                  keyboard:
                                                      TextInputType.number,
                                                  isVisible: true,
                                                  controller:
                                                      roomController
                                                          .numberOfRoomController,
                                                  supColor: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      24.horizontalSpace,

                      // ---------------- RIGHT COLUMN ----------------
                      Expanded(
                        child: Column(
                          children: [
                            // AMENITIES CARD (HOTEL ONLY)
                            Obx(() {
                              final isHotel =
                                  _categoryName(roomController) == 'Hotel';

                              if (!isHotel) return const SizedBox.shrink();

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: mainColor.withValues(
                                                  alpha: 0.14,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.checklist_rounded,
                                                color: mainColor,
                                                size: 20,
                                              ),
                                            ),
                                            12.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                'Amenities',
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF111827,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        20.verticalSpace,
                                        QuickTechRoomAmenitiesWidget(),
                                      ],
                                    ),
                                  ),
                                  16.verticalSpace,
                                ],
                              );
                            }),

                            // DESCRIPTION CARD
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.notes_rounded,
                                          color: mainColor,
                                          size: 20,
                                        ),
                                      ),
                                      12.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.verticalSpace,
                                  customTextField(
                                    hint: 'Room Description',
                                    isSuffix: true,
                                    maxline: 5,
                                    isVisible: true,
                                    controller:
                                        roomController
                                            .roomDescriptionController,
                                    supColor: Colors.black,
                                  ),
                                ],
                              ),
                            ),

                            16.verticalSpace,

                            // IMAGES CARD
                            Obx(() {
                              final category = _categoryName(roomController);
                              final isFlat = category == 'Flat Sale/Buy';
                              final isHome = category == 'Family Home';
                              final isRider = category == 'Rider';
                              final images = roomController.selectedImages;

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: mainColor.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.photo_library_outlined,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                        ),
                                        12.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            isFlat
                                                ? 'Flat Images'
                                                : isHome
                                                ? 'Home Images'
                                                : isRider
                                                ? 'Rider Images'
                                                : 'Room Images',
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Material(
                                        color: mainColor.withValues(
                                          alpha: 0.06,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: mainColor.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 1.4,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap:
                                              () =>
                                                  roomController
                                                      .pickRoomImages(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 22,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    size: 30,
                                                    color: mainColor,
                                                  ),
                                                  8.verticalSpace,
                                                  Text(
                                                    'Choose Images',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF111827,
                                                      ),
                                                    ),
                                                  ),
                                                  2.verticalSpace,
                                                  Text(
                                                    'Tap to browse',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                        0xFF6B7280,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (images.isNotEmpty) ...[
                                      16.verticalSpace,
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: List.generate(images.length, (
                                          index,
                                        ) {
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child:
                                                    kIsWeb
                                                        ? WebSafeNetworkImage(
                                                          imageUrl:
                                                              images[index],
                                                          width: 88,
                                                          height: 88,
                                                          fit: BoxFit.cover,
                                                        )
                                                        : Image.file(
                                                          File(images[index]),
                                                          width: 88,
                                                          height: 88,
                                                          fit: BoxFit.cover,
                                                        ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:
                                                        () => roomController
                                                            .removeImage(index),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close_rounded,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),

                            16.verticalSpace,

                            // VIDEO CARD
                            Obx(() {
                              final category = _categoryName(roomController);
                              final isFlat = category == 'Flat Sale/Buy';
                              final isHome = category == 'Family Home';
                              final isRider = category == 'Rider';
                              final String? video =
                                  roomController.selectedVideo.value;

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: mainColor.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.videocam_outlined,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                        ),
                                        12.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            isFlat
                                                ? 'Flat Video (Optional)'
                                                : isHome
                                                ? 'Home Video (Optional)'
                                                : isRider
                                                ? 'Rider Video (Optional)'
                                                : 'Room Video (Optional)',
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Material(
                                        color: mainColor.withValues(
                                          alpha: 0.06,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: mainColor.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 1.4,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap:
                                              () =>
                                                  roomController
                                                      .pickRoomVideo(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 22,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .video_library_outlined,
                                                    size: 30,
                                                    color: mainColor,
                                                  ),
                                                  8.verticalSpace,
                                                  Text(
                                                    'Choose Video',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF111827,
                                                      ),
                                                    ),
                                                  ),
                                                  2.verticalSpace,
                                                  Text(
                                                    'Tap to browse',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                        0xFF6B7280,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (video != null && video.isNotEmpty) ...[
                                      16.verticalSpace,
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.video_file_rounded,
                                              color: mainColor,
                                            ),
                                            10.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                video.split('/').last,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: const Color(
                                                    0xFF111827,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap:
                                                    () =>
                                                        roomController
                                                            .removeVideo(),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),

                            24.verticalSpace,

                            // SAVE BUTTON
                            Obx(() {
                              return customButton2(
                                title: 'Save & Continue',
                                icon: Icons.save_rounded,
                                isLoading: roomController.isLoading.value,
                                onTap: () {
                                  if (roomController.isLoading.value) return;
                                  roomController.submitRoom();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
