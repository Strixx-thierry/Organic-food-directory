import 'package:flutter_test/flutter_test.dart';
import 'package:organic_food_directory/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates a user with all the expected fields', () {
      final map = {
        'uid': 'user_abc',
        'name': 'Kevin Mwangi',
        'email': 'kevin@example.com',
        'isEmailVerified': true,
        'notificationCount': 2,
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'user_abc');
      expect(user.name, 'Kevin Mwangi');
      expect(user.isEmailVerified, isTrue);
      expect(user.notificationCount, 2);
    });

    test('copyWith updates a field without changing the rest', () {
      const user = UserModel(
        uid: 'user_abc',
        name: 'Kevin',
        email: 'kevin@example.com',
      );

      final updated = user.copyWith(name: 'Kevin Updated');

      expect(updated.name, 'Kevin Updated');
      expect(updated.uid, 'user_abc');
      expect(updated.email, 'kevin@example.com');
    });
  });
}
