import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'chat/model/room/room.dart';
import 'chat/service/recent_room_service.dart';
import 'locale/locale_provider.dart';
import 'route/route_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _recentRoomId = 'new_chat'; // Store the recent room ID

  final RecentRoomService _recentRoomService = RecentRoomService(
    baseUrl: 'http://15.165.84.103:8082/chat/recent-room',
    userId: '1',
  );

  List<String> _getImages() {
    return [
      'assets/images/home_chat.png',
      'assets/images/home_callbot.png',
      'assets/images/home_resume.png',
      'assets/images/home_job.png',
    ];
  }

  Future<List<String>> _getRoutes() async {
    _recentRoomId = _recentRoomId == 'new_chat'
        ? await _recentRoomService
            .fetchRecentChatRoom()
            .then((value) => value.roomId)
        : _recentRoomId;
    log("[HomeScreen-GetRoutes] Recent room ID: $_recentRoomId");

    return [
      '/chat/$_recentRoomId', // Updated to include roomId
      '/callbot',
      '/resume',
      '/job',
    ];
  }

  Future<void> fetchRecentRoomId() async {
    try {
      Room? temp = await _recentRoomService.fetchRecentChatRoom();
      _recentRoomId = temp.roomId ?? 'new_chat';
    } catch (e) {
      print('Error fetching recent room ID: $e');
    }
  }

  String _getTextForIndex(int index, BuildContext context) {
    switch (index) {
      case 0:
        return 'chat_consultation'.tr();
      case 1:
        return 'call_bot'.tr();
      case 2:
        return 'resume_writing'.tr();
      case 3:
        return 'job_information'.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final currentLocale = localeProvider.locale ?? context.locale;

        final paddingVal = MediaQuery.of(context).size.height * 0.1;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.all(paddingVal / 1.3),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "app_name",
                        style: TextStyle(
                          fontSize: 28 * paddingVal / 100,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                      Text(
                        "Hello World",
                        style: TextStyle(
                          fontSize: 28 * paddingVal / 100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(bottom: 16 * paddingVal / 100),
                  child: SizedBox(
                    width: 250.0 * paddingVal / 100, // Width of the image
                    height: 300.0 * paddingVal / 100, // Height of the image
                    child: Image.asset(
                      'assets/images/hello_world_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _getRoutes(), // Fetch the routes asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final routes = snapshot.data!;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0 * paddingVal / 50,
                            mainAxisSpacing: 8.0 * paddingVal / 50,
                            childAspectRatio:
                                1.2, // Aspect ratio for grid items
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            String assetName = _getImages()[index];
                            String route = routes[index];
                            String text = _getTextForIndex(index, context);

                            return GestureDetector(
                              onTap: () {
                                if (index == 1) {
                                  selectedBottomNavIndex = 1;
                                }
                                context.push(
                                    route); // Navigate to the route when tapped
                                log("[HomeScreen] Navigating to $route");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFB2B2F0).withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB2B2F0)
                                          .withOpacity(0.08),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                            8.0 * paddingVal / 100),
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0 * paddingVal / 100,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment
                                              .bottomRight, // Align image to bottom-right
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8.0 * paddingVal / 100),
                                            child: Image.asset(
                                              assetName,
                                              width: 100.0 *
                                                  paddingVal /
                                                  100, // Set to desired width
                                              height: 100.0 *
                                                  paddingVal /
                                                  100, // Set to desired height
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                            child: Text('No routes available.'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
