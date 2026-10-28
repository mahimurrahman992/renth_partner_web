import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:renth_manager/consts/consts.dart';
import 'package:renth_manager/model/response/quick_tech_room_details_response.dart'
    hide PropertyRoom;
import 'package:renth_manager/model/response/quickech_get_room_data.dart';
import 'package:renth_manager/widgets/web_image.dart';

class RoomDetailsController extends GetxController {
  // isLoading = details fetch, isUpdating = save korar shomoy
  var isLoading = true.obs;
  var isUpdating = false.obs;
  var roomDetails = QuicktechRoomDetails().obs;
  var errorMessage = ''.obs;

  // Dropdown data
  var properties = <Properties>[].obs;
  var roomTypes = <Type>[].obs;
  var bedTypes = <Type>[].obs;
  var facilities = <Faciliti>[].obs;

  // Selected values
  var selectedProperty = Rxn<Properties>();
  var selectedRoomType = Rxn<Type>();
  var selectedBedType = Rxn<Type>();
  var selectedFacilityIds = <int>[].obs;

  // Editable fields
  var roomNameController = TextEditingController();
  var roomPriceController = TextEditingController();
  var capacityAdultsController = TextEditingController();
  var capacityChildrenController = TextEditingController();
  var roomSizeController = TextEditingController();
  var roomDescriptionController = TextEditingController();
  var numberOfRoomController = TextEditingController();
  var extraPriceAdultController = TextEditingController();
  var extraPriceChildController = TextEditingController();
  var discountPriceController = TextEditingController();
  var extraMattressPriceController = TextEditingController();
  var vatPercentageController = TextEditingController();
  var serviceChargeController = TextEditingController();

  // Media Reactive Variables
  var selectedVideo = Rxn<File>();
  var selectedImages = <File>[].obs;
  var existingImages = <RoomImage>[].obs;
  var existingVideo = Rxn<String>();

  final ImagePicker _picker = ImagePicker();
  final CommonController commonController = locator.get<CommonController>();

  late final Future<void> _createDataFuture;

  @override
  void onInit() {
    super.onInit();
    _createDataFuture = _loadCreateData();
  }

  Future<void> _loadCreateData() async {
    try {
      await commonController.fetchRoomCreateData();
      properties.value = commonController.properties;
      roomTypes.value = commonController.roomTypes;
      bedTypes.value = commonController.bedTypes;
      facilities.value = commonController.facilities;
    } catch (e) {
      debugPrint("Error loading create data: $e");
    }
  }

