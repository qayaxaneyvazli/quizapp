# WebSocket Senkronizasyon Rehberi

Bu rehber, quiz uygulamasında gerçek zamanlı duel senkronizasyonu için WebSocket entegrasyonunu açıklar.

## Genel Bakış

WebSocket entegrasyonu, iki oyuncu arasında gerçek zamanlı senkronizasyon sağlamak için kullanılır:

- **Eşleşme Senkronizasyonu**: Her iki oyuncu da hazır olduğunda oyun başlar
- **Timer Senkronizasyonu**: Her iki cihazda da aynı timer değeri gösterilir
- **Cevap Senkronizasyonu**: Bir oyuncunun verdiği cevap diğer ekranda anında görünür
- **Oyun Durumu Senkronizasyonu**: Oyun durumu her iki cihazda da senkronize kalır

## WebSocket Servisi

### Ana Özellikler

`lib/core/services/websocket_service.dart` dosyasında WebSocket servisi bulunur:

- **Singleton Pattern**: Tek bir WebSocket bağlantısı tüm uygulama için kullanılır
- **Otomatik Yeniden Bağlanma**: Bağlantı koptuğunda otomatik olarak yeniden bağlanır
- **Event Stream**: Tüm WebSocket olayları stream üzerinden yayınlanır

### Temel Metodlar

```dart
// WebSocket bağlantısını başlat
Future<bool> initialize()

// Duel kanalına abone ol
Future<bool> subscribeToDuel(int duelId)

// Hazır sinyali gönder
Future<bool> sendDuelReady(int duelId)

// Cevap gönder
Future<bool> sendAnswer(int duelId, int questionIndex, int selectedOption, double timeTaken)

// Oyun başlatma sinyali gönder
Future<bool> sendGameStart(int duelId)

// Timer senkronizasyonu gönder
Future<bool> sendTimerSync(int duelId, int questionIndex, double remainingTime)
```

## Duel Akışı

### 1. Eşleşme Aşaması

1. **DuelLoadingScreen**: WebSocket bağlantısı kurulur
2. **API Duel Oluşturma**: `DuelService.createDuel()` ile duel oluşturulur
3. **OpponentFoundScreen**: Her iki oyuncu da hazır sinyali gönderir
4. **Senkronizasyon**: Her iki oyuncu da hazır olduğunda oyun başlar

### 2. Oyun Aşaması

1. **DuelScreen**: WebSocket bağlantısı kurulur ve duel kanalına abone olunur
2. **Timer Senkronizasyonu**: Her saniye timer değeri gönderilir
3. **Cevap Senkronizasyonu**: Oyuncu cevap verdiğinde diğer ekranda anında görünür
4. **Oyun Durumu**: Oyun durumu her iki cihazda da senkronize kalır

## Event Tipleri

### Gelen Olaylar

- `duel.ready`: Her iki oyuncu da hazır
- `duel.start`: Oyun başlatma sinyali
- `duel.answer`: Rakip cevap verdi
- `duel.timer_sync`: Timer senkronizasyonu
- `duel.game_state`: Oyun durumu güncellemesi

### Giden Olaylar

- `duel.ready`: Hazır sinyali gönder
- `duel.answer`: Cevap gönder
- `duel.start`: Oyun başlatma sinyali gönder
- `duel.timer_sync`: Timer senkronizasyonu gönder

## Kullanım Örnekleri

### Duel Loading Screen

```dart
// WebSocket bağlantısını başlat
final success = await _webSocketService.initialize();

// Duel kanalına abone ol
await _webSocketService.subscribeToDuel(duelId);

// Hazır sinyali gönder
await _webSocketService.sendDuelReady(duelId);
```

### Duel Screen

```dart
// WebSocket olaylarını dinle
_webSocketSubscription = _webSocketService.eventStream.listen((event) {
  _handleWebSocketEvent(event);
});

// Cevap gönder
await _webSocketService.sendAnswer(duelId, questionIndex, selectedOption, timeTaken);

// Timer senkronizasyonu
await _webSocketService.sendTimerSync(duelId, questionIndex, remainingTime);
```

## Hata Yönetimi

### Bağlantı Sorunları

- **Otomatik Yeniden Bağlanma**: Bağlantı koptuğunda otomatik olarak yeniden bağlanır
- **Fallback Mekanizması**: WebSocket başarısız olursa bot oyununa geçer
- **Timeout Yönetimi**: Belirli süre sonra fallback mekanizması devreye girer

### API Entegrasyonu

- **Dual Submission**: Hem WebSocket hem de API üzerinden cevaplar gönderilir
- **Error Handling**: API hatalarında WebSocket devam eder
- **Cache Management**: Token cache'i ile gereksiz istekler önlenir

## Test Etme

### WebSocket Test Ekranı

`lib/screens/duel/websocket_test.dart` dosyası WebSocket bağlantısını test etmek için kullanılır:

- Bağlantı durumunu gösterir
- Test mesajları gönderir
- Gelen olayları listeler

### Test Senaryoları

1. **İki Emülatör**: İki farklı emülatörde aynı anda duel başlatın
2. **Bot vs Real Player**: Bot oyunu ile gerçek oyuncu oyununu karşılaştırın
3. **Bağlantı Kesme**: Ağ bağlantısını keserek fallback mekanizmasını test edin

## Performans Optimizasyonları

### Timer Senkronizasyonu

- **1 Saniye Aralık**: Timer değeri her saniye gönderilir
- **Progress Bar**: Smooth progress bar için 100ms aralıklarla güncellenir
- **Network Optimization**: Sadece değişiklik olduğunda gönderilir

### Memory Management

- **AutoDispose**: Provider'lar otomatik olarak dispose edilir
- **Stream Cleanup**: WebSocket subscription'ları düzgün şekilde kapatılır
- **Timer Cleanup**: Timer'lar dispose edilirken iptal edilir

## Gelecek Geliştirmeler

### Önerilen İyileştirmeler

1. **Ping/Pong**: Bağlantı durumunu kontrol etmek için ping/pong mekanizması
2. **Message Queue**: Offline durumda mesajları queue'da saklama
3. **Compression**: Büyük mesajlar için compression
4. **Encryption**: Hassas veriler için end-to-end encryption
5. **Load Balancing**: Yüksek trafik için load balancing

### Backend Entegrasyonu

1. **Pusher Integration**: Pusher servisi ile tam entegrasyon
2. **Redis Pub/Sub**: Redis ile pub/sub mekanizması
3. **Database Sync**: Oyun durumunu veritabanında saklama
4. **Analytics**: WebSocket kullanımı için analytics

## Sorun Giderme

### Yaygın Sorunlar

1. **Bağlantı Kurulamıyor**
   - Firebase authentication kontrol edin
   - Backend servisinin çalıştığından emin olun
   - Network bağlantısını kontrol edin

2. **Senkronizasyon Sorunları**
   - Timer değerlerini kontrol edin
   - Event handling'i debug edin
   - WebSocket loglarını inceleyin

3. **Memory Leaks**
   - Stream subscription'ları kontrol edin
   - Timer'ların dispose edildiğinden emin olun
   - Provider'ların autoDispose kullandığından emin olun

### Debug Araçları

- **Console Logs**: WebSocket olayları console'da loglanır
- **Test Screen**: WebSocket test ekranı ile bağlantıyı test edin
- **Network Inspector**: Network trafiğini inceleyin 