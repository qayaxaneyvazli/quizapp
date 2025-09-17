class DuelPlayerMapping {
  final int localPlayerId;    // 1 veya 2 (local)
  final int backendPlayerId;  // Backend'den gelen gerçek ID
  final bool isCurrentUser;   // Bu kullanıcı mı?
  
  DuelPlayerMapping({
    required this.localPlayerId,
    required this.backendPlayerId,
    required this.isCurrentUser,
  });
}

class DuelMappingHelper {
  static Map<int?, int?> _backendToLocal = {};
  static Map<int, int?> _localToBackend = {};
  static int? _currentUserBackendId;
  
  // Mapping'i initialize et
  static void initializeMapping({
    required int currentUserBackendId,
    required int? opponentBackendId,
  }) {
    _currentUserBackendId = currentUserBackendId;
    
    // Current user = local player 1
    _backendToLocal[currentUserBackendId] = 1;
    _localToBackend[1] = currentUserBackendId;
    
    // Opponent = local player 2  
    _backendToLocal[opponentBackendId] = 2;
    _localToBackend[2] = opponentBackendId;
    
    print('🎮 Mapping initialized:');
    print('   Current user: $currentUserBackendId -> 1');
    print('   Opponent: $opponentBackendId -> 2');
  }
  
  // Backend ID'den local ID'ye çevir
  static int? backendToLocal(int backendId) {
    return _backendToLocal[backendId];
  }
  
  // Local ID'den backend ID'ye çevir  
  static int? localToBackend(int localId) {
    return _localToBackend[localId];
  }
  
  // Bu backend ID current user'a ait mi?
  static bool isCurrentUser(int backendId) {
    return backendId == _currentUserBackendId;
  }
  
  // Clear mapping (duel bittiğinde)
  static void clearMapping() {
    _backendToLocal.clear();
    _localToBackend.clear();
    _currentUserBackendId = null;
  }
}