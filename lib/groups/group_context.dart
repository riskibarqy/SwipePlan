import 'package:flutter/foundation.dart';

class GroupContext extends ChangeNotifier {
  String? _activeGroupId;

  String? get activeGroupId => _activeGroupId;

  void setActiveGroup(String? groupId) {
    if (_activeGroupId == groupId) return;
    _activeGroupId = groupId;
    notifyListeners();
  }
}
