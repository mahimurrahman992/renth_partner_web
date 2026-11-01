import 'package:renth_manager/consts/consts.dart';
import 'package:renth_manager/controller/quick_tech_property_details_controller.dart';

// =============================================================================
// PAGE (init + responsive switch)
// =============================================================================

class QuickTechEditPropertyPage extends StatefulWidget {
  final int? propertyId;

  const QuickTechEditPropertyPage({super.key, this.propertyId});

  @override
  State<QuickTechEditPropertyPage> createState() =>
      _QuickTechEditPropertyPageState();
}

class _QuickTechEditPropertyPageState extends State<QuickTechEditPropertyPage> {
  late final PropertyDetailsController controller;

  int? get _resolvedId =>
      widget.propertyId ??
      controller.property?.id ??
      int.tryParse(
        (GetStorage().read(StorageKeys.selectedPropertyId) ?? '').toString(),
      );

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PropertyDetailsController>()
        ? Get.find<PropertyDetailsController>()
        : Get.put(PropertyDetailsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _resolvedId;
      if (id != null) controller.initializeEditForm(propertyId: id);
    });
  }

  Future<void> _onSubmit() async {
    final ok = await controller.updateProperty();
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _onCancel() => Get.back();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value || controller.isEditInitializing.value) {
          return const Center(child: CircularProgressIndicator(color: mainColor));
        }

        if (controller.property == null) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 50, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        const Text(
                          'Property data not found',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            final id = _resolvedId;
                            if (id != null) {
                              controller.initializeEditForm(propertyId: id);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1024) {
              return QuickTechEditPropertyDesktopView(
                controller: controller,
                onSubmit: _onSubmit,
                onCancel: _onCancel,
              );
            }
            if (constraints.maxWidth >= 600) {
              return QuickTechEditPropertyTabletView(
                controller: controller,
                onSubmit: _onSubmit,
                onCancel: _onCancel,
              );
            }
            return QuickTechEditPropertyMobileView(
              controller: controller,
              onSubmit: _onSubmit,
              onCancel: _onCancel,
            );
          },
        );
      }),
    );
  }
}

// =============================================================================
// MOBILE VIEW
// =============================================================================

