import 'package:renth_manager/consts/consts.dart';
import 'package:renth_manager/controller/quick_tech_property_details_controller.dart';



class QuickTechPropertyDetails extends StatefulWidget {
  final int? propertyId;

  const QuickTechPropertyDetails({super.key, this.propertyId});

  @override
  State<QuickTechPropertyDetails> createState() =>
      _QuickTechPropertyDetailsState();
}

class _QuickTechPropertyDetailsState extends State<QuickTechPropertyDetails> {
  late final PropertyDetailsController controller;
  int? resolvedId;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PropertyDetailsController());

    resolvedId = widget.propertyId ??
        int.tryParse(
          (GetStorage().read(StorageKeys.selectedPropertyId) ?? '').toString(),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (resolvedId != null) {
        controller.fetchPropertyDetails(resolvedId!);
      } else {
        controller.errorMessage.value = 'No property selected';
      }
    });
  }

  @override
  void dispose() {
    Get.delete<PropertyDetailsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ---------------- REFRESH ----------------
    Future<void> onRefresh() async {
      final id = controller.property?.id ?? resolvedId;
      if (id != null) await controller.fetchPropertyDetails(id, silent: true);
    }

    // ---------------- EDIT (navigate) ----------------
   Future<void> onEdit() async {
      final id = controller.property?.id ?? resolvedId;
      if (id == null) return;

      final updated = await Get.to<bool>(
        () => QuickTechEditPropertyPage(propertyId: id),
      );

      if (updated == true) {
        await controller.fetchPropertyDetails(id, silent: true);
      }
    }

    // ---------------- BODY ----------------
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        // LOADING
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: mainColor));
        }

        // ERROR / EMPTY
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.errorMessage.value.isNotEmpty
                                ? Icons.error_outline_rounded
                                : Icons.domain_disabled_rounded,
                            size: 50,
                            color: controller.errorMessage.value.isNotEmpty
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'No property details found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (resolvedId != null) {
                                controller.fetchPropertyDetails(resolvedId!);
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
                ),
              ],
            ),
          );
        }

        // RESPONSIVE
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1024) {
              return QuickTechPropertyDetailsDesktopView(
                controller: controller,
                onEdit: onEdit,
                onRefresh: onRefresh,
              );
            }
            if (constraints.maxWidth >= 600) {
              return QuickTechPropertyDetailsTabletView(
                controller: controller,
                onEdit: onEdit,
                onRefresh: onRefresh,
              );
            }
            return QuickTechPropertyDetailsMobileView(
              controller: controller,
              onEdit: onEdit,
              onRefresh: onRefresh,
            );
          },
        );
      }),
    );
  }
}

// =============================================================================
// MOBILE VIEW  (app er moto)
// =============================================================================

