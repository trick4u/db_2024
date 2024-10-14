
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


import '../projectController/vision_board_controller.dart';
import '../services/app_theme.dart';
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
        enlargeCenterPage: true,
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
      padding: ScaleUtil.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: ScaleUtil.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildNotificationButton(context, controller, appTheme),
                    ScaleUtil.sizedBox(width: 2),
                    if (controller.canEditItem(item.id))
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.penToSquare,
                          size: ScaleUtil.iconSize(15),
                        ),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trashCan,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(context, controller),
                ),
              ],
            ),
          ),
          ScaleUtil.sizedBox(height: 8),
          Padding(
            padding: ScaleUtil.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => controller.toggleItemExpansion(item.id),
              child: Obx(() => AnimatedCrossFade(
                    firstChild: Text(
                      item.title,
                      style: appTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      item.title,
                      style: appTheme.bodyMedium,
                    ),
                    crossFadeState: controller.isItemExpanded(item.id)
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 300),
                  )),
            ),
          ),
          ScaleUtil.sizedBox(height: 4),
          Padding(
            padding: ScaleUtil.symmetric(horizontal: 16),
            child: Text(
              _getTimeAgo(),
              style: appTheme.bodyMedium
                  .copyWith(color: appTheme.secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildNotificationButton(BuildContext context,
    VisionBoardController controller, AppTheme appTheme) {
  return Obx(() {
    if (!controller.canScheduleAnyNotification() &&
        !controller.isNotificationActive(item.id)) {
      return SizedBox.shrink();
    }

    Widget notificationIcon;
    if (controller.isNotificationActive(item.id)) {
      if (item.notificationTime == 'morning') {
        notificationIcon = Icon(
          Icons.wb_sunny,
          size: ScaleUtil.iconSize(15),
          color: Colors.orange,
        );
      } else {
        notificationIcon = Icon(
          Icons.nightlight_round,
          size: ScaleUtil.iconSize(15),
          color: Colors.indigo,
        );
      }
    } else {
      notificationIcon = Icon(
        FontAwesomeIcons.bell,
        size: ScaleUtil.iconSize(15),
      );
    }

    return PopupMenuButton<String>(
      icon: notificationIcon,
      onSelected: (String value) =>
          _handleNotificationAction(value, controller),
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> menuItems = [];

        if (controller.isNotificationActive(item.id)) {
          // If a notification is active, only show the cancel option
          menuItems.add(PopupMenuItem<String>(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 8),
                Text('cancel Notification'),
              ],
            ),
          ));
        } else {
          // If no notification is active, show options to schedule
          if (controller.canScheduleMorningNotification()) {
            menuItems.add(PopupMenuItem<String>(
              value: 'morning',
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('at morning'),
                ],
              ),
            ));
          }

          if (controller.canScheduleNightNotification()) {
            menuItems.add(PopupMenuItem<String>(
              value: 'night',
              child: Row(
                children: [
                  Icon(Icons.nightlight_round, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text('at night'),
                ],
              ),
            ));
          }
        }

        return menuItems;
      },
    );
  });
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
          title: Text('delete vision board item'),
          content: Text('are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('delete'),
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