  // --- MEDIA PICKING ---
  Future<void> pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (image != null) {
          selectedImages.add(File(image.path));
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          selectedImages.addAll(images.map((img) => File(img.path)).toList());
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        selectedVideo.value = File(video.path);
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    }
  }

  // --- MEDIA REMOVAL & HELPERS ---
  final Map<String, Uint8List> _existingImageBytesCache = {};

  void _preFetchExistingImages() {
    for (var img in existingImages) {
      final rawUrl = img.photoName ?? '';
      final resolvedUrl = WebSafeNetworkImage.resolveUrl(rawUrl);
      if (resolvedUrl.isNotEmpty &&
          !_existingImageBytesCache.containsKey(resolvedUrl)) {
        _downloadImageBytes(resolvedUrl).then((bytes) {
          if (bytes != null) {
            debugPrint(
              "✓ Pre-fetched existing image: $resolvedUrl (${bytes.length} bytes)",
            );
          }
        });
      }
    }
  }

  void removeExistingImage(int index) {
    if (existingImages.length + selectedImages.length <= 1) {
      showErrorToast("At least one image is required");
      return;
    }
    if (index >= 0 && index < existingImages.length) {
      final removed = existingImages.removeAt(index);
      final rawUrl = removed.photoName ?? '';
      final resolvedUrl = WebSafeNetworkImage.resolveUrl(rawUrl);
      _existingImageBytesCache.remove(resolvedUrl);
    }
  }

  void removeSelectedImage(int index) {
    if (existingImages.length + selectedImages.length <= 1) {
      showErrorToast("At least one image is required");
      return;
    }
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void removeExistingVideo() {
    existingVideo.value = null;
  }

  void removeSelectedVideo() {
    selectedVideo.value = null;
  }

  Future<Uint8List?> _downloadImageBytes(String url) async {
    if (_existingImageBytesCache.containsKey(url)) {
      return _existingImageBytesCache[url];
    }

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        _existingImageBytesCache[url] = response.bodyBytes;
        return response.bodyBytes;
      }
      debugPrint(
        "Direct download returned status ${response.statusCode} for $url",
      );
    } catch (e) {
      debugPrint("Direct download failed for $url (likely CORS on web): $e");
    }

    if (kIsWeb) {
      final proxies = [
        'https://wsrv.nl/?url=${Uri.encodeComponent(url)}',
        'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}',
      ];

      for (var proxyUrl in proxies) {
        try {
          final response = await http
              .get(Uri.parse(proxyUrl))
              .timeout(const Duration(seconds: 15));
          if (response.statusCode == 200) {
            _existingImageBytesCache[url] = response.bodyBytes;
            return response.bodyBytes;
          }
        } catch (e) {
          debugPrint("Proxy download failed on $proxyUrl: $e");
        }
      }
    }

    return null;
  }

  // "1000.00" -> "1000", "12.5" -> "12.5"
  String parsePrice(String value) {
    final d = double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toString();
  }

  // API theke asha "1000.00" field e dekhanor jonno
  String _fmt(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final d = double.tryParse(value);
    if (d == null) return value;
    return d == d.truncateToDouble() ? d.toInt().toString() : d.toString();
  }

  // --- API UPDATE ---
  Future<void> updateRoomDetails(int roomId) async {
    final category = selectedProperty.value?.propertyCategory?.name ?? "Hotel";
    final isHotel = category == 'Hotel';
    final showChildren =
        category != 'Bachelor' &&
        category != 'Rider' &&
        category != 'Flat Sale/Buy';

    final totalImages = existingImages.length + selectedImages.length;
    if (totalImages < 1) {
      showErrorToast("At least one image is required");
      return;
    }

    if (selectedProperty.value == null) {
      showErrorToast("Please select Property");
      return;
    }

    if (roomNameController.text.trim().isEmpty) {
      String hint = 'room name';
      if (category == 'Flat Sale/Buy') {
        hint = 'flat name';
      } else if (category == 'Family Home') {
        hint = 'home name';
      } else if (category == 'Rider') {
        hint = 'rider name';
      }
      showErrorToast("Enter $hint");
      return;
    }

    if (selectedRoomType.value == null) {
      String hint = "room type";
      if (category == 'Flat Sale/Buy' || category == 'Family Home') {
        hint = "flat type";
      } else if (category == 'Rider') {
        hint = "rider type";
      }
      showErrorToast("Select $hint");
      return;
    }

    if (category != 'Flat Sale/Buy' &&
        category != 'Rider' &&
        selectedBedType.value == null) {
      showErrorToast("Select bed type");
      return;
    }

    if (roomPriceController.text.trim().isEmpty) {
      String hint = 'room price';
      if (category == 'Flat Sale/Buy') {
        hint = 'sale price';
      } else if (category == 'Family Home' ||
          category == 'Bachelor' ||
          category == 'Hostel' ||
          category == 'Rider') {
        hint = 'monthly rent';
      }
      showErrorToast("Enter $hint");
      return;
    }

    if (category != 'Rider' && capacityAdultsController.text.trim().isEmpty) {
      showErrorToast("Enter adult capacity");
      return;
    }

    if (isHotel && capacityChildrenController.text.trim().isEmpty) {
      showErrorToast("Enter child capacity");
      return;
    }

    if (roomSizeController.text.trim().isEmpty) {
      String hint = 'room size';
      if (category == 'Flat Sale/Buy') {
        hint = 'flat size';
      } else if (category == 'Family Home') {
        hint = 'home size';
      }
      showErrorToast("Enter $hint");
      return;
    }

    final vat = double.tryParse(vatPercentageController.text.trim()) ?? 0;
    if (vat > 100) {
      showErrorToast("VAT percentage cannot be greater than 100%");
      return;
    }

    if (numberOfRoomController.text.trim().isEmpty) {
      String hint = 'number of rooms';
      if (category == 'Flat Sale/Buy') {
        hint = 'number of flats';
      } else if (category == 'Family Home') {
        hint = 'number of homes';
      }
      showErrorToast("Enter $hint");
      return;
    }

    try {
      isUpdating(true);

      var url = Uri.parse(Api.roomUpdate);
      var token = GetStorage().read(StorageKeys.accessToken);

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': "Bearer $token",
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'property_room_id': roomId.toString(),
        'property_id': selectedProperty.value!.id.toString(),
        'room_type_id': selectedRoomType.value!.id.toString(),
        'bed_type_id':
            (category == 'Flat Sale/Buy' || category == 'Rider')
                ? '0'
                : selectedBedType.value?.id.toString() ?? '0',
        'room_name': roomNameController.text.trim(),
        'room_price_per_night': parsePrice(roomPriceController.text),
        'capacity_of_adults':
            category == 'Rider' ? '0' : capacityAdultsController.text.trim(),
        'capacity_of_children':
            showChildren && capacityChildrenController.text.trim().isNotEmpty
                ? capacityChildrenController.text.trim()
                : '0',
        'room_size': roomSizeController.text.trim(),
        'room_description': roomDescriptionController.text.trim(),
        'number_of_room': numberOfRoomController.text.trim(),
        'extra_price_per_adult':
            isHotel ? parsePrice(extraPriceAdultController.text) : '0',
        'extra_price_per_child_bed':
            isHotel ? parsePrice(extraPriceChildController.text) : '0',
        'discount_price_per_night': parsePrice(discountPriceController.text),
        'extra_mattress_price_per_night':
            isHotel ? parsePrice(extraMattressPriceController.text) : '0',
        'vat_percentage':
            vatPercentageController.text.trim().isEmpty
                ? '0'
                : vatPercentageController.text.trim(),
        'service_charge':
            serviceChargeController.text.trim().isEmpty
                ? '0'
                : serviceChargeController.text.trim(),
      });

      // Facilities (Hotel only)
      if (isHotel) {
        for (var i = 0; i < selectedFacilityIds.length; i++) {
          request.fields['facilityIds[$i]'] = selectedFacilityIds[i].toString();
        }
      }

      // Video (notun pick korle)
      if (selectedVideo.value != null) {
        if (kIsWeb) {
          final xfile = XFile(selectedVideo.value!.path);
          final bytes = await xfile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'video',
              bytes,
              filename: xfile.name.isNotEmpty ? xfile.name : 'video.mp4',
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'video',
              selectedVideo.value!.path,
            ),
          );
        }
      }

      // Images: kichu change hole kept + new duto-i pathano
      final initialImages = roomDetails.value.propertyRoom?.roomImages ?? [];
      final bool hasExistingRemoved =
          existingImages.length != initialImages.length ||
          !existingImages.every(
            (e) => initialImages.any(
              (init) =>
                  (init.id != null && init.id == e.id) ||
                  (init.photoName != null && init.photoName == e.photoName),
            ),
          );
      final bool imageSetChanged =
          hasExistingRemoved || selectedImages.isNotEmpty;

      if (imageSetChanged) {
        if (existingImages.isNotEmpty) {
          final List<Uint8List?> downloadedBytes = await Future.wait(
            existingImages.map((img) async {
              final rawUrl = img.photoName ?? '';
              final resolvedUrl = WebSafeNetworkImage.resolveUrl(rawUrl);
              if (resolvedUrl.isEmpty) return null;
              return await _downloadImageBytes(resolvedUrl);
            }),
          );

          for (var i = 0; i < downloadedBytes.length; i++) {
            final bytes = downloadedBytes[i];
            if (bytes == null) {
              showErrorToast(
                "Failed to process existing images. Please try again.",
              );
              return;
            }
            final rawUrl = existingImages[i].photoName ?? '';
            String fileName = rawUrl.split('/').last;
            if (fileName.isEmpty || !fileName.contains('.')) {
              fileName = 'existing_img_$i.jpg';
            }
            request.files.add(
              http.MultipartFile.fromBytes(
                'multi_img[]',
                bytes,
                filename: fileName,
              ),
            );
          }
        }

        for (var i = 0; i < selectedImages.length; i++) {
          if (kIsWeb) {
            final xfile = XFile(selectedImages[i].path);
            final bytes = await xfile.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'multi_img[]',
                bytes,
                filename:
                    xfile.name.isNotEmpty ? xfile.name : 'new_room_img_$i.jpg',
              ),
            );
          } else {
            request.files.add(
              await http.MultipartFile.fromPath(
                'multi_img[]',
                selectedImages[i].path,
              ),
            );
          }
        }
      }
      debugPrint(
        "Images changed: $imageSetChanged, kept ${existingImages.length}, new ${selectedImages.length}",
      );

      debugPrint("Sending update request... fields: ${request.fields}");
      http.StreamedResponse response = await request.send().timeout(
        const Duration(seconds: 180),
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint("Update Success Response: $responseBody");
        showSuccessToast("Room updated successfully");
        Get.back(result: true);
      } else {
        debugPrint(
          "Failed to update: Status ${response.statusCode}, Body: $responseBody",
        );

        String errorMsg =
            "Failed to update room. Status: ${response.statusCode}";
        try {
          final decoded = jsonDecode(responseBody);
          errorMsg = decoded['message'] ?? decoded['error'] ?? errorMsg;
        } catch (_) {}

        showErrorToast(errorMsg);
      }
    } catch (e) {
      debugPrint("Exception inside updateRoomDetails: $e");
      showErrorToast("Error: ${e.toString()}");
    } finally {
      isUpdating(false);
    }
  }

  Future<void> fetchRoomDetails(int roomId) async {
    try {
      isLoading(true);
      errorMessage('');

      // dropdown data load shesh howa porjonto opekkha
      await _createDataFuture;
      if (properties.isEmpty) {
        await _loadCreateData();
      }

      final url = Api.roomDetails(roomId);
      final token = GetStorage().read(StorageKeys.accessToken);
      debugPrint(url);

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        roomDetails.value = QuicktechRoomDetails.fromJson(data);

        if (roomDetails.value.propertyRoom == null) {
          errorMessage.value = "Room not found (ID: $roomId)";
          showErrorToast("Room not found");
          return;
        }

        _populateControllers();
        debugPrint("✓ Room details fetched and populated successfully");
      } else {
        errorMessage.value = "Error: ${response.statusCode}";
        showErrorToast("Failed to load room details");
      }
    } on SocketException {
      errorMessage.value = "Network error";
      showErrorToast("Network connection failed");
    } catch (e) {
      errorMessage.value = "Exception: $e";
      showErrorToast("Error: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

Future<void> deleteRoom({required int propertyRoomId}) async {
  try {
    isLoading.value = true;

    var request = http.MultipartRequest('POST', Uri.parse(Api.roomDelete));
    request.headers.addAll({
      'Authorization': 'Bearer ${GetStorage().read(StorageKeys.accessToken)}',
      'Accept': 'application/json',
    });
    request.fields.addAll({'property_room_id': propertyRoomId.toString()});

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      debugPrint('Delete room response: $data');

      
      final roomController = locator.get<QuickTechRoomController>();
      final dashboardController = locator.get<DashboardController>();

      final rawPropertyId = GetStorage().read(StorageKeys.selectedPropertyId);
      final propertyId = int.tryParse(rawPropertyId?.toString() ?? '');

    
      await Future.wait([
        dashboardController.getManagerDashboard(),
        if (propertyId != null)
          roomController.fetchRoomRecords(propertyId: propertyId),
      ]);

      Get.back();
      showSuccessToast('Room deleted successfully');
    } else {
      debugPrint('Delete room failed: $responseBody');
      showErrorToast('Failed to delete room. Please try again.');
    }
  } catch (e) {
    debugPrint('Delete room error: $e');
    showErrorToast('Something went wrong. Please try again.');
  } finally {
    isLoading.value = false;
  }
}

  void _populateControllers() {
    final room = roomDetails.value.propertyRoom;
    if (room == null) return;

    roomNameController.text = room.roomName ?? '';
    roomPriceController.text = _fmt(room.roomPricePerNight);
    capacityAdultsController.text = room.capacityOfAdults?.toString() ?? '';
    capacityChildrenController.text = room.capacityOfChildren?.toString() ?? '';
    roomSizeController.text = room.roomSize ?? '';
    roomDescriptionController.text = room.roomDescription ?? '';
    numberOfRoomController.text = room.numberOfRoom?.toString() ?? '';
    extraPriceAdultController.text = _fmt(room.extraPricePerAdult);
    extraPriceChildController.text = _fmt(room.extraPricePerChildBed);
    discountPriceController.text = _fmt(room.discountPricePerNight);
    extraMattressPriceController.text = _fmt(room.extraMattressPricePerNight);
    vatPercentageController.text = room.vatPercentage?.toString() ?? '';
    serviceChargeController.text = _fmt(room.serviceCharge);

    selectedProperty.value = properties.firstWhereOrNull(
      (p) => p.id == room.propertyId,
    );
    selectedRoomType.value = roomTypes.firstWhereOrNull(
      (rt) => rt.id == room.roomTypeId,
    );
    selectedBedType.value = bedTypes.firstWhereOrNull(
      (bt) => bt.id == room.bedTypeId,
    );

    selectedFacilityIds.value =
        (room.facilities ?? [])
            .map((f) => f.id ?? 0)
            .where((id) => id != 0)
            .toList();

    existingImages.assignAll(room.roomImages ?? []);
    _existingImageBytesCache.clear();
    _preFetchExistingImages();

    final videoStr = room.video?.toString().trim();
    existingVideo.value =
        (videoStr != null && videoStr.isNotEmpty && videoStr != 'null')
            ? videoStr
            : null;

    selectedImages.clear();
    selectedVideo.value = null;
  }

  void toggleFacility(int id) {
    if (selectedFacilityIds.contains(id)) {
      selectedFacilityIds.remove(id);
    } else {
      selectedFacilityIds.add(id);
    }
  }

  void clearControllers() {
    roomNameController.clear();
    roomPriceController.clear();
    capacityAdultsController.clear();
    capacityChildrenController.clear();
    roomSizeController.clear();
    roomDescriptionController.clear();
    numberOfRoomController.clear();
    extraPriceAdultController.clear();
    extraPriceChildController.clear();
    discountPriceController.clear();
    extraMattressPriceController.clear();
    vatPercentageController.clear();
    serviceChargeController.clear();
    selectedProperty.value = null;
    selectedRoomType.value = null;
    selectedBedType.value = null;
    selectedFacilityIds.clear();
    selectedImages.clear();
    selectedVideo.value = null;
    existingImages.clear();
    existingVideo.value = null;
    _existingImageBytesCache.clear();
  }

  @override
  void onClose() {
    roomNameController.dispose();
    roomPriceController.dispose();
    capacityAdultsController.dispose();
    capacityChildrenController.dispose();
    roomSizeController.dispose();
    roomDescriptionController.dispose();
    numberOfRoomController.dispose();
    extraPriceAdultController.dispose();
    extraPriceChildController.dispose();
    discountPriceController.dispose();
    extraMattressPriceController.dispose();
    vatPercentageController.dispose();
    serviceChargeController.dispose();
    super.onClose();
  }
}