class QuickTechEditPropertyMobileView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const QuickTechEditPropertyMobileView({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cardDeco = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    InputDecoration deco(String label, {String? prefix, bool multi = false}) =>
        InputDecoration(
          labelText: label,
          prefixText: prefix,
          alignLabelWithHint: multi,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        );

    Widget sectionTitle(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        );

    final countryField = Obx(
      () => DropdownButtonFormField<Countries>(
        value: controller.selectedCountry.value,
        isExpanded: true,
        decoration: deco('Country *'),
        items: controller.countries
            .map((c) => DropdownMenuItem<Countries>(
                  value: c,
                  child: Text(c.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onCountryChanged,
      ),
    );

    final districtField = Obx(
      () => DropdownButtonFormField<District>(
        value: controller.selectedDistrict.value,
        isExpanded: true,
        decoration: deco('District *').copyWith(
          suffixIcon: controller.isLoadingLocations.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        items: controller.districts
            .map((d) => DropdownMenuItem<District>(
                  value: d,
                  child: Text(d.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onDistrictChanged,
      ),
    );

    final photos = Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (int i = 0; i < controller.newImageBytes.length; i++)
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        controller.newImageBytes[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: InkWell(
                      onTap: () => controller.removeNewImage(i),
                      child: const CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          InkWell(
            onTap: controller.pickImages,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 26, color: Colors.black87),
                  SizedBox(height: 4),
                  Text('Add', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final actions = Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isUpdating.value ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.isUpdating.value ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: controller.isUpdating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Update Property',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          // APP BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                InkWell(
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Edit Property',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 34),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BASIC INFO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: cardDeco,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(Icons.apartment_rounded, 'Basic Information'),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.titleController,
                          decoration: deco('Title *'),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.startingPriceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              deco('Starting Price Per Night *', prefix: '৳ '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // LOCATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: cardDeco,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(Icons.location_on_outlined, 'Location'),
                        const SizedBox(height: 14),
                        countryField,
                        const SizedBox(height: 14),
                        districtField,
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.addressController,
                          decoration: deco('Address *'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // DESCRIPTION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: cardDeco,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(Icons.description_outlined, 'Description'),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.overviewController,
                          maxLines: 4,
                          decoration: deco('Overview *', multi: true),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.nearByController,
                          maxLines: 3,
                          decoration: deco('Near By *', multi: true),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.additionalDetailsController,
                          maxLines: 3,
                          decoration: deco('Additional Details *', multi: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PHOTOS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: cardDeco,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(Icons.photo_library_outlined, 'Photos *'),
                        const SizedBox(height: 6),
                        Text(
                          'Upload new photos. They will replace the current photos.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        photos,
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  actions,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TABLET VIEW
// =============================================================================

class QuickTechEditPropertyTabletView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const QuickTechEditPropertyTabletView({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cardDeco = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    InputDecoration deco(String label, {String? prefix, bool multi = false}) =>
        InputDecoration(
          labelText: label,
          prefixText: prefix,
          alignLabelWithHint: multi,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        );

    Widget sectionTitle(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        );

    final countryField = Obx(
      () => DropdownButtonFormField<Countries>(
        value: controller.selectedCountry.value,
        isExpanded: true,
        decoration: deco('Country *'),
        items: controller.countries
            .map((c) => DropdownMenuItem<Countries>(
                  value: c,
                  child: Text(c.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onCountryChanged,
      ),
    );

    final districtField = Obx(
      () => DropdownButtonFormField<District>(
        value: controller.selectedDistrict.value,
        isExpanded: true,
        decoration: deco('District *').copyWith(
          suffixIcon: controller.isLoadingLocations.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        items: controller.districts
            .map((d) => DropdownMenuItem<District>(
                  value: d,
                  child: Text(d.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onDistrictChanged,
      ),
    );

    final photos = Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (int i = 0; i < controller.newImageBytes.length; i++)
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        controller.newImageBytes[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: InkWell(
                      onTap: () => controller.removeNewImage(i),
                      child: const CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          InkWell(
            onTap: controller.pickImages,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 28, color: Colors.black87),
                  SizedBox(height: 4),
                  Text('Add', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final actions = Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: controller.isUpdating.value ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: controller.isUpdating.value ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: controller.isUpdating.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('Update Property',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                InkWell(
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Edit Property',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BASIC INFO (2 col)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: cardDeco,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(
                                Icons.apartment_rounded, 'Basic Information'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: controller.titleController,
                                    decoration: deco('Title *'),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller:
                                        controller.startingPriceController,
                                    keyboardType: TextInputType.number,
                                    decoration: deco('Starting Price / Night *',
                                        prefix: '৳ '),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // LOCATION
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: cardDeco,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(
                                Icons.location_on_outlined, 'Location'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: countryField),
                                const SizedBox(width: 14),
                                Expanded(child: districtField),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: controller.addressController,
                              decoration: deco('Address *'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // DESCRIPTION
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: cardDeco,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(
                                Icons.description_outlined, 'Description'),
                            const SizedBox(height: 14),
                            TextField(
                              controller: controller.overviewController,
                              maxLines: 4,
                              decoration: deco('Overview *', multi: true),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.nearByController,
                                    maxLines: 4,
                                    decoration: deco('Near By *', multi: true),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller:
                                        controller.additionalDetailsController,
                                    maxLines: 4,
                                    decoration: deco('Additional Details *',
                                        multi: true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // PHOTOS
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: cardDeco,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle(
                                Icons.photo_library_outlined, 'Photos *'),
                            const SizedBox(height: 6),
                            Text(
                              'Upload new photos. They will replace the current photos.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 14),
                            photos,
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      actions,
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

class QuickTechEditPropertyDesktopView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const QuickTechEditPropertyDesktopView({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cardDeco = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    InputDecoration deco(String label, {String? prefix, bool multi = false}) =>
        InputDecoration(
          labelText: label,
          prefixText: prefix,
          alignLabelWithHint: multi,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        );

    Widget sectionTitle(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        );

    final countryField = Obx(
      () => DropdownButtonFormField<Countries>(
        value: controller.selectedCountry.value,
        isExpanded: true,
        decoration: deco('Country *'),
        items: controller.countries
            .map((c) => DropdownMenuItem<Countries>(
                  value: c,
                  child: Text(c.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onCountryChanged,
      ),
    );

    final districtField = Obx(
      () => DropdownButtonFormField<District>(
        value: controller.selectedDistrict.value,
        isExpanded: true,
        decoration: deco('District *').copyWith(
          suffixIcon: controller.isLoadingLocations.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        items: controller.districts
            .map((d) => DropdownMenuItem<District>(
                  value: d,
                  child: Text(d.name ?? ''),
                ))
            .toList(),
        onChanged: controller.onDistrictChanged,
      ),
    );

    final photos = Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (int i = 0; i < controller.newImageBytes.length; i++)
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        controller.newImageBytes[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => controller.removeNewImage(i),
                        child: const CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: controller.pickImages,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 28, color: Colors.black87),
                    SizedBox(height: 4),
                    Text('Add', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final actions = Obx(
      () => Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: controller.isUpdating.value ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isUpdating.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Update Property',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: OutlinedButton(
                onPressed: controller.isUpdating.value ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 14),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Edit Property',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 4, 32, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============ LEFT COLUMN (form) ============
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // BASIC INFO
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: cardDeco,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle(Icons.apartment_rounded,
                                      'Basic Information'),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller:
                                              controller.titleController,
                                          decoration: deco('Title *'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: controller
                                              .startingPriceController,
                                          keyboardType: TextInputType.number,
                                          decoration: deco(
                                              'Starting Price / Night *',
                                              prefix: '৳ '),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // LOCATION
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: cardDeco,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle(
                                      Icons.location_on_outlined, 'Location'),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: countryField),
                                      const SizedBox(width: 16),
                                      Expanded(child: districtField),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: controller.addressController,
                                    decoration: deco('Address *'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // DESCRIPTION
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: cardDeco,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle(Icons.description_outlined,
                                      'Description'),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: controller.overviewController,
                                    maxLines: 5,
                                    decoration: deco('Overview *', multi: true),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.nearByController,
                                          maxLines: 4,
                                          decoration:
                                              deco('Near By *', multi: true),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: controller
                                              .additionalDetailsController,
                                          maxLines: 4,
                                          decoration: deco(
                                              'Additional Details *',
                                              multi: true),
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

                      const SizedBox(width: 24),

                      // ============ RIGHT COLUMN (photos + actions) ============
                      SizedBox(
                        width: 360,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: cardDeco,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionTitle(
                                      Icons.photo_library_outlined, 'Photos *'),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Upload new photos. They will replace the current photos.',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  photos,
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: cardDeco,
                              child: actions,
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
        ],
      ),
    );
  }
}