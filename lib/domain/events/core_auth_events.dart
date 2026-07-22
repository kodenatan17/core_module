/// CoreAuthEvent adalah abstraksi event terkait autentikasi yang didefinisikan
/// di Core Module. Event ini dipublikasikan oleh infrastruktur Core (misalnya,
/// AuthInterceptor) dan dapat didengarkan oleh modul lain (misalnya,
/// Authentication Module atau App Shell) untuk bereaksi terhadap perubahan
/// teknis pada status autentikasi.
///
/// Event ini menjaga Core Module tetap bersih dari business knowledge spesifik
/// Authentication Module, sekaligus menyediakan mekanisme komunikasi yang decoupling.
abstract class CoreAuthEvent {}

/// CoreSessionExpiredEvent mengindikasikan bahwa sesi teknis (misalnya,
/// karena token tidak valid atau kadaluarsa) telah berakhir. Event ini
/// dipublikasikan oleh AuthInterceptor ketika menerima respon 401 Unauthorized
/// yang tidak dapat di-refresh.
class CoreSessionExpiredEvent extends CoreAuthEvent {}

/// CoreTokenRefreshedEvent mengindikasikan bahwa token akses telah berhasil
/// diperbarui oleh AuthInterceptor. Event ini membawa token baru sehingga
/// komponen lain dapat memperbarui status internal mereka jika diperlukan.
class CoreTokenRefreshedEvent extends CoreAuthEvent {
  final String accessToken;
  final String refreshToken;

  CoreTokenRefreshedEvent({required this.accessToken, required this.refreshToken});
}