class QuickTechPropertyDetailsMobileView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  const QuickTechPropertyDetailsMobileView({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final property = controller.property!;
    final images = property.multiImages ?? [];
    final categoryName = property.propertyCategory?.name ?? 'Property';
    final addressText = [
      if (property.address != null && property.address!.trim().isNotEmpty)
        property.address!.trim(),
      if (property.district?.name != null &&
          property.district!.name!.trim().isNotEmpty)
        property.district!.name!.trim(),
      if (property.country?.name != null &&
          property.country!.name!.trim().isNotEmpty)
        property.country!.name!.trim(),
    ].join(', ');
    final startingPrice = property.startingPricePerNight;
    final totalPrice = property.totalPrice?.toString();
    final overviewText = property.overview ??
        property.aboutProperty?.toString() ??
        'No overview details provided for this property.';
    final facilities = property.uniqueFacilities ?? [];
    final rooms = property.propertyRooms ?? [];
    final nearBy = (property.nearBy ?? '').trim();
    final additional = (property.additionalDetails ?? '').trim();
    final manager = property.manager;
    final managerPhoto = controller.mediaUrl(manager?.profilePhoto);

    return SafeArea(
      child: Column(
        children: [
          // APP BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Property Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE CAROUSEL
                    if (images.isEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apartment_rounded,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Photos Available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: controller.pageController,
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  controller.activeImageIndex.value = index;
                                },
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    controller.mediaUrl(images[index].photoName),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: mainColor,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Obx(
                                  () => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.photo_library_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${controller.activeImageIndex.value + 1} / ${images.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // HEADER CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  property.title ?? 'Untitled Property',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: mainColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: mainColor),
                                ),
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  addressText.isNotEmpty
                                      ? addressText
                                      : 'Address not provided',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    size: 16,
                                    color: property.status == 1
                                        ? Colors.green[700]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    property.status == 1
                                        ? 'Active Property'
                                        : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: property.status == 1
                                          ? Colors.green[700]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (property.reviewsCount != null &&
                                  property.reviewsCount! > 0)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${property.reviewsAvgRating ?? '0.0'} (${property.reviewsCount})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PRICE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Starting Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    startingPrice != null &&
                                            startingPrice.isNotEmpty
                                        ? '৳ $startingPrice'
                                        : '৳ 0',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '/ night',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (totalPrice != null &&
                              totalPrice.isNotEmpty &&
                              totalPrice != '0')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳ $totalPrice',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // OVERVIEW CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 20, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            overviewText,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FACILITIES CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.hotel_class_outlined,
                                  size: 20, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Facilities & Amenities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (facilities.isEmpty)
                            Text(
                              'No specific facilities listed.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: facilities.map((facility) {
                                final photoUrl =
                                    controller.mediaUrl(facility.facilityPhoto);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (photoUrl.isNotEmpty)
                                        Image.network(
                                          photoUrl,
                                          width: 16,
                                          height: 16,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        facility.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ROOMS CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.meeting_room_outlined,
                                  size: 20, color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                'Rooms (${rooms.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (rooms.isEmpty)
                            Text(
                              'No rooms currently listed under this property.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rooms.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final room = rooms[index];
                                final photos = room.roomImages ?? [];
                                final firstPhoto = photos.isNotEmpty
                                    ? controller.mediaUrl(photos.first.photoName)
                                    : '';

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: firstPhoto.isNotEmpty
                                            ? Image.network(
                                                firstPhoto,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.bed,
                                                    color: Colors.grey,
                                                    size: 28,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.bed,
                                                  color: Colors.grey,
                                                  size: 28,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room.roomName ??
                                                  'Room ${index + 1}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (room.roomType?.name != null)
                                              Text(
                                                room.roomType!.name!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.person_outline,
                                                      size: 14,
                                                      color: Colors.black54,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${room.capacityOfAdults ?? 0} Adults',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '৳ ${room.roomPricePerNight ?? '0'}/night',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    // NEARBY
                    if (nearBy.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.near_me_outlined,
                                    size: 20, color: Colors.black87),
                                SizedBox(width: 8),
                                Text(
                                  'Nearby Places',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              nearBy,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ADDITIONAL DETAILS
                    if (additional.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 20, color: Colors.black87),
                                SizedBox(width: 8),
                                Text(
                                  'Additional Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              additional,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // MANAGER
                    if (manager != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.person_pin_circle_outlined,
                                    size: 20, color: Colors.black87),
                                SizedBox(width: 8),
                                Text(
                                  'Manager Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      mainColor.withValues(alpha: 0.3),
                                  backgroundImage: managerPhoto.isNotEmpty
                                      ? NetworkImage(managerPhoto)
                                      : null,
                                  child: managerPhoto.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.black87)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        manager.name ?? 'Manager',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        manager.role?.toUpperCase() ??
                                            'MANAGER',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (manager.phone != null &&
                                          manager.phone!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          manager.phone!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
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
// TABLET VIEW
// =============================================================================

class QuickTechPropertyDetailsTabletView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  const QuickTechPropertyDetailsTabletView({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final property = controller.property!;
    final images = property.multiImages ?? [];
    final categoryName = property.propertyCategory?.name ?? 'Property';
    final addressText = [
      if (property.address != null && property.address!.trim().isNotEmpty)
        property.address!.trim(),
      if (property.district?.name != null &&
          property.district!.name!.trim().isNotEmpty)
        property.district!.name!.trim(),
      if (property.country?.name != null &&
          property.country!.name!.trim().isNotEmpty)
        property.country!.name!.trim(),
    ].join(', ');
    final startingPrice = property.startingPricePerNight;
    final totalPrice = property.totalPrice?.toString();
    final overviewText = property.overview ??
        property.aboutProperty?.toString() ??
        'No overview details provided for this property.';
    final facilities = property.uniqueFacilities ?? [];
    final rooms = property.propertyRooms ?? [];
    final nearBy = (property.nearBy ?? '').trim();
    final additional = (property.additionalDetails ?? '').trim();
    final manager = property.manager;
    final managerPhoto = controller.mediaUrl(manager?.profilePhoto);

    return SafeArea(
      child: Column(
        children: [
          // TOP BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Property Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Property',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
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

          Expanded(
            child: RefreshIndicator(
              color: mainColor,
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CAROUSEL
                        if (images.isEmpty)
                          Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apartment_rounded,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('No Photos Available',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        else
                          Container(
                            height: 340,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: controller.pageController,
                                    itemCount: images.length,
                                    onPageChanged: (index) {
                                      controller.activeImageIndex.value = index;
                                    },
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        controller
                                            .mediaUrl(images[index].photoName),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: Colors.grey[100],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: mainColor,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, e, s) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.broken_image_rounded,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  Positioned(
                                    left: 10,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Colors.black.withValues(alpha: 0.45),
                                        child: IconButton(
                                          onPressed: () {
                                            controller.pageController
                                                .previousPage(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.chevron_left_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Colors.black.withValues(alpha: 0.45),
                                        child: IconButton(
                                          onPressed: () {
                                            controller.pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Obx(
                                      () => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.65),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${controller.activeImageIndex.value + 1} / ${images.length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // HEADER + PRICE ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            property.title ??
                                                'Untitled Property',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: mainColor
                                                .withValues(alpha: 0.25),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(color: mainColor),
                                          ),
                                          child: Text(
                                            categoryName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            addressText.isNotEmpty
                                                ? addressText
                                                : 'Address not provided',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(
                                        height: 1, color: Color(0xFFEEEEEE)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_outlined,
                                              size: 16,
                                              color: property.status == 1
                                                  ? Colors.green[700]
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              property.status == 1
                                                  ? 'Active Property'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: property.status == 1
                                                    ? Colors.green[700]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (property.reviewsCount != null &&
                                            property.reviewsCount! > 0)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 18,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${property.reviewsAvgRating ?? '0.0'} (${property.reviewsCount})',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Starting Price',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            startingPrice != null &&
                                                    startingPrice.isNotEmpty
                                                ? '৳ $startingPrice'
                                                : '৳ 0',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '/ night',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (totalPrice != null &&
                                        totalPrice.isNotEmpty &&
                                        totalPrice != '0') ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Total Price',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '৳ $totalPrice',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // OVERVIEW
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.description_outlined,
                                      size: 20, color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text(
                                    'Overview',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                overviewText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // FACILITIES
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.hotel_class_outlined,
                                      size: 20, color: Colors.black87),
                                  SizedBox(width: 8),
                                  Text(
                                    'Facilities & Amenities',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (facilities.isEmpty)
                                Text(
                                  'No specific facilities listed.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: facilities.map((facility) {
                                    final photoUrl = controller
                                        .mediaUrl(facility.facilityPhoto);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: mainColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (photoUrl.isNotEmpty)
                                            Image.network(
                                              photoUrl,
                                              width: 16,
                                              height: 16,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.check_circle_outline,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                          const SizedBox(width: 6),
                                          Text(
                                            facility.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ROOMS (2 column grid)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.meeting_room_outlined,
                                      size: 20, color: Colors.black87),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rooms (${rooms.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (rooms.isEmpty)
                                Text(
                                  'No rooms currently listed under this property.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: rooms.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    mainAxisExtent: 104,
                                  ),
                                  itemBuilder: (context, index) {
                                    final room = rooms[index];
                                    final photos = room.roomImages ?? [];
                                    final firstPhoto = photos.isNotEmpty
                                        ? controller
                                            .mediaUrl(photos.first.photoName)
                                        : '';

                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: mainColor.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: firstPhoto.isNotEmpty
                                                ? Image.network(
                                                    firstPhoto,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.bed,
                                                        color: Colors.grey,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.bed,
                                                      color: Colors.grey,
                                                      size: 28,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  room.roomName ??
                                                      'Room ${index + 1}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  room.roomType?.name ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${room.capacityOfAdults ?? 0} Adults',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        '৳ ${room.roomPricePerNight ?? '0'}/night',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        // NEARBY + ADDITIONAL (side by side)
                        if (nearBy.isNotEmpty || additional.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (nearBy.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.near_me_outlined,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(width: 8),
                                            Text(
                                              'Nearby Places',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          nearBy,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (nearBy.isNotEmpty && additional.isNotEmpty)
                                const SizedBox(width: 14),
                              if (additional.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.info_outline_rounded,
                                                size: 20,
                                                color: Colors.black87),
                                            SizedBox(width: 8),
                                            Text(
                                              'Additional Details',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          additional,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],

                        // MANAGER
                        if (manager != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.person_pin_circle_outlined,
                                        size: 20, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text(
                                      'Manager Information',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          mainColor.withValues(alpha: 0.3),
                                      backgroundImage: managerPhoto.isNotEmpty
                                          ? NetworkImage(managerPhoto)
                                          : null,
                                      child: managerPhoto.isEmpty
                                          ? const Icon(Icons.person,
                                              color: Colors.black87)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            manager.name ?? 'Manager',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            manager.role?.toUpperCase() ??
                                                'MANAGER',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (manager.phone != null &&
                                              manager.phone!
                                                  .trim()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              manager.phone!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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

class QuickTechPropertyDetailsDesktopView extends StatelessWidget {
  final PropertyDetailsController controller;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  const QuickTechPropertyDetailsDesktopView({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final property = controller.property!;
    final images = property.multiImages ?? [];
    final categoryName = property.propertyCategory?.name ?? 'Property';
    final addressText = [
      if (property.address != null && property.address!.trim().isNotEmpty)
        property.address!.trim(),
      if (property.district?.name != null &&
          property.district!.name!.trim().isNotEmpty)
        property.district!.name!.trim(),
      if (property.country?.name != null &&
          property.country!.name!.trim().isNotEmpty)
        property.country!.name!.trim(),
    ].join(', ');
    final startingPrice = property.startingPricePerNight;
    final totalPrice = property.totalPrice?.toString();
    final overviewText = property.overview ??
        property.aboutProperty?.toString() ??
        'No overview details provided for this property.';
    final facilities = property.uniqueFacilities ?? [];
    final rooms = property.propertyRooms ?? [];
    final nearBy = (property.nearBy ?? '').trim();
    final additional = (property.additionalDetails ?? '').trim();
    final manager = property.manager;
    final managerPhoto = controller.mediaUrl(manager?.profilePhoto);

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
                    onTap: () => Get.back(),
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
                    'Property Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Edit Property',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                      // ============ LEFT COLUMN ============
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GALLERY
                            if (images.isEmpty)
                              Container(
                                height: 380,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.apartment_rounded,
                                        size: 72, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('No Photos Available',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: [
                                  Container(
                                    height: 420,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Obx(() {
                                              final idx = controller
                                                  .activeImageIndex.value;
                                              final safeIdx =
                                                  idx < images.length ? idx : 0;
                                              return Image.network(
                                                controller.mediaUrl(
                                                  images[safeIdx].photoName,
                                                ),
                                                key: ValueKey(safeIdx),
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    color: Colors.grey[100],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: mainColor,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, e, s) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons
                                                          .broken_image_rounded,
                                                      size: 48,
                                                      color: Colors.grey[400],
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                          ),
                                          if (images.length > 1) ...[
                                            Positioned(
                                              left: 12,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors
                                                        .black
                                                        .withValues(alpha: 0.5),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        final cur = controller
                                                            .activeImageIndex
                                                            .value;
                                                        controller
                                                                .activeImageIndex
                                                                .value =
                                                            cur == 0
                                                                ? images.length -
                                                                    1
                                                                : cur - 1;
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .chevron_left_rounded,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 12,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors
                                                        .black
                                                        .withValues(alpha: 0.5),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        final cur = controller
                                                            .activeImageIndex
                                                            .value;
                                                        controller
                                                                .activeImageIndex
                                                                .value =
                                                            cur ==
                                                                    images.length -
                                                                        1
                                                                ? 0
                                                                : cur + 1;
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .chevron_right_rounded,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          Positioned(
                                            bottom: 14,
                                            right: 14,
                                            child: Obx(
                                              () => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.65),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${controller.activeImageIndex.value + 1} / ${images.length}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (images.length > 1) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 72,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: images.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => controller
                                                  .activeImageIndex
                                                  .value = index,
                                              child: Obx(
                                                () => Container(
                                                  width: 96,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: controller
                                                                  .activeImageIndex
                                                                  .value ==
                                                              index
                                                          ? mainColorDark
                                                          : Colors
                                                              .grey.shade300,
                                                      width: controller
                                                                  .activeImageIndex
                                                                  .value ==
                                                              index
                                                          ? 2.5
                                                          : 1,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      controller.mediaUrl(
                                                        images[index]
                                                            .photoName,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              Container(
                                                        color:
                                                            Colors.grey[200],
                                                        child: const Icon(
                                                          Icons
                                                              .broken_image_rounded,
                                                          size: 20,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            const SizedBox(height: 18),

                            // HEADER
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          property.title ?? 'Untitled Property',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mainColor.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: mainColor),
                                        ),
                                        child: Text(
                                          categoryName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 20,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          addressText.isNotEmpty
                                              ? addressText
                                              : 'Address not provided',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(
                                      height: 1, color: Color(0xFFEEEEEE)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.verified_outlined,
                                            size: 18,
                                            color: property.status == 1
                                                ? Colors.green[700]
                                                : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            property.status == 1
                                                ? 'Active Property'
                                                : 'Inactive',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: property.status == 1
                                                  ? Colors.green[700]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (property.reviewsCount != null &&
                                          property.reviewsCount! > 0)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 20,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${property.reviewsAvgRating ?? '0.0'} (${property.reviewsCount})',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // OVERVIEW
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.description_outlined,
                                          size: 22, color: Colors.black87),
                                      SizedBox(width: 8),
                                      Text(
                                        'Overview',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    overviewText,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // FACILITIES
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.hotel_class_outlined,
                                          size: 22, color: Colors.black87),
                                      SizedBox(width: 8),
                                      Text(
                                        'Facilities & Amenities',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  if (facilities.isEmpty)
                                    Text(
                                      'No specific facilities listed.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: facilities.map((facility) {
                                        final photoUrl = controller
                                            .mediaUrl(facility.facilityPhoto);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: mainColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (photoUrl.isNotEmpty)
                                                Image.network(
                                                  photoUrl,
                                                  width: 18,
                                                  height: 18,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                    Icons.check_circle_outline,
                                                    size: 18,
                                                    color: Colors.green,
                                                  ),
                                                )
                                              else
                                                const Icon(
                                                  Icons.check_circle_outline,
                                                  size: 18,
                                                  color: Colors.green,
                                                ),
                                              const SizedBox(width: 8),
                                              Text(
                                                facility.name ?? '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ROOMS
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.meeting_room_outlined,
                                          size: 22, color: Colors.black87),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rooms (${rooms.length})',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  if (rooms.isEmpty)
                                    Text(
                                      'No rooms currently listed under this property.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: rooms.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 14,
                                        crossAxisSpacing: 14,
                                        mainAxisExtent: 112,
                                      ),
                                      itemBuilder: (context, index) {
                                        final room = rooms[index];
                                        final photos = room.roomImages ?? [];
                                        final firstPhoto = photos.isNotEmpty
                                            ? controller.mediaUrl(
                                                photos.first.photoName)
                                            : '';

                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: mainColor
                                                .withValues(alpha: 0.25),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: firstPhoto.isNotEmpty
                                                    ? Image.network(
                                                        firstPhoto,
                                                        width: 88,
                                                        height: 88,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                Container(
                                                          width: 88,
                                                          height: 88,
                                                          color: Colors
                                                              .grey.shade300,
                                                          child: const Icon(
                                                            Icons.bed,
                                                            color: Colors.grey,
                                                            size: 30,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 88,
                                                        height: 88,
                                                        color:
                                                            Colors.grey.shade300,
                                                        child: const Icon(
                                                          Icons.bed,
                                                          color: Colors.grey,
                                                          size: 30,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      room.roomName ??
                                                          'Room ${index + 1}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      room.roomType?.name ?? '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .person_outline,
                                                              size: 14,
                                                              color:
                                                                  Colors.black54,
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Text(
                                                              '${room.capacityOfAdults ?? 0} Adults',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                          ],
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            '৳ ${room.roomPricePerNight ?? '0'}/night',
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black87,
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
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // ============ RIGHT COLUMN ============
                      SizedBox(
                        width: 360,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PRICE
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, const Color(0xFFFFFBEB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: mainColor.withValues(alpha: 0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Starting Price',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          startingPrice != null &&
                                                  startingPrice.isNotEmpty
                                              ? '৳ $startingPrice'
                                              : '৳ 0',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '/ night',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (totalPrice != null &&
                                      totalPrice.isNotEmpty &&
                                      totalPrice != '0') ...[
                                    const SizedBox(height: 14),
                                    const Divider(
                                        height: 1, color: Color(0xFFEEEEEE)),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Price',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '৳ $totalPrice',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // MANAGER
                            if (manager != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.person_pin_circle_outlined,
                                            size: 22, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text(
                                          'Manager Information',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              mainColor.withValues(alpha: 0.3),
                                          backgroundImage:
                                              managerPhoto.isNotEmpty
                                                  ? NetworkImage(managerPhoto)
                                                  : null,
                                          child: managerPhoto.isEmpty
                                              ? const Icon(Icons.person,
                                                  color: Colors.black87)
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                manager.name ?? 'Manager',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                manager.role?.toUpperCase() ??
                                                    'MANAGER',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              if (manager.phone != null &&
                                                  manager.phone!
                                                      .trim()
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  manager.phone!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // NEARBY
                            if (nearBy.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.near_me_outlined,
                                            size: 22, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text(
                                          'Nearby Places',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      nearBy,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // ADDITIONAL
                            if (additional.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.info_outline_rounded,
                                            size: 22, color: Colors.black87),
                                        SizedBox(width: 8),
                                        Text(
                                          'Additional Details',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      additional,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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