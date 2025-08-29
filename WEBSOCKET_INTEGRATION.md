# WebSocket Integration for Duel System

Bu dokümantasyon, quiz uygulamasındaki duel sistemi için WebSocket entegrasyonunu açıklar.

## Genel Bakış

WebSocket entegrasyonu, oyuncuların real-time duel deneyimi yaşaması için Pusher tabanlı bir sistem kullanır. Bu sistem şu özellikleri sağlar:

- Real-time opponent matching
- Live duel updates
- Answer submission tracking
- Score updates
- Duel end notifications

## Teknik Detaylar

### Backend Konfigürasyonu

Backend'den gelen HTML test dosyasına göre:

```javascript
const WS_HOST   = '116.203.188.209';
const WS_PORT   = 6002;
const PUSHER_KEY= 'localkey';
const AUTH_URL  = 'http://116.203.188.209/api/broadcasting/auth';
```

### Flutter Entegrasyonu

#### 1. Paket Bağımlılıkları

`pubspec.yaml` dosyasına eklendi:
```yaml
dependencies:
  pusher_client: ^2.0.0
```

#### 2. WebSocket Service

`lib/core/services/websocket_service.dart` dosyası oluşturuldu:

- **Singleton Pattern**: Tek bir WebSocket bağlantısı yönetimi
- **Authentication**: Firebase token ile backend authentication
- **Event Handling**: Duel-specific event'leri dinleme
- **Connection Management**: Bağlantı durumu yönetimi

#### 3. Duel Screen Entegrasyonu

`lib/screens/duel/duel.dart` dosyasına eklendi:

- **WebSocket Initialization**: Duel başladığında otomatik bağlantı
- **Event Listening**: Real-time event'leri dinleme
- **Answer Handling**: Rakip cevaplarını işleme
- **Resource Cleanup**: Dispose'da bağlantı temizleme

## Event Types

WebSocket sistemi şu event'leri destekler:

### Presence Events
- `pusher:subscription_succeeded`: Kanal aboneliği başarılı
- `pusher:member_added`: Yeni üye katıldı
- `pusher:member_removed`: Üye ayrıldı

### Duel Events
- ``: Duel eşleşmesi bulundu
- `duel.started`: Duel başladı
- `duel.answer_submitted`: Cevap gönderildi
- `duel.score_updated`: Skor güncellendi
- `duel.ended`: Duel bitti

## Kullanım

### 1. Duel Başlatma

```dart
// Duel screen'de otomatik olarak çalışır
@override
void initState() {
  super.initState();
  if (widget.duelResponse != null) {
    _initializeWebSocket();
  }
}
```

### 2. Event Dinleme

```dart
_webSocketSubscription = _webSocketService.eventStream.listen((event) {
  _handleWebSocketEvent(event);
});
```

### 3. Event İşleme

```dart
void _handleWebSocketEvent(Map<String, dynamic> event) {
  final eventType = event['type'] as String?;
  
  switch (eventType) {
    case 'duel.answer_submitted':
      _handleOpponentAnswer(event['data']);
      break;
    case 'duel.score_updated':
      // Update UI with new scores
      break;
  }
}
```

## Test Etme

### WebSocket Test Screen

`lib/screens/duel/websocket_test.dart` dosyası oluşturuldu:

- Bağlantı durumu gösterimi
- Event log'ları
- Manuel test butonları
- Real-time event monitoring

### Test Senaryoları

1. **Bağlantı Testi**: WebSocket bağlantısının kurulması
2. **Authentication Testi**: Firebase token ile backend auth
3. **Duel Subscription Testi**: Belirli duel ID'lerine abone olma
4. **Event Reception Testi**: Backend'den gelen event'leri alma

## Hata Yönetimi

### Bağlantı Hataları
- Network bağlantısı kontrolü
- Authentication token yenileme
- Otomatik yeniden bağlanma

### Event Hataları
- Event parsing hataları
- Unknown event handling
- Graceful degradation

## Güvenlik

### Authentication
- Firebase ID token kullanımı
- Backend session token caching
- Token expiration handling

### Channel Security
- Presence channel kullanımı
- User-specific channel subscription
- Authorization header'ları

## Performans

### Optimizasyonlar
- Singleton pattern ile tek bağlantı
- Event stream caching
- Memory leak prevention
- Resource cleanup

### Monitoring
- Connection state tracking
- Event frequency monitoring
- Error rate tracking

## Gelecek Geliştirmeler

### Planlanan Özellikler
1. **Reconnection Logic**: Otomatik yeniden bağlanma
2. **Event Batching**: Çoklu event'leri batch halinde işleme
3. **Offline Support**: Offline durumda event caching
4. **Analytics**: WebSocket kullanım analitikleri

### Backend Entegrasyonu
1. **Custom Events**: Uygulama-specific event'ler
2. **Push Notifications**: WebSocket + FCM entegrasyonu
3. **Multiplayer Support**: Çoklu oyuncu desteği

## Sorun Giderme

### Yaygın Sorunlar

1. **Bağlantı Kurulamıyor**
   - Network bağlantısını kontrol edin
   - Firebase authentication durumunu kontrol edin
   - Backend servis durumunu kontrol edin

2. **Event Alınamıyor**
   - Channel subscription durumunu kontrol edin
   - Event binding'lerini kontrol edin
   - Backend event broadcasting'ini kontrol edin

3. **Authentication Hatası**
   - Firebase token'ın geçerli olduğunu kontrol edin
   - Backend auth endpoint'ini kontrol edin
   - Token cache'ini temizleyin

### Debug Logları

WebSocket servisi detaylı log'lar üretir:
- `🔌` WebSocket bağlantı işlemleri
- `📡` Event alım/gönderim
- `✅` Başarılı işlemler
- `❌` Hatalar

## Örnek Kullanım

```dart
// Duel screen'de WebSocket kullanımı
class DuelScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    final success = await _webSocketService.initialize();
    if (success) {
      await _webSocketService.subscribeToDuel(duelId);
      _webSocketSubscription = _webSocketService.eventStream.listen(_handleEvent);
    }
  }

  void _handleEvent(Map<String, dynamic> event) {
    // Event handling logic
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _webSocketService.unsubscribeFromDuel();
    super.dispose();
  }
}
```

Bu entegrasyon sayesinde oyuncular real-time duel deneyimi yaşayabilir ve rakibin cevaplarını anında görebilir. 