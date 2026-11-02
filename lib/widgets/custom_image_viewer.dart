
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
class CustomImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTagPrefix;

  final Color backgroundColor;
  final double minScale;
  final double maxScale;
  final double doubleTapScale;

  const CustomImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTagPrefix,
    this.backgroundColor = Colors.black,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.doubleTapScale = 2.5,
  });

  static void open(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    String? heroTagPrefix,
    Color backgroundColor = Colors.black,
  }) {
    if (imageUrls.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) {
          return CustomImageViewer(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
            heroTagPrefix: heroTagPrefix,
            backgroundColor: backgroundColor,
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<CustomImageViewer> createState() =>
      _CustomImageViewerState();
}

class _CustomImageViewerState extends State<CustomImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex
        .clamp(0, widget.imageUrls.length - 1)
        .toInt();

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final imageUrl = widget.imageUrls[index];

                Widget image = _ZoomableImage(
                  key: ValueKey('zoom-$index'),
                  imageUrl: imageUrl,
                  minScale: widget.minScale,
                  maxScale: widget.maxScale,
                  doubleTapScale: widget.doubleTapScale,
                  resetToken: _currentIndex,
                );

                if (widget.heroTagPrefix != null) {
                  image = Hero(
                    tag: '${widget.heroTagPrefix}$index',
                    child: image,
                  );
                }

                return image;
              },
            ),
          ),

          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
          ),

          // Image counter
          if (widget.imageUrls.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

// Individual zoom controller for each image

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final double minScale;
  final double maxScale;
  final double doubleTapScale;
  final int resetToken;

  const _ZoomableImage({
    super.key,
    required this.imageUrl,
    required this.minScale,
    required this.maxScale,
    required this.doubleTapScale,
    required this.resetToken,
  });

  @override
  State<_ZoomableImage> createState() =>
      _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;

  Animation<Matrix4>? _animation;

  TapDownDetails? _doubleTapDetails;

  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();

    _transformationController = TransformationController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          _transformationController.value =
              _animation!.value;
        }
      });
  }

  @override
  void didUpdateWidget(covariant _ZoomableImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.resetToken != widget.resetToken) {
      _resetZoom();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _updateZoomState() {
    final zoomed =
        _transformationController.value.getMaxScaleOnAxis() >
            1.01;

    if (_isZoomed != zoomed && mounted) {
      setState(() {
        _isZoomed = zoomed;
      });
    }
  }

  void _resetZoom() {
    _animationController.stop();

    _transformationController.value = Matrix4.identity();

    if (mounted) {
      setState(() {
        _isZoomed = false;
      });
    }
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final currentScale =
        _transformationController.value.getMaxScaleOnAxis();

    if (currentScale > 1.01) {
      _animateTo(Matrix4.identity(), false);
      return;
    }

    final position = _doubleTapDetails?.localPosition;

    if (position == null) return;

    final scale = widget.doubleTapScale;

    final target = Matrix4.identity()
      ..translate(
        -position.dx * (scale - 1),
        -position.dy * (scale - 1),
      )
      ..scale(scale);

    _animateTo(target, true);
  }

  void _animateTo(Matrix4 target, bool zoomed) {
    _animationController.stop();

    _animation = Matrix4Tween(
      begin: Matrix4.copy(_transformationController.value),
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    setState(() {
      _isZoomed = zoomed;
    });

    _animationController.forward(from: 0);
  }

  Widget _buildImage(double width, double height) {
    if (kIsWeb) {
      return buildWebHtmlImage(
        imageUrl: widget.imageUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorWidget: const Icon(
          Icons.broken_image,
          color: Colors.white54,
          size: 60,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      },
      errorWidget: (context, url, error) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 60,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController:
                  _transformationController,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              panEnabled: _isZoomed,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(100),
              clipBehavior: Clip.none,
              onInteractionUpdate: (_) {
                _updateZoomState();
              },
              onInteractionEnd: (_) {
                _updateZoomState();
              },
              child: SizedBox(
                width: width,
                height: height,
                child: _buildImage(width, height),
              ),
            ),
          ),
        );
      },
    );
  }
}


final Set<String> _registeredViewTypes = {};

Widget buildWebHtmlImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  final String viewType =
      'web-img-${imageUrl.hashCode}-${fit.index}';

  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final imgElement = web.HTMLImageElement()
          ..src = imageUrl
          ..draggable = false
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'block'
          ..style.objectFit = _boxFitToCss(fit)
          ..style.pointerEvents = 'none'
          ..style.border = 'none';

        return imgElement;
      },
    );
  }

  return SizedBox(
    width: width,
    height: height,
    child: IgnorePointer(
      child: HtmlElementView(
        viewType: viewType,
      ),
    ),
  );
}

String _boxFitToCss(BoxFit fit) {
  switch (fit) {
    case BoxFit.fill:
      return 'fill';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.cover:
      return 'cover';
    case BoxFit.fitWidth:
      return 'contain';
    case BoxFit.fitHeight:
      return 'contain';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
  }
}
