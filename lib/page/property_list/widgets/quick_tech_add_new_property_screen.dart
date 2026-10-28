import 'package:renth_manager/consts/consts.dart';
import 'package:renth_manager/controller/quick_tech_property_room_store_controller.dart';

import 'package:renth_manager/widgets/quick_tech_custom_dropdown.dart';
import 'package:renth_manager/widgets/quick_tech_web_safe_image.dart';

class QuickTechAddNewPropertyScreen extends StatefulWidget {
  const QuickTechAddNewPropertyScreen({super.key});

  @override
  State<QuickTechAddNewPropertyScreen> createState() =>
      _QuickTechAddNewPropertyScreenState();
}

class _QuickTechAddNewPropertyScreenState
    extends State<QuickTechAddNewPropertyScreen> {
  final commonController = locator.get<CommonController>();
  final authController = locator.get<AuthController>();
  final propertyRoomController = locator.get<QuickTechPropertyRoomController>();

  @override
  void initState() {
    super.initState();
    commonController.selectedCountry.value = null;
    commonController.selectedDistrict.value = null;
    authController.selectedCategory.value = null;
    propertyRoomController.clearPropertyForm();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      commonController.fetchPropertyCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        if (width < 768) {
          return AddPropertyMobileView(
            commonController: commonController,
            authController: authController,
            propertyRoomController: propertyRoomController,
          );
        } else if (width < 1100) {
          return AddPropertyTabletView(
            commonController: commonController,
            authController: authController,
            propertyRoomController: propertyRoomController,
          );
        } else {
          return AddPropertyDesktopView(
            commonController: commonController,
            authController: authController,
            propertyRoomController: propertyRoomController,
          );
        }
      },
    );
  }
}

// =============================================================================
// MOBILE VIEW
// =============================================================================

class AddPropertyMobileView extends StatelessWidget {
  final CommonController commonController;
  final AuthController authController;
  final QuickTechPropertyRoomController propertyRoomController;

