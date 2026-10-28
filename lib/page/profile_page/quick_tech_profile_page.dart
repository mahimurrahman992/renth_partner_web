import 'package:renth_manager/consts/consts.dart';
import 'package:renth_manager/widgets/web_image.dart';

class QuickTechProfilePage extends StatefulWidget {
  final bool showAppBar;
  const QuickTechProfilePage({super.key, this.showAppBar = false});

  @override
  State<QuickTechProfilePage> createState() => _QuickTechProfilePageState();
}

class _QuickTechProfilePageState extends State<QuickTechProfilePage> {
  final ProfileController profileController = Get.find();
  final dashboardController = locator.get<DashboardController>();
  final commonController = locator.get<CommonController>();

  @override
  void initState() {
    super.initState();
    commonController.fetchPropertyCategories().then((_) {
      profileController.getProfile().then((_) {
        profileController.loadData();
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    final token = GetStorage().read(StorageKeys.accessToken);
    debugPrint('Token:$token');
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                          'Account Information',
                          style: QuickTechAppTextStyle.headline3().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
            
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: borderColor),
              const SizedBox(height: 16),
          
              // Avatar / Profile photo picker
              Center(
                child: Obx(() {
                  if (profileController.isLoading.value) {
                    return Shimmer.fromColors(
                      baseColor: secondColor,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: mainColor),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          profileController.pickImage(ImageSource.gallery);
                        },
                        child: Stack(
                          children: [
                            profileController.pickedBytes.value != null
                                ? ClipOval(
                                  child: Image.memory(
                                    profileController.pickedBytes.value!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : profileController.imageFile.value != null
                                ? WebSafeNetworkImage(
                                  imageUrl:
                                      profileController.imageFile.value!.path,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  isCircle: true,
                                )
                                : WebSafeNetworkImage(
                                  imageUrl:
                                      profileController
                                          .profile
                                          .value
                                          .user
                                          ?.profilePhoto,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  isCircle: true,
                                  errorWidget:
                                      Image.asset(
                                            'assets/images/graduating-student.png',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ).box.roundedFull
                                          .clip(Clip.antiAlias)
                                          .border(color: mainColor, width: 2)
                                          .make(),
                                ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          profileController.pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icons.upload_rounded,
                          size: 16,
                          color: Colors.black87,
                        ),
                        label: const Text(
                          'Change Photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
          
              const SizedBox(height: 24),
          
              // Form Fields
              Text(
                'Full Name',
                style: QuickTechAppTextStyle.bodyBold3().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              customTextField(
                hint: 'Full Name',
                isSuffix: false,
                isVisible: true,
                controller: profileController.name,
              ),
          
              const SizedBox(height: 16),
              Text(
                'Email Address',
                style: QuickTechAppTextStyle.bodyBold3().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              customTextField(
                hint: 'Email Address',
                isSuffix: false,
                isVisible: true,
                controller: profileController.email,
              ),
          
              const SizedBox(height: 16),
              Text(
                'Phone Number',
                style: QuickTechAppTextStyle.bodyBold3().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              phoneTextField(
                hint: 'Phone Number',
                isSuffix: false,
                controller: profileController.phone,
              ),
          
              const SizedBox(height: 16),
              Text(
                'Full Address',
                style: QuickTechAppTextStyle.bodyBold3().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              customTextField(
                hint: 'Full Address',
                isSuffix: false,
                isVisible: true,
                controller: profileController.address,
              ),
          
              const SizedBox(height: 16),
              Text(
                'Country',
                style: QuickTechAppTextStyle.bodyBold3().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() {
                return DropdownButtonFormField<Countries>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: mainColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  value: profileController.selectedCountry.value,
                  hint: const Text(
                    'Select Country',
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                  items:
                      commonController.countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(
                            country.name ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    profileController.setCountry(value);
                  },
                );
              }),
          
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: customButton2(
                  title: 'Save ',
                  icon: Icons.save_rounded,iconColor: textColor,
                  onTap: () {
                    profileController.updateProfile();
                  },
                ),
              ),
            ],
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
      key: dashboardController.scaffoldKey,
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
