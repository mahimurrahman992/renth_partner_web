import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:renth_manager/controller/quick_tech_room_details_controller.dart';
import 'package:renth_manager/model/response/quickech_get_room_data.dart';
import 'package:renth_manager/widgets/quick_tech_custom_dropdown.dart';
import 'package:renth_manager/widgets/web_image.dart';

import '../../consts/consts.dart';

class RoomDetailsPage extends StatefulWidget {
  final int roomId;

  const RoomDetailsPage({super.key, required this.roomId});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  late final RoomDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RoomDetailsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRoomDetails(widget.roomId);
    });
  }

  @override
  void dispose() {
    Get.delete<RoomDetailsController>();
    super.dispose();
  }

  void _showSourcePicker(
    String title,
    void Function(ImageSource source) onSelected,
  ) {
    if (kIsWeb) {
      onSelected(ImageSource.gallery);
      return;
    }
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: const Color(0xFFF3F4F6),
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          onSelected(ImageSource.camera);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: mainColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Material(
                      color: const Color(0xFFF3F4F6),
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          onSelected(ImageSource.gallery);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library_rounded,
                                color: mainColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onPickImages() =>
        _showSourcePicker('Select Image Source', controller.pickImages);
    void onPickVideo() =>
        _showSourcePicker('Select Video Source', controller.pickVideo);
    void onRetry() => controller.fetchRoomDetails(widget.roomId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          if (width < 600) {
            return RoomDetailsMobileView(
              controller: controller,
              roomId: widget.roomId,
              onPickImages: onPickImages,
              onPickVideo: onPickVideo,
              onRetry: onRetry,
            );
          } else if (width < 1024) {
            return RoomDetailsTabletView(
              controller: controller,
              roomId: widget.roomId,
              onPickImages: onPickImages,
              onPickVideo: onPickVideo,
              onRetry: onRetry,
            );
          } else {
            return RoomDetailsDesktopView(
              controller: controller,
              roomId: widget.roomId,
              onPickImages: onPickImages,
              onPickVideo: onPickVideo,
              onRetry: onRetry,
            );
          }
        },
      ),
    );
  }
}

// =============================================================================
// MOBILE VIEW
// =============================================================================

class RoomDetailsMobileView extends StatelessWidget {
  final RoomDetailsController controller;
  final int roomId;
  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;
  final VoidCallback onRetry;

