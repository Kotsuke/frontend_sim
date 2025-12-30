class ApiConfig {
  // Ganti dengan IP lokal laptop jika pakai Emulator (10.0.2.2) 
  // atau IP LAN jika pakai HP fisik (misal 192.168.1.x)
  static const String baseUrl = 'https://unexchangeable-unstern-robt.ngrok-free.dev';
  // static const String baseUrl = 'http://10.0.2.2:5000'; 

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
}
