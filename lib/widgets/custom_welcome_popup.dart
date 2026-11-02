
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../consts/consts.dart';

const String kCustomerWebsiteUrl = 'https://renth.app';

Future<void> _openCustomerWebsite() async {
  final Uri url = Uri.parse(kCustomerWebsiteUrl);

  try {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (e) {
    debugPrint('Could not launch $url: $e');
  }
}

class CustomWelcomePopup extends StatefulWidget {
  final Widget child;
  final Duration autoHideAfter;

  const CustomWelcomePopup({
    super.key,
    required this.child,
    this.autoHideAfter = const Duration(seconds: 3),
  });

  @override
  State<CustomWelcomePopup> createState() =>
      _CustomWelcomePopupState();
}

class _CustomWelcomePopupState extends State<CustomWelcomePopup>
    with TickerProviderStateMixin {
  static const double _fabSize = 48;
  static const double _fabRight = 22;

  bool _open = false;
  Timer? _timer;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      reverseDuration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _rotationAnimation = Tween<double>(
      begin: -0.035,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.7,
        curve: Curves.easeOut,
      ),
      reverseCurve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showDialog(autoHide: true);
    });
  }

  void _showDialog({bool autoHide = false}) {
    _timer?.cancel();

    setState(() => _open = true);
    _animationController.forward(from: 0);

    if (autoHide) {
      _timer = Timer(widget.autoHideAfter, _close);
    }
  }

  void _close() {
    if (!mounted || !_open) return;

    _timer?.cancel();

    setState(() => _open = false);
    _animationController.reverse();
  }

  void _openAgain() {
    if (_open) return;
    _showDialog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final bool isMobile = width < 600;
        final bool isTablet = width >= 600 && width < 1024;

        final double fabBottom = isMobile
            ? 105
            : isTablet
                ? 105
                : 28;

        final double dialogWidth = isMobile
            ? width - 36
            : isTablet
                ? 420
                : 440;

        final double safeDialogWidth =
            dialogWidth.clamp(0.0, width - 24);

        final double maxDialogHeight =
            height - (isMobile ? 120 : 80);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,

            // BACKDROP + BLUR
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_open,
                child: GestureDetector(
                  onTap: _close,
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      final opacity = _fadeAnimation.value;

                      return Opacity(
                        opacity: opacity,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 9 * opacity,
                              sigmaY: 9 * opacity,
                            ),
                            child: Container(
                              color: Colors.black.withValues(
                                alpha: 0.5 * opacity,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // CUSTOMER DIALOG
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_open,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeInOutCubicEmphasized,
                  alignment: _open
                      ? Alignment.center
                      : Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: _open ? 0 : _fabRight + _fabSize / 2,
                      bottom: _open ? 0 : fabBottom + _fabSize / 2,
                      left: _open ? 0 : 12,
                      top: _open ? 0 : 12,
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          alignment: Alignment.bottomRight,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: safeDialogWidth,
                          maxHeight: maxDialogHeight > 0
                              ? maxDialogHeight
                              : height,
                        ),
                        child: _CustomerCard(
                          isMobile: isMobile,
                          onClose: _close,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // FAB
            Positioned(
              right: _fabRight,
              bottom: fabBottom,
              child: IgnorePointer(
                ignoring: _open,
                child: AnimatedScale(
                  scale: _open ? 0 : 1,
                  duration: const Duration(milliseconds: 450),
                  curve: _open
                      ? Curves.easeInCubic
                      : Curves.elasticOut,
                  child: AnimatedOpacity(
                    opacity: _open ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      height: _fabSize,
                      width: _fabSize,
                      child: FloatingActionButton(
                        heroTag: 'welcome_fab',
                        onPressed: _openAgain,
                        elevation: 6,
                        backgroundColor: mainColor,
                        foregroundColor: textColor,
                        shape: const CircleBorder(),
                        tooltip: 'Renth',
                        child: Image.asset(
                          'assets/images/customerlogo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// CUSTOMER CARD
// =====================================================

class _CustomerCard extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onClose;

  const _CustomerCard({
    required this.isMobile,
    required this.onClose,
  });

  static const List<_Benefit> _benefits = [
    _Benefit(
      Icons.search_rounded,
      'Find Your Perfect Stay',
      'Explore properties that match your needs.',
    ),
    _Benefit(
      Icons.calendar_month_rounded,
      'Easy & Convenient Booking',
      'Book your preferred room with ease.',
    ),
    _Benefit(
      Icons.verified_user_rounded,
      'Hassle-Free Experience',
      'Enjoy a smooth and convenient journey.',
    ),
    _Benefit(
      Icons.account_balance_wallet_rounded,
      'Stays Within Your Budget',
      'Discover options that fit your budget.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double pad = isMobile ? 22 : 26;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: mainColor.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: 0.25),
              blurRadius: 45,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  pad,
                  14,
                  pad,
                  22,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mainColor,
                      mainColor.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),

                    // CUSTOMER LOGO
                    Container(
                      height: 68,
                      width: 68,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/customerlogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Welcome to Renth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Find your perfect stay, effortlessly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 12.5 : 13.5,
                        color: textColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // BENEFITS + CTA
              Padding(
                padding: EdgeInsets.fromLTRB(
                  pad,
                  18,
                  pad,
                  pad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final benefit in _benefits)
                      _BenefitRow(benefit: benefit),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _openCustomerWebsite();
                          onClose();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: textColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore Properties',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Your next stay starts with Renth.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BENEFIT MODEL
// =====================================================

class _Benefit {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit(
    this.icon,
    this.title,
    this.subtitle,
  );
}

// =====================================================
// BENEFIT ROW
// =====================================================

class _BenefitRow extends StatelessWidget {
  final _Benefit benefit;

  const _BenefitRow({
    required this.benefit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              benefit.icon,
              size: 21,
              color: mainColor,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  benefit.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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
