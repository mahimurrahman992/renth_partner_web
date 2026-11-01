import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:renth_manager/consts/consts.dart'
    hide Property, PropertyCategory, Manager, MultiImages;
import 'package:renth_manager/model/response/quick_tech_property_details_response.dart'
    hide District;

class PropertyDetailsController extends GetxController {
  // Legacy state (backward compatibility)
  var selectedIndex = 0.obs;
  var selectedAvailableIndex = 0.obs;
  var selectedAvailableIndexName = 'Single Sharing'.obs;
  final RxBool isVerified = RxBool(false);
  final RxBool isChecked = RxBool(false);

  // Details state
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var propertyDetailsResponse = Rxn<QuicktechPropertyDetailsResponse>();

  Property? get property => propertyDetailsResponse.value?.property;

  var activeImageIndex = 0.obs;
  final PageController pageController = PageController();

  // Edit state
  final titleController = TextEditingController();
  final startingPriceController = TextEditingController();
  final addressController = TextEditingController();
  final overviewController = TextEditingController();
  final nearByController = TextEditingController();
  final additionalDetailsController = TextEditingController();

  final RxList<Countries> countries = <Countries>[].obs;
  final RxList<District> districts = <District>[].obs;
  final Rxn<Countries> selectedCountry = Rxn<Countries>();
  final Rxn<District> selectedDistrict = Rxn<District>();
  final RxBool isLoadingLocations = false.obs;

  // Web safe: File er bodole bytes. Edit e shudhu notun image upload hoy.
  final ImagePicker _picker = ImagePicker();
  final RxList<Uint8List> newImageBytes = <Uint8List>[].obs;
  final RxList<String> newImageNames = <String>[].obs;

