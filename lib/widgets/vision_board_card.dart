import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tushar_db/services/app_text_style.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/app_theme.dart';
import '../services/scale_util.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/vsion_board_controller.dart';
import '../services/scale_util.dart';
import 'package:timeago/timeago.dart' as timeago;

class VisionBoardItemCard extends StatelessWidget {
  final VisionBoardItem item;
  final VoidCallback onEdit;
  final RxInt _currentImageIndex = 0.obs;

  VisionBoardItemCard({required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Reset current image index if it's out of bounds
    if (_currentImageIndex.value >= item.imageUrls.length) {
      _currentImageIndex.value = item.imageUrls.length - 1;
    }
    if (_currentImageIndex.value < 0) {
      _currentImageIndex.value = 0;
    }

    return Card(
      elevation: 0,
      margin: ScaleUtil.only(top: 8, bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrls.isNotEmpty) _buildImageCarousel(),
          //   if (item.imageUrls.length > 1) _buildDotIndicator(),
          _buildCardContent(context),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 1,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          _currentImageIndex.value = index;
        },
      ),
      items: item.imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ZoomableImageWidget(
                    imageUrls: item.imageUrls,
                    initialIndex: _currentImageIndex.value,
                  ),
                ));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // Widget _buildDotIndicator() {
  //   return Padding(
  //     padding: ScaleUtil.all(8),
  //     child: Center(
  //       child: DotsIndicator(
  //         dotsCount: item.imageUrls.length,
  //         position: _currentImageIndex.value
  //             .clamp(0, item.imageUrls.length - 1)
  //             .toInt(),
  //         decorator: DotsDecorator(
  //           size: Size.square(ScaleUtil.width(9)),
  //           activeSize: Size(ScaleUtil.width(18), ScaleUtil.height(9)),
  //           activeShape:
  //               RoundedRectangleBorder(borderRadius: ScaleUtil.circular(5)),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCardContent(BuildContext context) {
    final VisionBoardController controller = Get.find<VisionBoardController>();
    final AppTheme appTheme = Get.find<AppTheme>();

    return Padding(
      padding: ScaleUtil.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: appTheme.bodyMedium.copyWith(),
                    ),
                    ScaleUtil.sizedBox(height: 4),
                    Text(
                      _getTimeAgo(),
                      style: appTheme.bodyMedium
                          .copyWith(color: appTheme.secondaryTextColor),
                    ),
                  ],
                ),
              ),
              _buildNotificationButton(context, controller, appTheme),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.penToSquare,
                  size: ScaleUtil.iconSize(15),
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.trashCan,
                  color: appTheme.colorScheme.primary,
                ),
                onPressed: () => _confirmDelete(context, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context,
      VisionBoardController controller, AppTheme appTheme) {
    return Obx(() => PopupMenuButton<String>(
          icon: Icon(
            controller.isNotificationActive(item.id)
                ? FontAwesomeIcons.solidBell
                : FontAwesomeIcons.bell,
            size: ScaleUtil.iconSize(15),
            color: controller.isNotificationActive(item.id)
                ? appTheme.colorScheme.primary
                : null,
          ),
          onSelected: (String value) =>
              _handleNotificationAction(value, controller),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'morning',
              child: Text('At Morning'),
            ),
            PopupMenuItem<String>(
              value: 'night',
              child: Text('At Night'),
            ),
            if (controller.isNotificationActive(item.id))
              PopupMenuItem<String>(
                value: 'cancel',
                child: Text('Cancel Notification'),
              ),
          ],
        ));
  }

  void _handleNotificationAction(
      String action, VisionBoardController controller) {
    switch (action) {
      case 'morning':
        controller.scheduleNotification(item, true);
        break;
      case 'night':
        controller.scheduleNotification(item, false);
        break;
      case 'cancel':
        controller.cancelNotification(item.id);
        break;
    }
  }

  String _getTimeAgo() {
    return timeago.format(item.date, allowFromNow: true);
  }

  void _confirmDelete(BuildContext context, VisionBoardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Vision Board Item'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                controller.deleteItem(item.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ZoomableImageWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ZoomableImageWidget({required this.imageUrls, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
