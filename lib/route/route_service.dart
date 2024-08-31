import 'dart:developer';

import 'package:go_router/go_router.dart';
import 'package:hello_world_mvp/chat/model/room/room.dart';
import 'package:hello_world_mvp/chat/view/chat_screen_reopened.dart';

import '../auth/view/login_screen.dart';
import '../chat/service/recent_room_service.dart';
import '../chat/view/chat_screen.dart';
import '../home_screen.dart';
import '../locale/first_launch_screen.dart';
import '../resume/resume_screen.dart';
import 'check_initialization.dart';

int selectedBottomNavIndex = 0;

List<String> bottomNavItems = [
  '/home',
  '/chat',
  '/profile',
];

class RouteService {
  final Future<bool> isUserLoggedIn;
  String? _recentRoomId;
  final RecentRoomService _recentRoomService;

  RouteService(
    this._recentRoomService, {
    required this.isUserLoggedIn,
  });

  String? get recentRoomId => _recentRoomId;

  Future<List<String>> getRoutes() async {
    Room temp = await _recentRoomService.fetchRecentChatRoom();
    _recentRoomId = temp.roomId;

    final recentRoomIdPath =
        _recentRoomId != null ? '/chat/${_recentRoomId!}' : '/new_chat';
    return [
      recentRoomIdPath, // This will include the recent roomId
      '/callbot',
      '/resume',
      '/job',
    ];
  }

  GoRouter get router {
    return GoRouter(
      redirect: (context, state) async {
        final firstLaunch = await CheckInitialization.performInitialization();
        log("[RouteService] firstLaunch: $firstLaunch");

        var loggedIn = await isUserLoggedIn;
        loggedIn = true; // 테스트용으로 강제 로그인 상태

        final isLoggingIn = state.matchedLocation == '/login';
        final isFirstLaunch = state.matchedLocation == '/firstLaunch';

        if (!loggedIn && !isLoggingIn) {
          return '/login';
        } else if (firstLaunch && !isFirstLaunch) {
          return '/firstLaunch';
        } else {
          return null; // 현재 경로 유지
        }
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(), // 기본 홈 화면
        ),
        GoRoute(
          path: '/firstLaunch',
          builder: (context, state) => const FirstLaunchScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/chat/:roomId',
          builder: (context, state) {
            final roomId = state.pathParameters['roomId'] ?? 'new_chat';
            log("[RouteService] Navigate to /chat/$roomId");
            return ChatScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: '/resume',
          builder: (context, state) => const ResumeScreen(),
        ),
        GoRoute(
          path:
              '/reopenedChat/:roomId', // Capture roomId directly from the path
          builder: (context, state) {
            final roomId = state
                .pathParameters['roomId']; // Access roomId from path parameters
            log("[RouteService] Navigate to /reopenedChat/$roomId");
            return const ChatScreenReopened(); // Pass roomId to ChatScreenReopened
          },
          routes: const [],
        ),
        // 다른 라우트 정의...
      ],
    );
  }

  void navigateToChatRoom(String roomId) {
    router.go('/reopenedChat/room/$roomId');
  }
}