  final RxBool isUpdating = false.obs;
  final RxBool isEditInitializing = false.obs;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${GetStorage().read(StorageKeys.accessToken)}',
    'Accept': 'application/json',
  };

  // =========================
  // MEDIA URL
  // =========================
  String mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base =
        Api.baseUrl.endsWith('/')
            ? Api.baseUrl.substring(0, Api.baseUrl.length - 1)
            : Api.baseUrl;
    return '$base${path.startsWith('/') ? path : '/$path'}';
  }

  // =========================
  // FETCH PROPERTY DETAILS
  // =========================
  Future<void> fetchPropertyDetails(int id, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = '';

      final response = await http
          .get(Uri.parse('${Api.propertyDetails}$id'), headers: _headers)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        propertyDetailsResponse
            .value = QuicktechPropertyDetailsResponse.fromJson(data);
        activeImageIndex.value = 0;
        if (pageController.hasClients) pageController.jumpToPage(0);
        log('Property details loaded for ID: $id');
      } else {
        errorMessage.value = 'Failed to load details (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      debugPrint('Exception in fetchPropertyDetails: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // COUNTRIES / DISTRICTS
  // =========================
  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse(Api.getCountryCategories),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final res = QuicktechCountryProperyCatgResponse.fromJson(
          jsonDecode(response.body),
        );
        countries.value = res.countries ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
    }
  }

  Future<void> fetchDistrictsByCountry(int countryId) async {
    try {
      isLoadingLocations.value = true;
      final response = await http.get(
        Uri.parse(Api.getdistrictsbyCountry(countryId)),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final res = QuicktechgetdistrictByCountryResponse.fromJson(
          jsonDecode(response.body),
        );
        districts.value = res.districts ?? [];
      } else {
        districts.clear();
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      districts.clear();
    } finally {
      isLoadingLocations.value = false;
    }
  }

  // =========================
  // INITIALIZE EDIT FORM
  // =========================
  Future<void> initializeEditForm({required int propertyId}) async {
    try {
      isEditInitializing.value = true;

      if (property == null || property?.id != propertyId) {
        await fetchPropertyDetails(propertyId);
      }

      final prop = property;
      if (prop == null) return;

      titleController.text = prop.title ?? '';
      startingPriceController.text = prop.startingPricePerNight ?? '';
      addressController.text = prop.address ?? '';
      overviewController.text = prop.overview ?? '';
      nearByController.text = prop.nearBy ?? '';
      additionalDetailsController.text = prop.additionalDetails ?? '';

      // Edit e purono image dekhano hoy na, shudhu notun upload
      newImageBytes.clear();
      newImageNames.clear();

      if (countries.isEmpty) await fetchCountries();

      selectedCountry.value = null;
      selectedDistrict.value = null;

      if (prop.countryId != null && countries.isNotEmpty) {
        selectedCountry.value = countries.firstWhereOrNull(
          (c) => c.id == prop.countryId,
        );
      }

      if (selectedCountry.value?.id != null) {
        await fetchDistrictsByCountry(selectedCountry.value!.id!);
        if (prop.districtId != null && districts.isNotEmpty) {
          selectedDistrict.value = districts.firstWhereOrNull(
            (d) => d.id == prop.districtId,
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing edit form: $e');
    } finally {
      isEditInitializing.value = false;
    }
  }

  void onCountryChanged(Countries? country) {
    selectedCountry.value = country;
    selectedDistrict.value = null;
    districts.clear();
    if (country?.id != null) fetchDistrictsByCountry(country!.id!);
  }

  void onDistrictChanged(District? district) {
    selectedDistrict.value = district;
  }

  // =========================
  // IMAGES (new only)
  // =========================
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 60);
      for (final img in images) {
        newImageBytes.add(await img.readAsBytes());
        newImageNames.add(img.name);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void removeNewImage(int index) {
    if (index < 0 || index >= newImageBytes.length) return;
    newImageBytes.removeAt(index);
    newImageNames.removeAt(index);
  }

  // =========================
  // UPDATE PROPERTY
  // =========================
  Future<bool> updateProperty() async {
    final propId = property?.id;

    if (propId == null) {
      Get.snackbar('Error', 'Property not found');
      return false;
    }
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required');
      return false;
    }
    if (startingPriceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Starting price is required');
      return false;
    }
    if (selectedCountry.value?.id == null) {
      Get.snackbar('Error', 'Country is required');
      return false;
    }
    if (selectedDistrict.value?.id == null) {
      Get.snackbar('Error', 'District is required');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Address is required');
      return false;
    }
    if (overviewController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Overview is required');
      return false;
    }
    if (nearByController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Near by is required');
      return false;
    }
    if (additionalDetailsController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Additional details is required');
      return false;
    }
    if (property?.propertyCategoryId == null) {
      Get.snackbar('Error', 'Property category not found');
      return false;
    }
    if (newImageBytes.isEmpty) {
      Get.snackbar('Error', 'Please upload at least one new image');
      return false;
    }

    try {
      isUpdating.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.properyupdate),
      );
      request.headers.addAll(_headers);

      request.fields.addAll({
        'property_id': propId.toString(),
        'property_category_id': property!.propertyCategoryId.toString(),
        'title': titleController.text.trim(),
        'starting_price_per_night': startingPriceController.text.trim(),
        'country_id': selectedCountry.value!.id.toString(),
        'district_id': selectedDistrict.value!.id.toString(),
        'address': addressController.text.trim(),
        'overview': overviewController.text.trim(),
        'near_by': nearByController.text.trim(),
        'additional_details': additionalDetailsController.text.trim(),
      });

      // Shudhu notun images (bytes theke)
      for (int i = 0; i < newImageBytes.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'multi_img[]',
            newImageBytes[i],
            filename: newImageNames[i],
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );
      final body = await streamed.stream.bytesToString();
      debugPrint('Update status: ${streamed.statusCode}');
      debugPrint('Update response: $body');

      if (streamed.statusCode == 200) {
        Get.snackbar('Success', 'Property updated successfully');
        newImageBytes.clear();
        newImageNames.clear();
        await fetchPropertyDetails(propId, silent: true);

        // Home er property list refresh
        try {
          await locator.get<EditPropertyController>().fetchAllProperties();
        } catch (e) {
          debugPrint('Home refresh failed: $e');
        }
        return true;
      } else {
        String message = 'Update failed (${streamed.statusCode})';
        try {
          final data = jsonDecode(body);
          if (data['message'] != null) message = data['message'].toString();
        } catch (_) {}
        Get.snackbar('Error', message);
        return false;
      }
    } catch (e) {
      debugPrint('Exception in updateProperty: $e');
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    titleController.dispose();
    startingPriceController.dispose();
    addressController.dispose();
    overviewController.dispose();
    nearByController.dispose();
    additionalDetailsController.dispose();
    super.onClose();
  }
}
