import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';

class ImageGalleryPopupWidget extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryPopupWidget({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ImageGalleryPopupWidget(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<ImageGalleryPopupWidget> createState() =>
      _ImageGalleryPopupWidgetState();
}

class _ImageGalleryPopupWidgetState extends State<ImageGalleryPopupWidget> {
  late int _currentIndex;
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: BlocTheme.theme.defaultBlackColor.withOpacity(0.9),
          child: Stack(
            children: [
              // Image carousel
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping on image
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: widget.images.length,
                    options: CarouselOptions(
                      initialPage: widget.initialIndex,
                      viewportFraction: 1.0,
                      height: screenSize.height,
                      enableInfiniteScroll: widget.images.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    itemBuilder: (BuildContext context, int index, int realIndex) {
                      return SizedBox(
                        width: screenSize.width,
                        height: screenSize.height,
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.contain,
                            width: screenSize.width,
                            height: screenSize.height,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: BlocTheme.theme.defaultGray300Color,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: BlocTheme.theme.defaultGray600Color,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: BlocTheme.theme.defaultBlackColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(BlocTheme.theme.defaultWhiteColor),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Page indicator (if more than one image)
              if (widget.images.length > 1)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.images.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(entry.key),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key
                                ? BlocTheme.theme.defaultWhiteColor
                                : BlocTheme.theme.defaultWhiteColor.withOpacity(0.4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BlocTheme.theme.defaultBlackColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: BlocTheme.theme.defaultWhiteColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