  const AddPropertyMobileView({
    super.key,
    required this.commonController,
    required this.authController,
    required this.propertyRoomController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55.h,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            margin: EdgeInsets.only(left: 12.w),
            height: 38.h,
            width: 38.h,
            decoration: BoxDecoration(shape: BoxShape.circle, color: mainColor),
            child: Icon(Icons.arrow_back_sharp, size: 30.h),
          ),
        ),
        title: Text(
          'Basic Property Information',
          style: QuickTechAppTextStyle.appBarTitle(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
        child: Column(
          children: [
            // ---------------- BASIC INFORMATION CARD ----------------

            customTextField(
              hint: 'Property Name',
              isSuffix: false,
              isVisible: true,
              controller: propertyRoomController.titleController,
            ),
            14.verticalSpace,
            customTextField(
              hint: 'Full Address',
              isSuffix: false,
              isVisible: true,
              controller: propertyRoomController.addressController,
            ),
            20.verticalSpace,
            Obx(() {
              final countries = commonController.countries;
              return customDropdownField<Countries>(
                hint: 'Country / Region',
                items:
                    countries.map((country) {
                      return DropdownMenuItem<Countries>(
                        value: country,
                        child: Text(country.name ?? 'Unknown'),
                      );
                    }).toList(),
                value: countries.firstWhereOrNull(
                  (e) => e.id == commonController.selectedCountry.value?.id,
                ),
                onChanged: (value) {
                  commonController.selectedCountry.value = value;

                  if (value != null) {
                    commonController.selectedDistrict.value = null;
                    commonController.fetchDistrictsByCountry(value.id ?? 0);
                    propertyRoomController.setCountry(value.id ?? 0);
                  }
                },
                prefixIcon: const Icon(Icons.public, color: Colors.grey),
              );
            }),
            14.verticalSpace,
            Obx(() {
              final districts = commonController.districtsOfCountry;
              return customDropdownField<District>(
                hint: 'City / District',
                items:
                    districts.map((district) {
                      return DropdownMenuItem<District>(
                        value: district,
                        child: Text(district.name ?? 'Unknown'),
                      );
                    }).toList(),
                value: districts.firstWhereOrNull(
                  (e) => e.id == commonController.selectedDistrict.value?.id,
                ),
                onChanged: (value) {
                  commonController.selectedDistrict.value = value;
                  propertyRoomController.setDistrict(value?.id ?? 0);
                },
                prefixIcon: const Icon(Icons.location_city, color: Colors.grey),
              );
            }),

            14.verticalSpace,
            Obx(() {
              final categories = commonController.propertyCategories;
              if (categories.isEmpty) {
                return SizedBox(
                  height: 52,
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: mainColor,
                      ),
                    ),
                  ),
                );
              }

              return customDropdownField<PropertyCategories>(
                hint: 'Property Category',
                items:
                    categories.map((category) {
                      return DropdownMenuItem<PropertyCategories>(
                        value: category,
                        child: Text(category.name ?? 'Unknown'),
                      );
                    }).toList(),
                value: categories.firstWhereOrNull(
                  (e) => e.id == authController.selectedCategory.value?.id,
                ),
                onChanged: (value) {
                  authController.selectedCategory.value = value;
                  propertyRoomController.setCategory(value?.id ?? 0);
                },
                prefixIcon: const Icon(Icons.category, color: Colors.grey),
              );
            }),

            14.verticalSpace,
            customTextField(
              hint: 'Starting Price',
              isSuffix: true,
              isVisible: true,
              keyboard: TextInputType.number,
              controller: propertyRoomController.priceController,
              supColor: Colors.black,
            ),

            20.verticalSpace,

            customTextField(
              hint: 'Overview',
              isSuffix: false,
              isVisible: true,
              controller: propertyRoomController.overviewController,
            ),
            14.verticalSpace,
            customTextField(
              hint: 'Near By',
              isSuffix: false,
              isVisible: true,
              controller: propertyRoomController.nearbyController,
            ),
            14.verticalSpace,
            customTextField(
              hint: 'Additional Details',
              isSuffix: false,
              isVisible: true,
              maxline: 6,
              controller: propertyRoomController.additionalDetailsController,
            ),

            20.verticalSpace,
            TextField(
              readOnly: true,
              onTap: () => propertyRoomController.pickImages(),
              decoration: InputDecoration(
                hintText: 'Choose Images',
                prefixIcon: Container(
                  height: 40.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: mainColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.cloud_upload, size: 28.w, color: Colors.black),
                      Text(
                        'Upload Images',
                        style: QuickTechAppTextStyle.bodyText4().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: mainColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            Obx(() {
              final images = propertyRoomController.images;
              if (images.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      images.map((path) {
                        return Stack(
                          children: [
                            QuickTechWebSafeImage(
                              fileOrPath: path,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap:
                                      () => propertyRoomController.images
                                          .remove(path),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              );
            }),

            24.verticalSpace,

            // ---------------- SAVE BUTTON ----------------
            Obx(() {
              return customButton2(
                height: 50.h,
                title: 'Save & Continue',
                icon: Icons.save,
                iconSize: 25.h,
                iconColor: mainColor,
                iconBackground: black,
                isLoading: propertyRoomController.isLoading.value,
                onTap: () async {
                  if (propertyRoomController.isLoading.value) return;

                  final success = await propertyRoomController.submitProperty();
                  if (success && context.mounted) {
                    Get.back();
                  }
                },
              );
            }),

            30.verticalSpace,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TABLET VIEW
// =============================================================================

class AddPropertyTabletView extends StatelessWidget {
  final CommonController commonController;
  final AuthController authController;
  final QuickTechPropertyRoomController propertyRoomController;

  const AddPropertyTabletView({
    super.key,
    required this.commonController,
    required this.authController,
    required this.propertyRoomController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          const CustomDrawer(isPermanentSidebar: true),
          Expanded(
            child: Column(
              children: [
                customAppbar(context),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF7F8FA),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------------- HEADING ----------------
                              Row(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Property',
                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        2.verticalSpace,
                                        Text(
                                          'Fill in the basic information to list a new property',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              24.verticalSpace,

                              // ---------------- BASIC INFORMATION CARD ----------------
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Property Name',
                                            isSuffix: false,
                                            isVisible: true,
                                            controller:
                                                propertyRoomController
                                                    .titleController,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: Obx(() {
                                            final categories =
                                                commonController
                                                    .propertyCategories;
                                            if (categories.isEmpty) {
                                              return SizedBox(
                                                height: 52,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 26,
                                                    height: 26,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 3,
                                                          color: mainColor,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }

                                            return customDropdownField<
                                              PropertyCategories
                                            >(
                                              hint: 'Property Category',
                                              items:
                                                  categories.map((category) {
                                                    return DropdownMenuItem<
                                                      PropertyCategories
                                                    >(
                                                      value: category,
                                                      child: Text(
                                                        category.name ??
                                                            'Unknown',
                                                      ),
                                                    );
                                                  }).toList(),
                                              value: categories
                                                  .firstWhereOrNull(
                                                    (e) =>
                                                        e.id ==
                                                        authController
                                                            .selectedCategory
                                                            .value
                                                            ?.id,
                                                  ),
                                              onChanged: (value) {
                                                authController
                                                    .selectedCategory
                                                    .value = value;
                                                propertyRoomController
                                                    .setCategory(
                                                      value?.id ?? 0,
                                                    );
                                              },
                                              prefixIcon: const Icon(
                                                Icons.category,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    14.verticalSpace,
                                    customTextField(
                                      hint: 'Full Address',
                                      isSuffix: false,
                                      isVisible: true,
                                      controller:
                                          propertyRoomController
                                              .addressController,
                                    ),
                                    14.verticalSpace,
                                    customTextField(
                                      hint: 'Starting Price',
                                      isSuffix: true,
                                      isVisible: true,
                                      keyboard: TextInputType.number,
                                      controller:
                                          propertyRoomController
                                              .priceController,
                                      supColor: Colors.black,
                                    ),
                                  ],
                                ),
                              ),

                              16.verticalSpace,

                              // ---------------- LOCATION CARD ----------------
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
                                            Icons.location_on_outlined,
                                            color: mainColor,
                                            size: 20,
                                          ),
                                        ),
                                        12.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            'Location',
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Obx(() {
                                            final countries =
                                                commonController.countries;
                                            return customDropdownField<
                                              Countries
                                            >(
                                              hint: 'Country / Region',
                                              items:
                                                  countries.map((country) {
                                                    return DropdownMenuItem<
                                                      Countries
                                                    >(
                                                      value: country,
                                                      child: Text(
                                                        country.name ??
                                                            'Unknown',
                                                      ),
                                                    );
                                                  }).toList(),
                                              value: countries.firstWhereOrNull(
                                                (e) =>
                                                    e.id ==
                                                    commonController
                                                        .selectedCountry
                                                        .value
                                                        ?.id,
                                              ),
                                              onChanged: (value) {
                                                commonController
                                                    .selectedCountry
                                                    .value = value;

                                                if (value != null) {
                                                  commonController
                                                      .selectedDistrict
                                                      .value = null;
                                                  commonController
                                                      .fetchDistrictsByCountry(
                                                        value.id ?? 0,
                                                      );
                                                  propertyRoomController
                                                      .setCountry(
                                                        value.id ?? 0,
                                                      );
                                                }
                                              },
                                              prefixIcon: const Icon(
                                                Icons.public,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: Obx(() {
                                            final districts =
                                                commonController
                                                    .districtsOfCountry;
                                            return customDropdownField<
                                              District
                                            >(
                                              hint: 'City / District',
                                              items:
                                                  districts.map((district) {
                                                    return DropdownMenuItem<
                                                      District
                                                    >(
                                                      value: district,
                                                      child: Text(
                                                        district.name ??
                                                            'Unknown',
                                                      ),
                                                    );
                                                  }).toList(),
                                              value: districts.firstWhereOrNull(
                                                (e) =>
                                                    e.id ==
                                                    commonController
                                                        .selectedDistrict
                                                        .value
                                                        ?.id,
                                              ),
                                              onChanged: (value) {
                                                commonController
                                                    .selectedDistrict
                                                    .value = value;
                                                propertyRoomController
                                                    .setDistrict(
                                                      value?.id ?? 0,
                                                    );
                                              },
                                              prefixIcon: const Icon(
                                                Icons.location_city,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              16.verticalSpace,

                              // ---------------- PROPERTY DETAILS CARD ----------------
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
                                            'Property Details',
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Overview',
                                            isSuffix: false,
                                            isVisible: true,
                                            controller:
                                                propertyRoomController
                                                    .overviewController,
                                          ),
                                        ),
                                        16.horizontalSpace,
                                        Expanded(
                                          child: customTextField(
                                            hint: 'Near By',
                                            isSuffix: false,
                                            isVisible: true,
                                            controller:
                                                propertyRoomController
                                                    .nearbyController,
                                          ),
                                        ),
                                      ],
                                    ),
                                    14.verticalSpace,
                                    customTextField(
                                      hint: 'Additional Details',
                                      isSuffix: false,
                                      isVisible: true,
                                      maxline: 6,
                                      controller:
                                          propertyRoomController
                                              .additionalDetailsController,
                                    ),
                                  ],
                                ),
                              ),

                              16.verticalSpace,

                              // ---------------- PROPERTY IMAGES CARD ----------------
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
                                            'Property Images',
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
                                                  propertyRoomController
                                                      .pickImages(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 24,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    size: 32,
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
                                    Obx(() {
                                      final images =
                                          propertyRoomController.images;
                                      if (images.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children:
                                              images.map((path) {
                                                return Stack(
                                                  children: [
                                                    QuickTechWebSafeImage(
                                                      fileOrPath: path,
                                                      width: 88,
                                                      height: 88,
                                                      fit: BoxFit.cover,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
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
                                                              () =>
                                                                  propertyRoomController
                                                                      .images
                                                                      .remove(
                                                                        path,
                                                                      ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .black54,
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
                                              }).toList(),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              24.verticalSpace,

                              // ---------------- SAVE BUTTON ----------------
                              Obx(() {
                                return customButton2(
                                  title: 'Save & Continue',
                                  icon: Icons.save_rounded,
                                  iconColor: textColor,
                                  isLoading:
                                      propertyRoomController.isLoading.value,
                                  onTap: () async {
                                    if (propertyRoomController
                                        .isLoading
                                        .value) {
                                      return;
                                    }

                                    final success =
                                        await propertyRoomController
                                            .submitProperty();
                                    if (success && context.mounted) {
                                      Get.back();
                                    }
                                  },
                                );
                              }),

                              30.verticalSpace,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

class AddPropertyDesktopView extends StatelessWidget {
  final CommonController commonController;
  final AuthController authController;
  final QuickTechPropertyRoomController propertyRoomController;

  const AddPropertyDesktopView({
    super.key,
    required this.commonController,
    required this.authController,
    required this.propertyRoomController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          const CustomDrawer(isPermanentSidebar: true),
          Expanded(
            child: Column(
              children: [
                customAppbar(context),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF7F8FA),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 28.h,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---------------- HEADING ----------------
                              Row(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Property',
                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        2.verticalSpace,
                                        Text(
                                          'Fill in the basic information to list a new property',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              28.verticalSpace,

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ---------------- LEFT COLUMN ----------------
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      children: [
                                        // BASIC INFORMATION CARD
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF111827,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              20.verticalSpace,
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: customTextField(
                                                      hint: 'Property Name',
                                                      isSuffix: false,
                                                      isVisible: true,
                                                      controller:
                                                          propertyRoomController
                                                              .titleController,
                                                    ),
                                                  ),
                                                  16.horizontalSpace,
                                                  Expanded(
                                                    child: Obx(() {
                                                      final categories =
                                                          commonController
                                                              .propertyCategories;
                                                      if (categories.isEmpty) {
                                                        return SizedBox(
                                                          height: 52,
                                                          child: Center(
                                                            child: SizedBox(
                                                              width: 26,
                                                              height: 26,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        3,
                                                                    color:
                                                                        mainColor,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      return customDropdownField<
                                                        PropertyCategories
                                                      >(
                                                        hint:
                                                            'Property Category',
                                                        items:
                                                            categories.map((
                                                              category,
                                                            ) {
                                                              return DropdownMenuItem<
                                                                PropertyCategories
                                                              >(
                                                                value: category,
                                                                child: Text(
                                                                  category.name ??
                                                                      'Unknown',
                                                                ),
                                                              );
                                                            }).toList(),
                                                        value: categories
                                                            .firstWhereOrNull(
                                                              (e) =>
                                                                  e.id ==
                                                                  authController
                                                                      .selectedCategory
                                                                      .value
                                                                      ?.id,
                                                            ),
                                                        onChanged: (value) {
                                                          authController
                                                              .selectedCategory
                                                              .value = value;
                                                          propertyRoomController
                                                              .setCategory(
                                                                value?.id ?? 0,
                                                              );
                                                        },
                                                        prefixIcon: const Icon(
                                                          Icons.category,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                              14.verticalSpace,
                                              customTextField(
                                                hint: 'Full Address',
                                                isSuffix: false,
                                                isVisible: true,
                                                controller:
                                                    propertyRoomController
                                                        .addressController,
                                              ),
                                              14.verticalSpace,
                                              customTextField(
                                                hint: 'Starting Price',
                                                isSuffix: true,
                                                isVisible: true,
                                                keyboard: TextInputType.number,
                                                controller:
                                                    propertyRoomController
                                                        .priceController,
                                                supColor: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),

                                        16.verticalSpace,

                                        // LOCATION CARD
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: mainColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  12.horizontalSpace,
                                                  Expanded(
                                                    child: Text(
                                                      'Location',
                                                      style: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF111827,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              20.verticalSpace,
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Obx(() {
                                                      final countries =
                                                          commonController
                                                              .countries;
                                                      return customDropdownField<
                                                        Countries
                                                      >(
                                                        hint:
                                                            'Country / Region',
                                                        items:
                                                            countries.map((
                                                              country,
                                                            ) {
                                                              return DropdownMenuItem<
                                                                Countries
                                                              >(
                                                                value: country,
                                                                child: Text(
                                                                  country.name ??
                                                                      'Unknown',
                                                                ),
                                                              );
                                                            }).toList(),
                                                        value: countries
                                                            .firstWhereOrNull(
                                                              (e) =>
                                                                  e.id ==
                                                                  commonController
                                                                      .selectedCountry
                                                                      .value
                                                                      ?.id,
                                                            ),
                                                        onChanged: (value) {
                                                          commonController
                                                              .selectedCountry
                                                              .value = value;

                                                          if (value != null) {
                                                            commonController
                                                                .selectedDistrict
                                                                .value = null;
                                                            commonController
                                                                .fetchDistrictsByCountry(
                                                                  value.id ?? 0,
                                                                );
                                                            propertyRoomController
                                                                .setCountry(
                                                                  value.id ?? 0,
                                                                );
                                                          }
                                                        },
                                                        prefixIcon: const Icon(
                                                          Icons.public,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  16.horizontalSpace,
                                                  Expanded(
                                                    child: Obx(() {
                                                      final districts =
                                                          commonController
                                                              .districtsOfCountry;
                                                      return customDropdownField<
                                                        District
                                                      >(
                                                        hint: 'City / District',
                                                        items:
                                                            districts.map((
                                                              district,
                                                            ) {
                                                              return DropdownMenuItem<
                                                                District
                                                              >(
                                                                value: district,
                                                                child: Text(
                                                                  district.name ??
                                                                      'Unknown',
                                                                ),
                                                              );
                                                            }).toList(),
                                                        value: districts
                                                            .firstWhereOrNull(
                                                              (e) =>
                                                                  e.id ==
                                                                  commonController
                                                                      .selectedDistrict
                                                                      .value
                                                                      ?.id,
                                                            ),
                                                        onChanged: (value) {
                                                          commonController
                                                              .selectedDistrict
                                                              .value = value;
                                                          propertyRoomController
                                                              .setDistrict(
                                                                value?.id ?? 0,
                                                              );
                                                        },
                                                        prefixIcon: const Icon(
                                                          Icons.location_city,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        16.verticalSpace,

                                        // PROPERTY DETAILS CARD
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                      'Property Details',
                                                      style: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF111827,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              20.verticalSpace,
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: customTextField(
                                                      hint: 'Overview',
                                                      isSuffix: false,
                                                      isVisible: true,
                                                      controller:
                                                          propertyRoomController
                                                              .overviewController,
                                                    ),
                                                  ),
                                                  16.horizontalSpace,
                                                  Expanded(
                                                    child: customTextField(
                                                      hint: 'Near By',
                                                      isSuffix: false,
                                                      isVisible: true,
                                                      controller:
                                                          propertyRoomController
                                                              .nearbyController,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              14.verticalSpace,
                                              customTextField(
                                                hint: 'Additional Details',
                                                isSuffix: false,
                                                isVisible: true,
                                                maxline: 6,
                                                controller:
                                                    propertyRoomController
                                                        .additionalDetailsController,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  24.horizontalSpace,

                                  // ---------------- RIGHT COLUMN ----------------
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        // PROPERTY IMAGES CARD
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: mainColor
                                                          .withValues(
                                                            alpha: 0.14,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .photo_library_outlined,
                                                      color: mainColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  12.horizontalSpace,
                                                  Expanded(
                                                    child: Text(
                                                      'Property Images',
                                                      style: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF111827,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              20.verticalSpace,
                                              MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Material(
                                                  color: mainColor.withValues(
                                                    alpha: 0.06,
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
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
                                                    onTap:
                                                        () =>
                                                            propertyRoomController
                                                                .pickImages(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 24,
                                                          ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .cloud_upload_outlined,
                                                              size: 32,
                                                              color: mainColor,
                                                            ),
                                                            8.verticalSpace,
                                                            Text(
                                                              'Choose Images',
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    const Color(
                                                                      0xFF111827,
                                                                    ),
                                                              ),
                                                            ),
                                                            2.verticalSpace,
                                                            Text(
                                                              'Tap to browse',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    const Color(
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
                                              Obx(() {
                                                final images =
                                                    propertyRoomController
                                                        .images;
                                                if (images.isEmpty) {
                                                  return const SizedBox.shrink();
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 16,
                                                      ),
                                                  child: Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children:
                                                        images.map((path) {
                                                          return Stack(
                                                            children: [
                                                              QuickTechWebSafeImage(
                                                                fileOrPath:
                                                                    path,
                                                                width: 88,
                                                                height: 88,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
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
                                                                        () => propertyRoomController
                                                                            .images
                                                                            .remove(
                                                                              path,
                                                                            ),
                                                                    child: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            4,
                                                                          ),
                                                                      decoration: const BoxDecoration(
                                                                        color:
                                                                            Colors.black54,
                                                                        shape:
                                                                            BoxShape.circle,
                                                                      ),
                                                                      child: const Icon(
                                                                        Icons
                                                                            .close_rounded,
                                                                        size:
                                                                            14,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),

                                        24.verticalSpace,

                                        // SAVE BUTTON
                                        Obx(() {
                                          return customButton2(
                                            title: 'Save & Continue',
                                            icon: Icons.save_rounded,
                                            iconColor: textColor,
                                            isLoading:
                                                propertyRoomController
                                                    .isLoading
                                                    .value,
                                            onTap: () async {
                                              if (propertyRoomController
                                                  .isLoading
                                                  .value) {
                                                return;
                                              }

                                              final success =
                                                  await propertyRoomController
                                                      .submitProperty();
                                              if (success && context.mounted) {
                                                Get.back();
                                              }
                                            },
                                          );
                                        }),

                                        30.verticalSpace,
                                      ],
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