  const RoomDetailsMobileView({
    super.key,
    required this.controller,
    required this.roomId,
    required this.onPickImages,
    required this.onPickVideo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
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
    );
    final titleStyle = TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
    );
    final iconBoxDecoration = BoxDecoration(
      color: mainColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, mainColor.withValues(alpha: 0.75)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 24.w, 20.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  14.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Room Details',
                      style: TextStyle(
                        fontSize: 24.sp,
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
                decoration: BoxDecoration(color: const Color(0xFFF7F8FA)),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(color: mainColor),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 40,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 160,
                                child: customButton2(
                                  title: 'Retry',
                                  icon: Icons.refresh_rounded,
                                  onTap: onRetry,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              24.h,
                              16.w,
                              24.h,
                            ),
                            child: Column(
                              children: [
                                // ---------------- BASIC INFORMATION ----------------
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: cardDecoration,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              'Basic Information',
                                              style: titleStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.verticalSpace,
                                      Obx(() {
                                        final category =
                                            controller
                                                .selectedProperty
                                                .value
                                                ?.propertyCategory
                                                ?.name
                                                ?.trim() ??
                                            'Hotel';
                                        final isFlat =
                                            category == 'Flat Sale/Buy';
                                        final isHome =
                                            category == 'Family Home';
                                        final isRider = category == 'Rider';
                                        final showBed = !isFlat && !isRider;

                                        return Column(
                                          children: [
                                            customDropdownField<Properties>(
                                              hint: 'Property',
                                              items:
                                                  controller.properties.map((
                                                    prop,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      Properties
                                                    >(
                                                      value: prop,
                                                      child: Text(
                                                        prop.title ?? '',
                                                      ),
                                                    );
                                                  }).toList(),
                                              value:
                                                  controller
                                                      .selectedProperty
                                                      .value,
                                              onChanged: (val) {
                                                controller
                                                    .selectedProperty
                                                    .value = val;
                                                final isHotel =
                                                    (val?.propertyCategory?.name
                                                            ?.trim()
                                                            .toLowerCase() ??
                                                        '') ==
                                                    'hotel';
                                                if (!isHotel) {
                                                  controller.selectedFacilityIds
                                                      .clear();
                                                }
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
                                              controller:
                                                  controller.roomNameController,
                                              isSuffix: false,
                                              isVisible: true,
                                              icon: Icons.meeting_room_outlined,
                                            ),
                                            14.verticalSpace,
                                            customDropdownField<Type>(
                                              hint:
                                                  (isFlat || isHome)
                                                      ? 'Flat Type'
                                                      : isRider
                                                      ? 'Rider Type'
                                                      : 'Room Type',
                                              items:
                                                  controller.roomTypes.map((
                                                    rt,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      Type
                                                    >(
                                                      value: rt,
                                                      child: Text(
                                                        rt.name ?? '',
                                                      ),
                                                    );
                                                  }).toList(),
                                              value:
                                                  controller
                                                      .selectedRoomType
                                                      .value,
                                              onChanged:
                                                  (val) =>
                                                      controller
                                                          .selectedRoomType
                                                          .value = val,
                                            ),
                                            if (showBed) ...[
                                              14.verticalSpace,
                                              customDropdownField<Type>(
                                                hint: 'Bed Type',
                                                items:
                                                    controller.bedTypes.map((
                                                      bt,
                                                    ) {
                                                      return DropdownMenuItem<
                                                        Type
                                                      >(
                                                        value: bt,
                                                        child: Text(
                                                          bt.name ?? '',
                                                        ),
                                                      );
                                                    }).toList(),
                                                value:
                                                    controller
                                                        .selectedBedType
                                                        .value,
                                                onChanged:
                                                    (val) =>
                                                        controller
                                                            .selectedBedType
                                                            .value = val,
                                              ),
                                            ],
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                16.verticalSpace,

                                // ---------------- PRICING & CHARGES ----------------
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: cardDecoration,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.payments_outlined,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              'Pricing & Charges',
                                              style: titleStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.verticalSpace,
                                      Obx(() {
                                        final category =
                                            controller
                                                .selectedProperty
                                                .value
                                                ?.propertyCategory
                                                ?.name
                                                ?.trim() ??
                                            'Hotel';
                                        final isHotel = category == 'Hotel';
                                        final isFlat =
                                            category == 'Flat Sale/Buy';

                                        return Column(
                                          children: [
                                            customTextField(
                                              hint:
                                                  isFlat
                                                      ? 'Sale Price'
                                                      : isHotel
                                                      ? 'Price Per Night'
                                                      : 'Monthly Rent',
                                              controller:
                                                  controller
                                                      .roomPriceController,
                                              isSuffix: false,
                                              isVisible: true,
                                              icon: Icons.attach_money_rounded,
                                              keyboard: TextInputType.number,
                                            ),
                                            14.verticalSpace,
                                            // customTextField(
                                            //   hint:
                                            //       isFlat
                                            //           ? 'Discount Sale Price'
                                            //           : isHotel
                                            //           ? 'Discount Price Per Night'
                                            //           : 'Discount Monthly Rent',
                                            //   controller:
                                            //       controller
                                            //           .discountPriceController,
                                            //   isSuffix: false,
                                            //   isVisible: true,
                                            //   icon: Icons.money_off_rounded,
                                            //   keyboard: TextInputType.number,
                                            // ),
                                            // if (isHotel) ...[
                                            //   14.verticalSpace,
                                            //   customTextField(
                                            //     hint: 'Extra Price Per Adult',
                                            //     controller:
                                            //         controller
                                            //             .extraPriceAdultController,
                                            //     isSuffix: false,
                                            //     isVisible: true,
                                            //     icon:
                                            //         Icons
                                            //             .person_add_alt_1_outlined,
                                            //     keyboard: TextInputType.number,
                                            //   ),
                                            //   14.verticalSpace,
                                            //   customTextField(
                                            //     hint:
                                            //         'Extra Price Per Child Bed',
                                            //     controller:
                                            //         controller
                                            //             .extraPriceChildController,
                                            //     isSuffix: false,
                                            //     isVisible: true,
                                            //     icon: Icons.child_care_rounded,
                                            //     keyboard: TextInputType.number,
                                            //   ),
                                            //   14.verticalSpace,
                                            //   customTextField(
                                            //     hint:
                                            //         'Extra Mattress Price Per Night',
                                            //     controller:
                                            //         controller
                                            //             .extraMattressPriceController,
                                            //     isSuffix: false,
                                            //     isVisible: true,
                                            //     icon: Icons.bed_rounded,
                                            //     keyboard: TextInputType.number,
                                            //   ),
                                            // ],
                                            // 14.verticalSpace,
                                            // customTextField(
                                            //   hint: 'VAT %',
                                            //   controller: controller.vatPercentageController,
                                            //   isSuffix: false,
                                            //   isVisible: true,
                                            //   icon: Icons.percent_rounded,
                                            //   keyboard: TextInputType.number,
                                            // ),
                                            14.verticalSpace,
                                            customTextField(
                                              hint: 'Service Charge',
                                              controller:
                                                  controller
                                                      .serviceChargeController,
                                              isSuffix: false,
                                              isVisible: true,
                                              icon: Icons.room_service_outlined,
                                              keyboard: TextInputType.number,
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                16.verticalSpace,

                                // ---------------- CAPACITY & DIMENSIONS ----------------
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: cardDecoration,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.straighten_rounded,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              'Capacity & Dimensions',
                                              style: titleStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.verticalSpace,
                                      Obx(() {
                                        final category =
                                            controller
                                                .selectedProperty
                                                .value
                                                ?.propertyCategory
                                                ?.name
                                                ?.trim() ??
                                            'Hotel';
                                        final isFlat =
                                            category == 'Flat Sale/Buy';
                                        final isHome =
                                            category == 'Family Home';
                                        final isRider = category == 'Rider';
                                        final isBachelor =
                                            category == 'Bachelor';
                                        final showAdults = !isRider;
                                        final showChildren =
                                            !isBachelor && !isRider && !isFlat;

                                        return Column(
                                          children: [
                                            if (showAdults) ...[
                                              customTextField(
                                                hint: 'Adults Limit',
                                                controller:
                                                    controller
                                                        .capacityAdultsController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon: Icons.people_alt_outlined,
                                                keyboard: TextInputType.number,
                                              ),
                                              14.verticalSpace,
                                            ],
                                            if (showChildren) ...[
                                              customTextField(
                                                hint: 'Children Limit',
                                                controller:
                                                    controller
                                                        .capacityChildrenController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon:
                                                    Icons
                                                        .child_friendly_outlined,
                                                keyboard: TextInputType.number,
                                              ),
                                              14.verticalSpace,
                                            ],
                                            customTextField(
                                              hint:
                                                  isFlat
                                                      ? 'Flat Size'
                                                      : isHome
                                                      ? 'Home Size'
                                                      : 'Room Size (sq ft)',
                                              controller:
                                                  controller.roomSizeController,
                                              isSuffix: false,
                                              isVisible: true,
                                              icon:
                                                  Icons
                                                      .photo_size_select_small_rounded,
                                            ),
                                            14.verticalSpace,
                                            customTextField(
                                              hint:
                                                  isFlat
                                                      ? 'Total Flats'
                                                      : isHome
                                                      ? 'Total Homes'
                                                      : 'Total Rooms',
                                              controller:
                                                  controller
                                                      .numberOfRoomController,
                                              isSuffix: false,
                                              isVisible: true,
                                              icon: Icons.layers_outlined,
                                              keyboard: TextInputType.number,
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),

                                16.verticalSpace,

                                // ---------------- DESCRIPTION ----------------
                                Obx(() {
                                  final category =
                                      controller
                                          .selectedProperty
                                          .value
                                          ?.propertyCategory
                                          ?.name
                                          ?.trim() ??
                                      'Hotel';
                                  final descTitle =
                                      category == 'Flat Sale/Buy'
                                          ? 'Flat Description'
                                          : category == 'Family Home'
                                          ? 'Home Description'
                                          : category == 'Rider'
                                          ? 'Rider Description'
                                          : 'Description';

                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: cardDecoration,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.description_outlined,
                                              color: mainColor,
                                              size: 20,
                                            ),
                                            12.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                descTitle,
                                                style: titleStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        20.verticalSpace,
                                        customTextField(
                                          hint: descTitle,
                                          controller:
                                              controller
                                                  .roomDescriptionController,
                                          isSuffix: false,
                                          isVisible: true,
                                          maxline: 4,
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                16.verticalSpace,

                                // ---------------- FACILITIES (HOTEL ONLY) ----------------
                                Obx(() {
                                  final category =
                                      controller
                                          .selectedProperty
                                          .value
                                          ?.propertyCategory
                                          ?.name
                                          ?.trim() ??
                                      'Hotel';
                                  if (category != 'Hotel') {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: cardDecoration,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: iconBoxDecoration,
                                                  child: Icon(
                                                    Icons.all_inclusive_rounded,
                                                    color: mainColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                12.horizontalSpace,
                                                Expanded(
                                                  child: Text(
                                                    'Facilities Available',
                                                    style: titleStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            20.verticalSpace,
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 10,
                                              children:
                                                  controller.facilities.map((
                                                    facility,
                                                  ) {
                                                    final bool isSelected =
                                                        controller
                                                            .selectedFacilityIds
                                                            .contains(
                                                              facility.id,
                                                            );

                                                    return MouseRegion(
                                                      cursor:
                                                          SystemMouseCursors
                                                              .click,
                                                      child: Material(
                                                        color:
                                                            isSelected
                                                                ? mainColor
                                                                : Colors.white,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                          side: BorderSide(
                                                            color:
                                                                isSelected
                                                                    ? mainColor
                                                                    : const Color(
                                                                      0xFFE5E7EB,
                                                                    ),
                                                            width:
                                                                isSelected
                                                                    ? 1.5
                                                                    : 1,
                                                          ),
                                                        ),
                                                        child: InkWell(
                                                          onTap:
                                                              () => controller
                                                                  .toggleFacility(
                                                                    facility.id ??
                                                                        0,
                                                                  ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 9,
                                                                ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  isSelected
                                                                      ? Icons
                                                                          .check_circle_rounded
                                                                      : Icons
                                                                          .add_circle_outline_rounded,
                                                                  size: 18,
                                                                  color:
                                                                      isSelected
                                                                          ? Colors
                                                                              .black87
                                                                          : Colors
                                                                              .grey
                                                                              .shade600,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  facility.name ??
                                                                      '',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13.5,
                                                                    fontWeight:
                                                                        isSelected
                                                                            ? FontWeight.w700
                                                                            : FontWeight.w500,
                                                                    color:
                                                                        Colors
                                                                            .black87,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      16.verticalSpace,
                                    ],
                                  );
                                }),

                                // ---------------- MEDIA ----------------
                                Obx(() {
                                  final category =
                                      controller
                                          .selectedProperty
                                          .value
                                          ?.propertyCategory
                                          ?.name
                                          ?.trim() ??
                                      'Hotel';
                                  final mediaTitle =
                                      category == 'Flat Sale/Buy'
                                          ? 'Flat Media Attachments'
                                          : category == 'Family Home'
                                          ? 'Home Media Attachments'
                                          : category == 'Rider'
                                          ? 'Rider Media Attachments'
                                          : 'Media Attachments';

                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: cardDecoration,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.perm_media_outlined,
                                              color: mainColor,
                                              size: 20,
                                            ),
                                            12.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                mediaTitle,
                                                style: titleStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        20.verticalSpace,
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Material(
                                                color: mainColor.withValues(
                                                  alpha: 0.06,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  side: BorderSide(
                                                    color: mainColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: onPickImages,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 18,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.image_outlined,
                                                          size: 28,
                                                          color: mainColor,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        const Text(
                                                          'Pick Images',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                              0xFF111827,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Material(
                                                color: mainColor.withValues(
                                                  alpha: 0.06,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  side: BorderSide(
                                                    color: mainColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: onPickVideo,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 18,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .video_library_outlined,
                                                          size: 28,
                                                          color: mainColor,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        const Text(
                                                          'Pick Video',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                              0xFF111827,
                                                            ),
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

                                        // Existing Images
                                        Obx(() {
                                          final images =
                                              controller.existingImages;
                                          if (images.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Existing Images',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF374151),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${images.length} image${images.length > 1 ? 's' : ''}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              GridView(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 100,
                                                      crossAxisSpacing: 8,
                                                      mainAxisSpacing: 8,
                                                    ),
                                                children: List.generate(images.length, (
                                                  index,
                                                ) {
                                                  final img = images[index];
                                                  return Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child:
                                                            WebSafeNetworkImage(
                                                              imageUrl:
                                                                  img.photoName,
                                                              fit: BoxFit.cover,
                                                            ),
                                                      ),
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .removeExistingImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.65,
                                                                      ),
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ],
                                          );
                                        }),

                                        // Video (new or existing)
                                        Obx(() {
                                          final selectedVideo =
                                              controller.selectedVideo.value;
                                          final existingVideo =
                                              controller.existingVideo.value;

                                          if (selectedVideo == null &&
                                              existingVideo == null) {
                                            return const SizedBox.shrink();
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedVideo != null
                                                        ? const Color(
                                                          0xFFECFDF5,
                                                        )
                                                        : const Color(
                                                          0xFFF3F4F6,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      selectedVideo != null
                                                          ? const Color(
                                                            0xFFA7F3D0,
                                                          )
                                                          : const Color(
                                                            0xFFE5E7EB,
                                                          ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    selectedVideo != null
                                                        ? Icons
                                                            .check_circle_rounded
                                                        : Icons
                                                            .videocam_rounded,
                                                    color:
                                                        selectedVideo != null
                                                            ? const Color(
                                                              0xFF059669,
                                                            )
                                                            : mainColor,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          selectedVideo != null
                                                              ? (existingVideo !=
                                                                      null
                                                                  ? 'New Video Selected (Replaces existing)'
                                                                  : 'New Video Selected')
                                                              : 'Existing Video',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                        Text(
                                                          selectedVideo != null
                                                              ? selectedVideo
                                                                  .path
                                                                  .split('/')
                                                                  .last
                                                              : existingVideo!
                                                                  .split('/')
                                                                  .last,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13.5,
                                                                color: Color(
                                                                  0xFF374151,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        () =>
                                                            selectedVideo !=
                                                                    null
                                                                ? controller
                                                                    .removeSelectedVideo()
                                                                : controller
                                                                    .removeExistingVideo(),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close_rounded,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),

                                        // New Images
                                        Obx(() {
                                          final images =
                                              controller.selectedImages;
                                          if (images.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'New Images',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF374151),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${images.length} new image${images.length > 1 ? 's' : ''}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF059669),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              GridView(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                                      maxCrossAxisExtent: 100,
                                                      crossAxisSpacing: 8,
                                                      mainAxisSpacing: 8,
                                                    ),
                                                children: List.generate(images.length, (
                                                  index,
                                                ) {
                                                  return Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child:
                                                            kIsWeb
                                                                ? WebSafeNetworkImage(
                                                                  imageUrl:
                                                                      images[index]
                                                                          .path,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                )
                                                                : Image.file(
                                                                  images[index],
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                      ),
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .removeSelectedImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.65,
                                                                      ),
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // ---------------- FOOTER ----------------
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed:
                                        () => controller.deleteRoom(propertyRoomId: roomId),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.red,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Delete Room',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Obx(() {
                                  return customButton2(
                                    title: 'Save Details',
                                    icon: Icons.save_rounded,iconColor: black,
                                    height: 52,
                                    isLoading: controller.isUpdating.value,
                                    onTap: () {
                                      if (controller.isUpdating.value) return;
                                      controller.updateRoomDetails(roomId);
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TABLET VIEW
// =============================================================================

class RoomDetailsTabletView extends StatelessWidget {
  final RoomDetailsController controller;
  final int roomId;
  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;
  final VoidCallback onRetry;

  const RoomDetailsTabletView({
    super.key,
    required this.controller,
    required this.roomId,
    required this.onPickImages,
    required this.onPickVideo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
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
    );
    final titleStyle = TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
    );
    final iconBoxDecoration = BoxDecoration(
      color: mainColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    );

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
                      'Room Details',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      'Edit pricing, facilities and media',
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: mainColor),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 160,
                          child: customButton2(
                            title: 'Retry',
                            icon: Icons.refresh_rounded,
                            onTap: onRetry,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            children: [
                              // ---------------- BASIC INFORMATION ----------------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: cardDecoration,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: iconBoxDecoration,
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                        ),
                                        12.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            'Basic Information',
                                            style: titleStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      final isFlat =
                                          category == 'Flat Sale/Buy';
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
                                                child: customDropdownField<
                                                  Properties
                                                >(
                                                  hint: 'Property',
                                                  items:
                                                      controller.properties.map((
                                                        prop,
                                                      ) {
                                                        return DropdownMenuItem<
                                                          Properties
                                                        >(
                                                          value: prop,
                                                          child: Text(
                                                            prop.title ?? '',
                                                          ),
                                                        );
                                                      }).toList(),
                                                  value:
                                                      controller
                                                          .selectedProperty
                                                          .value,
                                                  onChanged: (val) {
                                                    controller
                                                        .selectedProperty
                                                        .value = val;
                                                    final isHotel =
                                                        (val
                                                                ?.propertyCategory
                                                                ?.name
                                                                ?.trim()
                                                                .toLowerCase() ??
                                                            '') ==
                                                        'hotel';
                                                    if (!isHotel) {
                                                      controller
                                                          .selectedFacilityIds
                                                          .clear();
                                                    }
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
                                                  controller:
                                                      controller
                                                          .roomNameController,
                                                  isSuffix: false,
                                                  isVisible: true,
                                                  icon:
                                                      Icons
                                                          .meeting_room_outlined,
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
                                                child: customDropdownField<
                                                  Type
                                                >(
                                                  hint:
                                                      (isFlat || isHome)
                                                          ? 'Flat Type'
                                                          : isRider
                                                          ? 'Rider Type'
                                                          : 'Room Type',
                                                  items:
                                                      controller.roomTypes.map((
                                                        rt,
                                                      ) {
                                                        return DropdownMenuItem<
                                                          Type
                                                        >(
                                                          value: rt,
                                                          child: Text(
                                                            rt.name ?? '',
                                                          ),
                                                        );
                                                      }).toList(),
                                                  value:
                                                      controller
                                                          .selectedRoomType
                                                          .value,
                                                  onChanged:
                                                      (val) =>
                                                          controller
                                                              .selectedRoomType
                                                              .value = val,
                                                ),
                                              ),
                                              16.horizontalSpace,
                                              Expanded(
                                                child:
                                                    showBed
                                                        ? customDropdownField<
                                                          Type
                                                        >(
                                                          hint: 'Bed Type',
                                                          items:
                                                              controller.bedTypes.map((
                                                                bt,
                                                              ) {
                                                                return DropdownMenuItem<
                                                                  Type
                                                                >(
                                                                  value: bt,
                                                                  child: Text(
                                                                    bt.name ??
                                                                        '',
                                                                  ),
                                                                );
                                                              }).toList(),
                                                          value:
                                                              controller
                                                                  .selectedBedType
                                                                  .value,
                                                          onChanged:
                                                              (val) =>
                                                                  controller
                                                                      .selectedBedType
                                                                      .value = val,
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

                              // ---------------- PRICING & CHARGES ----------------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: cardDecoration,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: iconBoxDecoration,
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
                                            style: titleStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      final isHotel = category == 'Hotel';
                                      final isFlat =
                                          category == 'Flat Sale/Buy';

                                      final fields = <Widget>[
                                        customTextField(
                                          hint:
                                              isFlat
                                                  ? 'Sale Price'
                                                  : isHotel
                                                  ? 'Price Per Night'
                                                  : 'Monthly Rent',
                                          controller:
                                              controller.roomPriceController,
                                          isSuffix: false,
                                          isVisible: true,
                                          icon: Icons.attach_money_rounded,
                                          keyboard: TextInputType.number,
                                        ),
                                        // customTextField(
                                        //   hint:
                                        //       isFlat
                                        //           ? 'Discount Sale Price'
                                        //           : isHotel
                                        //           ? 'Discount Price Per Night'
                                        //           : 'Discount Monthly Rent',
                                        //   controller:
                                        //       controller
                                        //           .discountPriceController,
                                        //   isSuffix: false,
                                        //   isVisible: true,
                                        //   icon: Icons.money_off_rounded,
                                        //   keyboard: TextInputType.number,
                                        // ),
                                        // if (isHotel) ...[
                                        //   customTextField(
                                        //     hint: 'Extra Price Per Adult',
                                        //     controller:
                                        //         controller
                                        //             .extraPriceAdultController,
                                        //     isSuffix: false,
                                        //     isVisible: true,
                                        //     icon:
                                        //         Icons.person_add_alt_1_outlined,
                                        //     keyboard: TextInputType.number,
                                        //   ),
                                        //   customTextField(
                                        //     hint: 'Extra Price Per Child Bed',
                                        //     controller:
                                        //         controller
                                        //             .extraPriceChildController,
                                        //     isSuffix: false,
                                        //     isVisible: true,
                                        //     icon: Icons.child_care_rounded,
                                        //     keyboard: TextInputType.number,
                                        //   ),
                                        //   customTextField(
                                        //     hint:
                                        //         'Extra Mattress Price Per Night',
                                        //     controller:
                                        //         controller
                                        //             .extraMattressPriceController,
                                        //     isSuffix: false,
                                        //     isVisible: true,
                                        //     icon: Icons.bed_rounded,
                                        //     keyboard: TextInputType.number,
                                        //   ),
                                        // ],
                                        // customTextField(
                                        //   hint: 'VAT %',
                                        //   controller: controller.vatPercentageController,
                                        //   isSuffix: false,
                                        //   isVisible: true,
                                        //   icon: Icons.percent_rounded,
                                        //   keyboard: TextInputType.number,
                                        // ),
                                        customTextField(
                                          hint: 'Service Charge',
                                          controller:
                                              controller
                                                  .serviceChargeController,
                                          isSuffix: false,
                                          isVisible: true,
                                          icon: Icons.room_service_outlined,
                                          keyboard: TextInputType.number,
                                        ),
                                      ];

                                      return Column(
                                        children: [
                                          for (
                                            int i = 0;
                                            i < fields.length;
                                            i += 2
                                          )
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    i + 2 < fields.length
                                                        ? 14
                                                        : 0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(child: fields[i]),
                                                  16.horizontalSpace,
                                                  Expanded(
                                                    child:
                                                        i + 1 < fields.length
                                                            ? fields[i + 1]
                                                            : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              16.verticalSpace,

                              // ---------------- CAPACITY & DIMENSIONS ----------------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: cardDecoration,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: iconBoxDecoration,
                                          child: Icon(
                                            Icons.straighten_rounded,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                        ),
                                        12.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            'Capacity & Dimensions',
                                            style: titleStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.verticalSpace,
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      final isFlat =
                                          category == 'Flat Sale/Buy';
                                      final isHome = category == 'Family Home';
                                      final isRider = category == 'Rider';
                                      final isBachelor = category == 'Bachelor';
                                      final showAdults = !isRider;
                                      final showChildren =
                                          !isBachelor && !isRider && !isFlat;

                                      final fields = <Widget>[
                                        if (showAdults)
                                          customTextField(
                                            hint: 'Adults Limit',
                                            controller:
                                                controller
                                                    .capacityAdultsController,
                                            isSuffix: false,
                                            isVisible: true,
                                            icon: Icons.people_alt_outlined,
                                            keyboard: TextInputType.number,
                                          ),
                                        if (showChildren)
                                          customTextField(
                                            hint: 'Children Limit',
                                            controller:
                                                controller
                                                    .capacityChildrenController,
                                            isSuffix: false,
                                            isVisible: true,
                                            icon: Icons.child_friendly_outlined,
                                            keyboard: TextInputType.number,
                                          ),
                                        customTextField(
                                          hint:
                                              isFlat
                                                  ? 'Flat Size'
                                                  : isHome
                                                  ? 'Home Size'
                                                  : 'Room Size (sq ft)',
                                          controller:
                                              controller.roomSizeController,
                                          isSuffix: false,
                                          isVisible: true,
                                          icon:
                                              Icons
                                                  .photo_size_select_small_rounded,
                                        ),
                                        customTextField(
                                          hint:
                                              isFlat
                                                  ? 'Total Flats'
                                                  : isHome
                                                  ? 'Total Homes'
                                                  : 'Total Rooms',
                                          controller:
                                              controller.numberOfRoomController,
                                          isSuffix: false,
                                          isVisible: true,
                                          icon: Icons.layers_outlined,
                                          keyboard: TextInputType.number,
                                        ),
                                      ];

                                      return Column(
                                        children: [
                                          for (
                                            int i = 0;
                                            i < fields.length;
                                            i += 2
                                          )
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    i + 2 < fields.length
                                                        ? 14
                                                        : 0,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(child: fields[i]),
                                                  16.horizontalSpace,
                                                  Expanded(
                                                    child:
                                                        i + 1 < fields.length
                                                            ? fields[i + 1]
                                                            : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              16.verticalSpace,

                              // ---------------- DESCRIPTION ----------------
                              Obx(() {
                                final category =
                                    controller
                                        .selectedProperty
                                        .value
                                        ?.propertyCategory
                                        ?.name
                                        ?.trim() ??
                                    'Hotel';
                                final descTitle =
                                    category == 'Flat Sale/Buy'
                                        ? 'Flat Description'
                                        : category == 'Family Home'
                                        ? 'Home Description'
                                        : category == 'Rider'
                                        ? 'Rider Description'
                                        : 'Description';

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: cardDecoration,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: iconBoxDecoration,
                                            child: Icon(
                                              Icons.description_outlined,
                                              color: mainColor,
                                              size: 20,
                                            ),
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              descTitle,
                                              style: titleStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.verticalSpace,
                                      customTextField(
                                        hint: descTitle,
                                        controller:
                                            controller
                                                .roomDescriptionController,
                                        isSuffix: false,
                                        isVisible: true,
                                        maxline: 4,
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              16.verticalSpace,

                              // ---------------- FACILITIES (HOTEL ONLY) ----------------
                              Obx(() {
                                final category =
                                    controller
                                        .selectedProperty
                                        .value
                                        ?.propertyCategory
                                        ?.name
                                        ?.trim() ??
                                    'Hotel';
                                if (category != 'Hotel') {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: cardDecoration,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: iconBoxDecoration,
                                                child: Icon(
                                                  Icons.all_inclusive_rounded,
                                                  color: mainColor,
                                                  size: 20,
                                                ),
                                              ),
                                              12.horizontalSpace,
                                              Expanded(
                                                child: Text(
                                                  'Facilities Available',
                                                  style: titleStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          20.verticalSpace,
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 10,
                                            children:
                                                controller.facilities.map((
                                                  facility,
                                                ) {
                                                  final bool isSelected =
                                                      controller
                                                          .selectedFacilityIds
                                                          .contains(
                                                            facility.id,
                                                          );

                                                  return MouseRegion(
                                                    cursor:
                                                        SystemMouseCursors
                                                            .click,
                                                    child: Material(
                                                      color:
                                                          isSelected
                                                              ? mainColor
                                                              : Colors.white,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              isSelected
                                                                  ? mainColor
                                                                  : const Color(
                                                                    0xFFE5E7EB,
                                                                  ),
                                                          width:
                                                              isSelected
                                                                  ? 1.5
                                                                  : 1,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap:
                                                            () => controller
                                                                .toggleFacility(
                                                                  facility.id ??
                                                                      0,
                                                                ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 9,
                                                              ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                isSelected
                                                                    ? Icons
                                                                        .check_circle_rounded
                                                                    : Icons
                                                                        .add_circle_outline_rounded,
                                                                size: 18,
                                                                color:
                                                                    isSelected
                                                                        ? Colors
                                                                            .black87
                                                                        : Colors
                                                                            .grey
                                                                            .shade600,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                facility.name ??
                                                                    '',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      13.5,
                                                                  fontWeight:
                                                                      isSelected
                                                                          ? FontWeight
                                                                              .w700
                                                                          : FontWeight
                                                                              .w500,
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    16.verticalSpace,
                                  ],
                                );
                              }),

                              // ---------------- MEDIA ----------------
                              Obx(() {
                                final category =
                                    controller
                                        .selectedProperty
                                        .value
                                        ?.propertyCategory
                                        ?.name
                                        ?.trim() ??
                                    'Hotel';
                                final mediaTitle =
                                    category == 'Flat Sale/Buy'
                                        ? 'Flat Media Attachments'
                                        : category == 'Family Home'
                                        ? 'Home Media Attachments'
                                        : category == 'Rider'
                                        ? 'Rider Media Attachments'
                                        : 'Media Attachments';

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: cardDecoration,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: iconBoxDecoration,
                                            child: Icon(
                                              Icons.perm_media_outlined,
                                              color: mainColor,
                                              size: 20,
                                            ),
                                          ),
                                          12.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              mediaTitle,
                                              style: titleStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      20.verticalSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Material(
                                                color: mainColor.withValues(
                                                  alpha: 0.06,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  side: BorderSide(
                                                    color: mainColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: onPickImages,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 18,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.image_outlined,
                                                          size: 28,
                                                          color: mainColor,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        const Text(
                                                          'Pick Images',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                              0xFF111827,
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
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: Material(
                                                color: mainColor.withValues(
                                                  alpha: 0.06,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  side: BorderSide(
                                                    color: mainColor.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    width: 1.4,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: onPickVideo,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 18,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .video_library_outlined,
                                                          size: 28,
                                                          color: mainColor,
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        const Text(
                                                          'Pick Video',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                              0xFF111827,
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
                                        ],
                                      ),

                                      // Existing Images
                                      Obx(() {
                                        final images =
                                            controller.existingImages;
                                        if (images.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Existing Images',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                                Text(
                                                  '${images.length} image${images.length > 1 ? 's' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6B7280),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            GridView(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 100,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                  ),
                                              children: List.generate(images.length, (
                                                index,
                                              ) {
                                                final img = images[index];
                                                return Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child:
                                                          WebSafeNetworkImage(
                                                            imageUrl:
                                                                img.photoName,
                                                            fit: BoxFit.cover,
                                                          ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: MouseRegion(
                                                        cursor:
                                                            SystemMouseCursors
                                                                .click,
                                                        child: GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .removeExistingImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.65,
                                                                      ),
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
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
                                        );
                                      }),

                                      // Video (new or existing)
                                      Obx(() {
                                        final selectedVideo =
                                            controller.selectedVideo.value;
                                        final existingVideo =
                                            controller.existingVideo.value;

                                        if (selectedVideo == null &&
                                            existingVideo == null) {
                                          return const SizedBox.shrink();
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  selectedVideo != null
                                                      ? const Color(0xFFECFDF5)
                                                      : const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    selectedVideo != null
                                                        ? const Color(
                                                          0xFFA7F3D0,
                                                        )
                                                        : const Color(
                                                          0xFFE5E7EB,
                                                        ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  selectedVideo != null
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons.videocam_rounded,
                                                  color:
                                                      selectedVideo != null
                                                          ? const Color(
                                                            0xFF059669,
                                                          )
                                                          : mainColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        selectedVideo != null
                                                            ? (existingVideo !=
                                                                    null
                                                                ? 'New Video Selected (Replaces existing)'
                                                                : 'New Video Selected')
                                                            : 'Existing Video',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF6B7280,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        selectedVideo != null
                                                            ? selectedVideo.path
                                                                .split('/')
                                                                .last
                                                            : existingVideo!
                                                                .split('/')
                                                                .last,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 13.5,
                                                          color: Color(
                                                            0xFF374151,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    onTap:
                                                        () =>
                                                            selectedVideo !=
                                                                    null
                                                                ? controller
                                                                    .removeSelectedVideo()
                                                                : controller
                                                                    .removeExistingVideo(),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close_rounded,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),

                                      // New Images
                                      Obx(() {
                                        final images =
                                            controller.selectedImages;
                                        if (images.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'New Images',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                                Text(
                                                  '${images.length} new image${images.length > 1 ? 's' : ''}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF059669),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            GridView(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 100,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                  ),
                                              children: List.generate(images.length, (
                                                index,
                                              ) {
                                                return Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child:
                                                          kIsWeb
                                                              ? WebSafeNetworkImage(
                                                                imageUrl:
                                                                    images[index]
                                                                        .path,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              )
                                                              : Image.file(
                                                                images[index],
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: MouseRegion(
                                                        cursor:
                                                            SystemMouseCursors
                                                                .click,
                                                        child: GestureDetector(
                                                          onTap:
                                                              () => controller
                                                                  .removeSelectedImage(
                                                                    index,
                                                                  ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.65,
                                                                      ),
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
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
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ---------------- FOOTER ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: OutlinedButton(
                                    onPressed:
                                        () => controller.clearControllers(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear All',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Obx(() {
                                return customButton2(
                                  title: 'Save Details',
                                  icon: Icons.save_rounded,
                                  height: 52,
                                  isLoading: controller.isUpdating.value,
                                  onTap: () {
                                    if (controller.isUpdating.value) return;
                                    controller.updateRoomDetails(roomId);
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP VIEW
// =============================================================================

class RoomDetailsDesktopView extends StatelessWidget {
  final RoomDetailsController controller;
  final int roomId;
  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;
  final VoidCallback onRetry;

  const RoomDetailsDesktopView({
    super.key,
    required this.controller,
    required this.roomId,
    required this.onPickImages,
    required this.onPickVideo,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
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
    );
    final titleStyle = TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
    );
    final iconBoxDecoration = BoxDecoration(
      color: mainColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    );

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
                Text(
                  'Room Details',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- BODY ----------------
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: mainColor),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 160,
                          child: customButton2(
                            title: 'Retry',
                            icon: Icons.refresh_rounded,
                            onTap: onRetry,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 28.h,
                      ),
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
                                    // BASIC INFORMATION
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: cardDecoration,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: iconBoxDecoration,
                                                child: Icon(
                                                  Icons.info_outline_rounded,
                                                  color: mainColor,
                                                  size: 20,
                                                ),
                                              ),
                                              12.horizontalSpace,
                                              Expanded(
                                                child: Text(
                                                  'Basic Information',
                                                  style: titleStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          20.verticalSpace,
                                          Obx(() {
                                            final category =
                                                controller
                                                    .selectedProperty
                                                    .value
                                                    ?.propertyCategory
                                                    ?.name
                                                    ?.trim() ??
                                                'Hotel';
                                            final isFlat =
                                                category == 'Flat Sale/Buy';
                                            final isHome =
                                                category == 'Family Home';
                                            final isRider = category == 'Rider';
                                            final showBed = !isFlat && !isRider;

                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: customDropdownField<
                                                        Properties
                                                      >(
                                                        hint: 'Property',
                                                        items:
                                                            controller.properties.map((
                                                              prop,
                                                            ) {
                                                              return DropdownMenuItem<
                                                                Properties
                                                              >(
                                                                value: prop,
                                                                child: Text(
                                                                  prop.title ??
                                                                      '',
                                                                ),
                                                              );
                                                            }).toList(),
                                                        value:
                                                            controller
                                                                .selectedProperty
                                                                .value,
                                                        onChanged: (val) {
                                                          controller
                                                              .selectedProperty
                                                              .value = val;
                                                          final isHotel =
                                                              (val
                                                                      ?.propertyCategory
                                                                      ?.name
                                                                      ?.trim()
                                                                      .toLowerCase() ??
                                                                  '') ==
                                                              'hotel';
                                                          if (!isHotel) {
                                                            controller
                                                                .selectedFacilityIds
                                                                .clear();
                                                          }
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
                                                        controller:
                                                            controller
                                                                .roomNameController,
                                                        isSuffix: false,
                                                        isVisible: true,
                                                        icon:
                                                            Icons
                                                                .meeting_room_outlined,
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
                                                      child: customDropdownField<
                                                        Type
                                                      >(
                                                        hint:
                                                            (isFlat || isHome)
                                                                ? 'Flat Type'
                                                                : isRider
                                                                ? 'Rider Type'
                                                                : 'Room Type',
                                                        items:
                                                            controller.roomTypes
                                                                .map((rt) {
                                                                  return DropdownMenuItem<
                                                                    Type
                                                                  >(
                                                                    value: rt,
                                                                    child: Text(
                                                                      rt.name ??
                                                                          '',
                                                                    ),
                                                                  );
                                                                })
                                                                .toList(),
                                                        value:
                                                            controller
                                                                .selectedRoomType
                                                                .value,
                                                        onChanged:
                                                            (val) =>
                                                                controller
                                                                    .selectedRoomType
                                                                    .value = val,
                                                      ),
                                                    ),
                                                    16.horizontalSpace,
                                                    Expanded(
                                                      child:
                                                          showBed
                                                              ? customDropdownField<
                                                                Type
                                                              >(
                                                                hint:
                                                                    'Bed Type',
                                                                items:
                                                                    controller.bedTypes.map((
                                                                      bt,
                                                                    ) {
                                                                      return DropdownMenuItem<
                                                                        Type
                                                                      >(
                                                                        value:
                                                                            bt,
                                                                        child: Text(
                                                                          bt.name ??
                                                                              '',
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                value:
                                                                    controller
                                                                        .selectedBedType
                                                                        .value,
                                                                onChanged:
                                                                    (val) =>
                                                                        controller
                                                                            .selectedBedType
                                                                            .value = val,
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

                                    // PRICING & CHARGES
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: cardDecoration,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: iconBoxDecoration,
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
                                                  style: titleStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          20.verticalSpace,
                                          Obx(() {
                                            final category =
                                                controller
                                                    .selectedProperty
                                                    .value
                                                    ?.propertyCategory
                                                    ?.name
                                                    ?.trim() ??
                                                'Hotel';
                                            final isHotel = category == 'Hotel';
                                            final isFlat =
                                                category == 'Flat Sale/Buy';

                                            final fields = <Widget>[
                                              customTextField(
                                                hint:
                                                    isFlat
                                                        ? 'Sale Price'
                                                        : isHotel
                                                        ? 'Price Per Night'
                                                        : 'Monthly Rent',
                                                controller:
                                                    controller
                                                        .roomPriceController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon:
                                                    Icons.attach_money_rounded,
                                                keyboard: TextInputType.number,
                                              ),
                                              // customTextField(
                                              //   hint:
                                              //       isFlat
                                              //           ? 'Discount Sale Price'
                                              //           : isHotel
                                              //           ? 'Discount Price Per Night'
                                              //           : 'Discount Monthly Rent',
                                              //   controller:
                                              //       controller
                                              //           .discountPriceController,
                                              //   isSuffix: false,
                                              //   isVisible: true,
                                              //   icon: Icons.money_off_rounded,
                                              //   keyboard: TextInputType.number,
                                              // ),
                                              // if (isHotel) ...[
                                              //   customTextField(
                                              //     hint: 'Extra Price Per Adult',
                                              //     controller:
                                              //         controller
                                              //             .extraPriceAdultController,
                                              //     isSuffix: false,
                                              //     isVisible: true,
                                              //     icon:
                                              //         Icons
                                              //             .person_add_alt_1_outlined,
                                              //     keyboard:
                                              //         TextInputType.number,
                                              //   ),
                                              //   customTextField(
                                              //     hint:
                                              //         'Extra Price Per Child Bed',
                                              //     controller:
                                              //         controller
                                              //             .extraPriceChildController,
                                              //     isSuffix: false,
                                              //     isVisible: true,
                                              //     icon:
                                              //         Icons.child_care_rounded,
                                              //     keyboard:
                                              //         TextInputType.number,
                                              //   ),
                                              //   customTextField(
                                              //     hint:
                                              //         'Extra Mattress Price Per Night',
                                              //     controller:
                                              //         controller
                                              //             .extraMattressPriceController,
                                              //     isSuffix: false,
                                              //     isVisible: true,
                                              //     icon: Icons.bed_rounded,
                                              //     keyboard:
                                              //         TextInputType.number,
                                              //   ),
                                              // ],
                                              // customTextField(
                                              //   hint: 'VAT %',
                                              //   controller: controller.vatPercentageController,
                                              //   isSuffix: false,
                                              //   isVisible: true,
                                              //   icon: Icons.percent_rounded,
                                              //   keyboard: TextInputType.number,
                                              // ),
                                              customTextField(
                                                hint: 'Service Charge',
                                                controller:
                                                    controller
                                                        .serviceChargeController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon:
                                                    Icons.room_service_outlined,
                                                keyboard: TextInputType.number,
                                              ),
                                            ];

                                            return Column(
                                              children: [
                                                for (
                                                  int i = 0;
                                                  i < fields.length;
                                                  i += 2
                                                )
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          i + 2 < fields.length
                                                              ? 14
                                                              : 0,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: fields[i],
                                                        ),
                                                        16.horizontalSpace,
                                                        Expanded(
                                                          child:
                                                              i + 1 <
                                                                      fields
                                                                          .length
                                                                  ? fields[i +
                                                                      1]
                                                                  : const SizedBox.shrink(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),

                                    16.verticalSpace,

                                    // CAPACITY & DIMENSIONS
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: cardDecoration,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: iconBoxDecoration,
                                                child: Icon(
                                                  Icons.straighten_rounded,
                                                  color: mainColor,
                                                  size: 20,
                                                ),
                                              ),
                                              12.horizontalSpace,
                                              Expanded(
                                                child: Text(
                                                  'Capacity & Dimensions',
                                                  style: titleStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          20.verticalSpace,
                                          Obx(() {
                                            final category =
                                                controller
                                                    .selectedProperty
                                                    .value
                                                    ?.propertyCategory
                                                    ?.name
                                                    ?.trim() ??
                                                'Hotel';
                                            final isFlat =
                                                category == 'Flat Sale/Buy';
                                            final isHome =
                                                category == 'Family Home';
                                            final isRider = category == 'Rider';
                                            final isBachelor =
                                                category == 'Bachelor';
                                            final showAdults = !isRider;
                                            final showChildren =
                                                !isBachelor &&
                                                !isRider &&
                                                !isFlat;

                                            final fields = <Widget>[
                                              if (showAdults)
                                                customTextField(
                                                  hint: 'Adults Limit',
                                                  controller:
                                                      controller
                                                          .capacityAdultsController,
                                                  isSuffix: false,
                                                  isVisible: true,
                                                  icon:
                                                      Icons.people_alt_outlined,
                                                  keyboard:
                                                      TextInputType.number,
                                                ),
                                              if (showChildren)
                                                customTextField(
                                                  hint: 'Children Limit',
                                                  controller:
                                                      controller
                                                          .capacityChildrenController,
                                                  isSuffix: false,
                                                  isVisible: true,
                                                  icon:
                                                      Icons
                                                          .child_friendly_outlined,
                                                  keyboard:
                                                      TextInputType.number,
                                                ),
                                              customTextField(
                                                hint:
                                                    isFlat
                                                        ? 'Flat Size'
                                                        : isHome
                                                        ? 'Home Size'
                                                        : 'Room Size (sq ft)',
                                                controller:
                                                    controller
                                                        .roomSizeController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon:
                                                    Icons
                                                        .photo_size_select_small_rounded,
                                              ),
                                              customTextField(
                                                hint:
                                                    isFlat
                                                        ? 'Total Flats'
                                                        : isHome
                                                        ? 'Total Homes'
                                                        : 'Total Rooms',
                                                controller:
                                                    controller
                                                        .numberOfRoomController,
                                                isSuffix: false,
                                                isVisible: true,
                                                icon: Icons.layers_outlined,
                                                keyboard: TextInputType.number,
                                              ),
                                            ];

                                            return Column(
                                              children: [
                                                for (
                                                  int i = 0;
                                                  i < fields.length;
                                                  i += 2
                                                )
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          i + 2 < fields.length
                                                              ? 14
                                                              : 0,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: fields[i],
                                                        ),
                                                        16.horizontalSpace,
                                                        Expanded(
                                                          child:
                                                              i + 1 <
                                                                      fields
                                                                          .length
                                                                  ? fields[i +
                                                                      1]
                                                                  : const SizedBox.shrink(),
                                                        ),
                                                      ],
                                                    ),
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
                                    // DESCRIPTION
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      final descTitle =
                                          category == 'Flat Sale/Buy'
                                              ? 'Flat Description'
                                              : category == 'Family Home'
                                              ? 'Home Description'
                                              : category == 'Rider'
                                              ? 'Rider Description'
                                              : 'Description';

                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: cardDecoration,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: iconBoxDecoration,
                                                  child: Icon(
                                                    Icons.description_outlined,
                                                    color: mainColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                12.horizontalSpace,
                                                Expanded(
                                                  child: Text(
                                                    descTitle,
                                                    style: titleStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            20.verticalSpace,
                                            customTextField(
                                              hint: descTitle,
                                              controller:
                                                  controller
                                                      .roomDescriptionController,
                                              isSuffix: false,
                                              isVisible: true,
                                              maxline: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    16.verticalSpace,

                                    // FACILITIES (HOTEL ONLY)
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      if (category != 'Hotel') {
                                        return const SizedBox.shrink();
                                      }

                                      return Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(20),
                                            decoration: cardDecoration,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration:
                                                          iconBoxDecoration,
                                                      child: Icon(
                                                        Icons
                                                            .all_inclusive_rounded,
                                                        color: mainColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    12.horizontalSpace,
                                                    Expanded(
                                                      child: Text(
                                                        'Facilities Available',
                                                        style: titleStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                20.verticalSpace,
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 10,
                                                  children:
                                                      controller.facilities.map((
                                                        facility,
                                                      ) {
                                                        final bool
                                                        isSelected = controller
                                                            .selectedFacilityIds
                                                            .contains(
                                                              facility.id,
                                                            );

                                                        return MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Material(
                                                            color:
                                                                isSelected
                                                                    ? mainColor
                                                                    : Colors
                                                                        .white,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    30,
                                                                  ),
                                                              side: BorderSide(
                                                                color:
                                                                    isSelected
                                                                        ? mainColor
                                                                        : const Color(
                                                                          0xFFE5E7EB,
                                                                        ),
                                                                width:
                                                                    isSelected
                                                                        ? 1.5
                                                                        : 1,
                                                              ),
                                                            ),
                                                            child: InkWell(
                                                              onTap:
                                                                  () => controller
                                                                      .toggleFacility(
                                                                        facility.id ??
                                                                            0,
                                                                      ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          9,
                                                                    ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      isSelected
                                                                          ? Icons
                                                                              .check_circle_rounded
                                                                          : Icons
                                                                              .add_circle_outline_rounded,
                                                                      size: 18,
                                                                      color:
                                                                          isSelected
                                                                              ? Colors.black87
                                                                              : Colors.grey.shade600,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                      facility.name ??
                                                                          '',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            13.5,
                                                                        fontWeight:
                                                                            isSelected
                                                                                ? FontWeight.w700
                                                                                : FontWeight.w500,
                                                                        color:
                                                                            Colors.black87,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          16.verticalSpace,
                                        ],
                                      );
                                    }),

                                    // MEDIA
                                    Obx(() {
                                      final category =
                                          controller
                                              .selectedProperty
                                              .value
                                              ?.propertyCategory
                                              ?.name
                                              ?.trim() ??
                                          'Hotel';
                                      final mediaTitle =
                                          category == 'Flat Sale/Buy'
                                              ? 'Flat Media Attachments'
                                              : category == 'Family Home'
                                              ? 'Home Media Attachments'
                                              : category == 'Rider'
                                              ? 'Rider Media Attachments'
                                              : 'Media Attachments';

                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: cardDecoration,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: iconBoxDecoration,
                                                  child: Icon(
                                                    Icons.perm_media_outlined,
                                                    color: mainColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                12.horizontalSpace,
                                                Expanded(
                                                  child: Text(
                                                    mediaTitle,
                                                    style: titleStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            20.verticalSpace,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MouseRegion(
                                                    cursor:
                                                        SystemMouseCursors
                                                            .click,
                                                    child: Material(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.06,
                                                          ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        side: BorderSide(
                                                          color: mainColor
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                          width: 1.4,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: onPickImages,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .image_outlined,
                                                                size: 28,
                                                                color:
                                                                    mainColor,
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              const Text(
                                                                'Pick Images',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xFF111827,
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
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: MouseRegion(
                                                    cursor:
                                                        SystemMouseCursors
                                                            .click,
                                                    child: Material(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.06,
                                                          ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        side: BorderSide(
                                                          color: mainColor
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                          width: 1.4,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: onPickVideo,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 18,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .video_library_outlined,
                                                                size: 28,
                                                                color:
                                                                    mainColor,
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              const Text(
                                                                'Pick Video',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xFF111827,
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
                                              ],
                                            ),

                                            // Existing Images
                                            Obx(() {
                                              final images =
                                                  controller.existingImages;
                                              if (images.isEmpty) {
                                                return const SizedBox.shrink();
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'Existing Images',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xFF374151,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${images.length} image${images.length > 1 ? 's' : ''}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF6B7280,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  GridView(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                                          maxCrossAxisExtent:
                                                              100,
                                                          crossAxisSpacing: 8,
                                                          mainAxisSpacing: 8,
                                                        ),
                                                    children: List.generate(images.length, (
                                                      index,
                                                    ) {
                                                      final img = images[index];
                                                      return Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            child: WebSafeNetworkImage(
                                                              imageUrl:
                                                                  img.photoName,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 4,
                                                            right: 4,
                                                            child: MouseRegion(
                                                              cursor:
                                                                  SystemMouseCursors
                                                                      .click,
                                                              child: GestureDetector(
                                                                onTap:
                                                                    () => controller
                                                                        .removeExistingImage(
                                                                          index,
                                                                        ),
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withValues(
                                                                          alpha:
                                                                              0.65,
                                                                        ),
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons
                                                                        .close_rounded,
                                                                    size: 14,
                                                                    color:
                                                                        Colors
                                                                            .white,
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
                                              );
                                            }),

                                            // Video (new or existing)
                                            Obx(() {
                                              final selectedVideo =
                                                  controller
                                                      .selectedVideo
                                                      .value;
                                              final existingVideo =
                                                  controller
                                                      .existingVideo
                                                      .value;

                                              if (selectedVideo == null &&
                                                  existingVideo == null) {
                                                return const SizedBox.shrink();
                                              }

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 16,
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selectedVideo != null
                                                            ? const Color(
                                                              0xFFECFDF5,
                                                            )
                                                            : const Color(
                                                              0xFFF3F4F6,
                                                            ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          selectedVideo != null
                                                              ? const Color(
                                                                0xFFA7F3D0,
                                                              )
                                                              : const Color(
                                                                0xFFE5E7EB,
                                                              ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        selectedVideo != null
                                                            ? Icons
                                                                .check_circle_rounded
                                                            : Icons
                                                                .videocam_rounded,
                                                        color:
                                                            selectedVideo !=
                                                                    null
                                                                ? const Color(
                                                                  0xFF059669,
                                                                )
                                                                : mainColor,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              selectedVideo !=
                                                                      null
                                                                  ? (existingVideo !=
                                                                          null
                                                                      ? 'New Video Selected (Replaces existing)'
                                                                      : 'New Video Selected')
                                                                  : 'Existing Video',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              selectedVideo !=
                                                                      null
                                                                  ? selectedVideo
                                                                      .path
                                                                      .split(
                                                                        '/',
                                                                      )
                                                                      .last
                                                                  : existingVideo!
                                                                      .split(
                                                                        '/',
                                                                      )
                                                                      .last,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        13.5,
                                                                    color: Color(
                                                                      0xFF374151,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      MouseRegion(
                                                        cursor:
                                                            SystemMouseCursors
                                                                .click,
                                                        child: GestureDetector(
                                                          onTap:
                                                              () =>
                                                                  selectedVideo !=
                                                                          null
                                                                      ? controller
                                                                          .removeSelectedVideo()
                                                                      : controller
                                                                          .removeExistingVideo(),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              size: 16,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),

                                            // New Images
                                            Obx(() {
                                              final images =
                                                  controller.selectedImages;
                                              if (images.isEmpty) {
                                                return const SizedBox.shrink();
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'New Images',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xFF374151,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${images.length} new image${images.length > 1 ? 's' : ''}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF059669,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  GridView(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                                          maxCrossAxisExtent:
                                                              100,
                                                          crossAxisSpacing: 8,
                                                          mainAxisSpacing: 8,
                                                        ),
                                                    children: List.generate(images.length, (
                                                      index,
                                                    ) {
                                                      return Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            child:
                                                                kIsWeb
                                                                    ? WebSafeNetworkImage(
                                                                      imageUrl:
                                                                          images[index]
                                                                              .path,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    )
                                                                    : Image.file(
                                                                      images[index],
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                    ),
                                                          ),
                                                          Positioned(
                                                            top: 4,
                                                            right: 4,
                                                            child: MouseRegion(
                                                              cursor:
                                                                  SystemMouseCursors
                                                                      .click,
                                                              child: GestureDetector(
                                                                onTap:
                                                                    () => controller
                                                                        .removeSelectedImage(
                                                                          index,
                                                                        ),
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withValues(
                                                                          alpha:
                                                                              0.65,
                                                                        ),
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons
                                                                        .close_rounded,
                                                                    size: 14,
                                                                    color:
                                                                        Colors
                                                                            .white,
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
                                              );
                                            }),
                                          ],
                                        ),
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

                  // ---------------- FOOTER ----------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: OutlinedButton(
                                    onPressed:
                                        () => controller.clearControllers(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear All',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Obx(() {
                                return customButton2(
                                  title: 'Save Details',
                                  icon: Icons.save_rounded,
                                  height: 52,
                                  isLoading: controller.isUpdating.value,
                                  onTap: () {
                                    if (controller.isUpdating.value) return;
                                    controller.updateRoomDetails(roomId);
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
