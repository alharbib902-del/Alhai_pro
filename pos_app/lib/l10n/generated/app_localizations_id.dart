// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Sistem POS';

  @override
  String get login => 'Masuk';

  @override
  String get logout => 'Keluar';

  @override
  String get welcome => 'Selamat Datang';

  @override
  String get welcomeBack => 'Selamat Datang Kembali';

  @override
  String get phone => 'Nomor Telepon';

  @override
  String get phoneHint => '08xxxxxxxxxx';

  @override
  String get phoneRequired => 'Nomor telepon wajib diisi';

  @override
  String get phoneInvalid => 'Nomor telepon tidak valid';

  @override
  String get otp => 'Kode Verifikasi';

  @override
  String get otpHint => 'Masukkan kode verifikasi';

  @override
  String get otpSent => 'Kode verifikasi terkirim';

  @override
  String get otpResend => 'Kirim ulang kode';

  @override
  String get otpExpired => 'Kode verifikasi kedaluwarsa';

  @override
  String get otpInvalid => 'Kode verifikasi tidak valid';

  @override
  String otpResendIn(int seconds) {
    return 'Kirim ulang dalam $seconds detik';
  }

  @override
  String get pin => 'Kode PIN';

  @override
  String get pinHint => 'Masukkan kode PIN';

  @override
  String get pinRequired => 'Kode PIN wajib diisi';

  @override
  String get pinInvalid => 'Kode PIN tidak valid';

  @override
  String pinAttemptsRemaining(int count) {
    return 'Sisa percobaan: $count';
  }

  @override
  String pinLocked(int minutes) {
    return 'Akun terkunci. Coba lagi setelah $minutes menit';
  }

  @override
  String get home => 'Beranda';

  @override
  String get dashboard => 'Dasbor';

  @override
  String get pos => 'Titik Penjualan';

  @override
  String get products => 'Produk';

  @override
  String get categories => 'Kategori';

  @override
  String get inventory => 'Inventaris';

  @override
  String get customers => 'Pelanggan';

  @override
  String get orders => 'Pesanan';

  @override
  String get invoices => 'Faktur';

  @override
  String get reports => 'Laporan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get sales => 'Penjualan';

  @override
  String get salesAnalytics => 'Analisis Penjualan';

  @override
  String get refund => 'Pengembalian';

  @override
  String get todaySales => 'Penjualan Hari Ini';

  @override
  String get totalSales => 'Total Penjualan';

  @override
  String get averageSale => 'Rata-rata Penjualan';

  @override
  String get cart => 'Keranjang';

  @override
  String get cartEmpty => 'Keranjang kosong';

  @override
  String get addToCart => 'Tambah ke Keranjang';

  @override
  String get removeFromCart => 'Hapus dari Keranjang';

  @override
  String get clearCart => 'Kosongkan Keranjang';

  @override
  String get checkout => 'Checkout';

  @override
  String get payment => 'Pembayaran';

  @override
  String get paymentMethod => 'Metode Pembayaran';

  @override
  String get cash => 'Tunai';

  @override
  String get card => 'Kartu';

  @override
  String get credit => 'Kredit';

  @override
  String get transfer => 'Transfer';

  @override
  String get paymentSuccess => 'Pembayaran berhasil';

  @override
  String get paymentFailed => 'Pembayaran gagal';

  @override
  String get price => 'Harga';

  @override
  String get quantity => 'Jumlah';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Diskon';

  @override
  String get tax => 'Pajak';

  @override
  String get vat => 'PPN';

  @override
  String get grandTotal => 'Total Keseluruhan';

  @override
  String get product => 'Produk';

  @override
  String get productName => 'Nama Produk';

  @override
  String get productCode => 'Kode Produk';

  @override
  String get barcode => 'Barcode';

  @override
  String get sku => 'SKU';

  @override
  String get stock => 'Stok';

  @override
  String get lowStock => 'Stok Rendah';

  @override
  String get outOfStock => 'Stok Habis';

  @override
  String get inStock => 'Tersedia';

  @override
  String get customer => 'Pelanggan';

  @override
  String get customerName => 'Nama Pelanggan';

  @override
  String get customerPhone => 'Telepon Pelanggan';

  @override
  String get debt => 'Hutang';

  @override
  String get balance => 'Saldo';

  @override
  String get search => 'Cari';

  @override
  String get searchHint => 'Cari di sini...';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Urutkan';

  @override
  String get all => 'Semua';

  @override
  String get add => 'Tambah';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Hapus';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get next => 'Selanjutnya';

  @override
  String get done => 'Selesai';

  @override
  String get submit => 'Kirim';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get loading => 'Memuat...';

  @override
  String get noData => 'Tidak ada data';

  @override
  String get noResults => 'Tidak ada hasil';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'Terjadi kesalahan';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get connectionError => 'Kesalahan koneksi';

  @override
  String get noInternet => 'Tidak ada koneksi internet';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get success => 'Berhasil';

  @override
  String get warning => 'Peringatan';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get today => 'Hari Ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get thisWeek => 'Minggu Ini';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get shift => 'Shift';

  @override
  String get openShift => 'Buka Shift';

  @override
  String get closeShift => 'Tutup Shift';

  @override
  String get shiftSummary => 'Ringkasan Shift';

  @override
  String get cashDrawer => 'Laci Uang';

  @override
  String get receipt => 'Struk';

  @override
  String get printReceipt => 'Cetak Struk';

  @override
  String get shareReceipt => 'Bagikan Struk';

  @override
  String get sync => 'Sinkronisasi';

  @override
  String get syncing => 'Menyinkronkan...';

  @override
  String get syncComplete => 'Sinkronisasi selesai';

  @override
  String get syncFailed => 'Sinkronisasi gagal';

  @override
  String get lastSync => 'Sinkronisasi terakhir';

  @override
  String get language => 'Bahasa';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get urdu => 'اردو';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get filipino => 'Filipino';

  @override
  String get bengali => 'বাংলা';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get systemMode => 'Mode Sistem';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get security => 'Keamanan';

  @override
  String get printer => 'Printer';

  @override
  String get backup => 'Cadangan';

  @override
  String get help => 'Bantuan';

  @override
  String get about => 'Tentang';

  @override
  String get version => 'Versi';

  @override
  String get copyright => 'Hak cipta dilindungi';

  @override
  String get deleteConfirmTitle => 'Konfirmasi Hapus';

  @override
  String get deleteConfirmMessage => 'Apakah Anda yakin ingin menghapus?';

  @override
  String get logoutConfirmTitle => 'Konfirmasi Keluar';

  @override
  String get logoutConfirmMessage => 'Apakah Anda yakin ingin keluar?';

  @override
  String get requiredField => 'Bidang ini wajib diisi';

  @override
  String get invalidFormat => 'Format tidak valid';

  @override
  String minLength(int min) {
    return 'Minimal $min karakter';
  }

  @override
  String maxLength(int max) {
    return 'Maksimal $max karakter';
  }

  @override
  String get welcomeTitle => 'Selamat Datang Kembali! 👋';

  @override
  String get welcomeSubtitle =>
      'Masuk untuk mengelola toko Anda dengan mudah dan cepat';

  @override
  String get welcomeSubtitleShort => 'Masuk untuk mengelola toko Anda';

  @override
  String get brandName => 'Al-Hal POS';

  @override
  String get brandTagline => 'Sistem Point of Sale Cerdas';

  @override
  String get enterPhoneToContinue => 'Masukkan nomor telepon untuk melanjutkan';

  @override
  String get pleaseEnterValidPhone => 'Masukkan nomor telepon yang valid';

  @override
  String get otpSentViaWhatsApp => 'Kode verifikasi dikirim via WhatsApp';

  @override
  String get otpResent => 'Kode verifikasi dikirim ulang';

  @override
  String get enterOtpFully => 'Masukkan kode verifikasi lengkap';

  @override
  String get maxAttemptsReached => 'Batas percobaan tercapai. Minta kode baru';

  @override
  String waitMinutes(int minutes) {
    return 'Batas percobaan tercapai. Tunggu $minutes menit';
  }

  @override
  String waitSeconds(int seconds) {
    return 'Harap tunggu $seconds detik';
  }

  @override
  String resendIn(String time) {
    return 'Kirim ulang ($time)';
  }

  @override
  String get resendCode => 'Kirim ulang kode';

  @override
  String get changeNumber => 'Ubah nomor';

  @override
  String get verificationCode => 'Kode Verifikasi';

  @override
  String remainingAttempts(int count) {
    return 'Sisa percobaan: $count';
  }

  @override
  String get technicalSupport => 'Dukungan Teknis';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsAndConditions => 'Syarat dan Ketentuan';

  @override
  String get allRightsReserved => '© 2026 Al-Hal System. Hak cipta dilindungi.';

  @override
  String get dayMode => 'Mode Siang';

  @override
  String get nightMode => 'Mode Malam';

  @override
  String get selectBranch => 'Pilih Cabang';

  @override
  String get selectBranchDesc => 'Pilih cabang yang ingin Anda kelola';

  @override
  String get availableBranches => 'Cabang Tersedia';

  @override
  String branchCount(int count) {
    return '$count cabang';
  }

  @override
  String branchSelected(String name) {
    return 'Dipilih $name';
  }

  @override
  String get addBranch => 'Tambah Cabang Baru';

  @override
  String get comingSoon => 'Fitur ini segera hadir';

  @override
  String get tryDifferentSearch => 'Coba kata pencarian lain';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get languageChangeInfo =>
      'Pilih bahasa tampilan pilihan Anda. Perubahan akan diterapkan segera.';

  @override
  String get centralManagement => 'Manajemen Terpusat';

  @override
  String get centralManagementDesc =>
      'Kontrol semua cabang dan gudang Anda dari satu tempat. Dapatkan laporan instan dan sinkronisasi inventaris di semua titik POS.';

  @override
  String get selectBranchToContinue => 'Pilih Cabang untuk Melanjutkan';

  @override
  String get youHaveAccessToBranches =>
      'Anda memiliki akses ke cabang-cabang berikut. Pilih salah satu untuk memulai.';

  @override
  String get searchForBranch => 'Cari cabang...';

  @override
  String get openNow => 'Buka Sekarang';

  @override
  String closedOpensAt(String time) {
    return 'Tutup (Buka $time)';
  }

  @override
  String get loggedInAs => 'Masuk sebagai';

  @override
  String get support247 => 'Dukungan 24/7';

  @override
  String get analyticsTools => 'Alat Analitik';

  @override
  String get uptime => 'Uptime';

  @override
  String get dashboardTitle => 'Dasbor';

  @override
  String get searchPlaceholder => 'Pencarian umum...';

  @override
  String get mainBranch => 'Cabang Utama (Riyadh)';

  @override
  String get todaySalesLabel => 'Penjualan Hari Ini';

  @override
  String get ordersCountLabel => 'Jumlah Pesanan';

  @override
  String get newCustomersLabel => 'Pelanggan Baru';

  @override
  String get stockAlertsLabel => 'Peringatan Stok';

  @override
  String get productsUnit => 'produk';

  @override
  String get salesAnalysis => 'Analisis Penjualan';

  @override
  String get storePerformance => 'Kinerja toko minggu ini';

  @override
  String get weekly => 'Mingguan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get yearly => 'Tahunan';

  @override
  String get quickAction => 'Aksi Cepat';

  @override
  String get newSale => 'Penjualan Baru';

  @override
  String get addProduct => 'Tambah Produk';

  @override
  String get returnItem => 'Pengembalian';

  @override
  String get dailyReport => 'Laporan Harian';

  @override
  String get closeDay => 'Tutup Hari';

  @override
  String get topSelling => 'Terlaris';

  @override
  String ordersToday(int count) {
    return '$count pesanan hari ini';
  }

  @override
  String get recentTransactions => 'Transaksi Terbaru';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get orderNumber => 'Pesanan #';

  @override
  String get time => 'Waktu';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Jumlah';

  @override
  String get action => 'Aksi';

  @override
  String get completed => 'Selesai';

  @override
  String get returned => 'Dikembalikan';

  @override
  String get pending => 'Tertunda';

  @override
  String get cancelled => 'Dibatalkan';

  @override
  String get guestCustomer => 'Pelanggan Tamu';

  @override
  String minutesAgo(int count) {
    return '$count menit yang lalu';
  }

  @override
  String get posSystem => 'Sistem Point of Sale';

  @override
  String get branchManager => 'Manajer Cabang';

  @override
  String get settingsSection => 'Pengaturan';

  @override
  String get systemSettings => 'Pengaturan Sistem';

  @override
  String get sar => 'SAR';

  @override
  String get daily => 'Harian';

  @override
  String get goodMorning => 'Selamat Pagi';

  @override
  String get goodEvening => 'Selamat Malam';

  @override
  String get cashCustomer => 'Pelanggan Tunai';

  @override
  String get noTransactionsToday => 'Tidak ada transaksi hari ini';

  @override
  String get comparedToYesterday => 'Dibandingkan kemarin';

  @override
  String get ordersText => 'pesanan hari ini';

  @override
  String get storeManagement => 'Manajemen Toko';

  @override
  String get finance => 'Keuangan';

  @override
  String get teamSection => 'Tim';

  @override
  String get fullscreen => 'Layar Penuh';

  @override
  String goodMorningName(String name) {
    return 'Selamat Pagi, $name!';
  }

  @override
  String goodEveningName(String name) {
    return 'Selamat Malam, $name!';
  }
}
