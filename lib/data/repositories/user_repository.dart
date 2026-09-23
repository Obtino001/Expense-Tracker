import '../mock/mock_data.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository();

  Future<UserModel> getUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockData.user;
  }

  Future<List<NotificationModel>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return MockData.notifications;
  }

  Future<void> markRead(String id) async {
    final int i =
        MockData.notifications.indexWhere((NotificationModel n) => n.id == id);
    if (i != -1) {
      MockData.notifications[i] =
          MockData.notifications[i].copyWith(isRead: true);
    }
  }
}
