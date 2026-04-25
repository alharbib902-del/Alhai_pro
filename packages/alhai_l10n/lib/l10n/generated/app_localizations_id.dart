// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get vatNumberMissing => 'VAT number not configured';

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
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

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
  String pageNotFoundPath(String path) {
    return 'Page not found: $path';
  }

  @override
  String get noInvoiceDataAvailable => 'No invoice data available';

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
  String confirmDeleteItemMessage(String name) {
    return 'Hapus \"$name\"?\nTindakan ini tidak dapat dibatalkan.';
  }

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cabang',
      zero: 'Tidak ada cabang',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pesanan hari ini',
      zero: 'Tidak ada pesanan hari ini',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit yang lalu',
    );
    return '$_temp0';
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

  @override
  String get shoppingCart => 'Keranjang Belanja';

  @override
  String get selectOrSearchCustomer => 'Pilih atau cari pelanggan';

  @override
  String get newCustomer => 'Baru';

  @override
  String get draft => 'Draf';

  @override
  String get pay => 'Bayar';

  @override
  String get haveCoupon => 'Punya kupon diskon?';

  @override
  String discountPercent(String percent) {
    return 'Diskon $percent%';
  }

  @override
  String get openDrawer => 'Buka Laci';

  @override
  String get suspend => 'Tunda';

  @override
  String get quantitySoldOut => 'Stok Habis';

  @override
  String get noProducts => 'Tidak ada produk';

  @override
  String get addProductsToStart => 'Tambahkan produk untuk memulai';

  @override
  String get undoComingSoon => 'Batalkan (segera hadir)';

  @override
  String undoneRemoved(String name) {
    return 'Undone: removed $name';
  }

  @override
  String undoneAdded(String name) {
    return 'Undone: restored $name';
  }

  @override
  String undoneQtyChanged(String name, int from, int to) {
    return 'Undone: $name qty $from → $to';
  }

  @override
  String get nothingToUndo => 'Nothing to undo';

  @override
  String get employees => 'Karyawan';

  @override
  String get loyaltyProgram => 'Program Loyalitas';

  @override
  String get newBadge => 'Baru';

  @override
  String get technicalSupportShort => 'Dukungan Teknis';

  @override
  String get productDetails => 'Detail Produk';

  @override
  String get stockMovements => 'Pergerakan Stok';

  @override
  String get priceHistory => 'Riwayat Harga';

  @override
  String get salesHistory => 'Riwayat Penjualan';

  @override
  String get available => 'Tersedia';

  @override
  String get alertLevel => 'Level Peringatan';

  @override
  String get reorderPoint => 'Titik Pesan Ulang';

  @override
  String get revenue => 'Revenue';

  @override
  String get supplier => 'Pemasok';

  @override
  String get lastSale => 'Penjualan Terakhir';

  @override
  String get printLabel => 'Cetak Label';

  @override
  String get copied => 'Disalin';

  @override
  String copiedToClipboard(String label) {
    return '$label disalin';
  }

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Nonaktif';

  @override
  String get profitMargin => 'Margin Keuntungan';

  @override
  String get sellingPrice => 'Harga Jual';

  @override
  String get costPrice => 'Harga Pokok';

  @override
  String get description => 'Deskripsi';

  @override
  String get noDescription => 'Tidak ada deskripsi';

  @override
  String get productNotFound => 'Produk tidak ditemukan';

  @override
  String get stockStatus => 'Status Stok';

  @override
  String get currentStock => 'Stok Saat Ini';

  @override
  String get unit => 'unit';

  @override
  String get units => 'unit';

  @override
  String get date => 'Tanggal';

  @override
  String get type => 'Jenis';

  @override
  String get reference => 'Referensi';

  @override
  String get newBalance => 'Saldo Baru';

  @override
  String get oldPrice => 'Harga Lama';

  @override
  String get newPrice => 'Harga Baru';

  @override
  String get reason => 'Alasan';

  @override
  String get invoiceNumber => 'No. Faktur';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get uncategorized => 'Tanpa Kategori';

  @override
  String get noSupplier => 'Tidak ada pemasok';

  @override
  String get moreOptions => 'Opsi Lainnya';

  @override
  String get noStockMovements => 'Tidak ada pergerakan stok';

  @override
  String get noPriceHistory => 'Tidak ada riwayat harga';

  @override
  String get noSalesHistory => 'Tidak ada riwayat penjualan';

  @override
  String get sale => 'Penjualan';

  @override
  String get purchase => 'Pembelian';

  @override
  String get adjustment => 'Penyesuaian';

  @override
  String get returnText => 'Pengembalian';

  @override
  String get waste => 'Pemborosan';

  @override
  String get initialStock => 'Stok Awal';

  @override
  String get searchByNameOrBarcode => 'Cari berdasarkan nama atau barcode...';

  @override
  String get hideFilters => 'Sembunyikan Filter';

  @override
  String get showFilters => 'Tampilkan Filter';

  @override
  String get sortByName => 'Nama';

  @override
  String get sortByPrice => 'Harga';

  @override
  String get sortByStock => 'Stok';

  @override
  String get sortByRecent => 'Terbaru';

  @override
  String get allItems => 'Semua';

  @override
  String get clearFilters => 'Hapus Filter';

  @override
  String get noBarcode => 'Tanpa barcode';

  @override
  String stockCount(int count) {
    return 'Stok: $count';
  }

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get addTheProduct => 'Tambah Produk';

  @override
  String get editProduct => 'Edit Produk';

  @override
  String get newProduct => 'Produk Baru';

  @override
  String get minimumQuantity => 'Jumlah Minimum';

  @override
  String get selectCategory => 'Pilih Kategori';

  @override
  String get productImage => 'Gambar Produk';

  @override
  String get trackInventory => 'Lacak Inventaris';

  @override
  String get productSavedSuccess => 'Produk berhasil disimpan';

  @override
  String get productAddedSuccess => 'Produk berhasil ditambahkan';

  @override
  String get deleteProduct => 'Hapus Produk';

  @override
  String deleteProductConfirm(String name) {
    return 'Hapus produk \"$name\"?\nAkan dipindahkan ke arsip dan dapat dipulihkan nanti.';
  }

  @override
  String get productDeletedSuccess => 'Produk berhasil dihapus';

  @override
  String get scanBarcode => 'Pindai Barcode';

  @override
  String get activeProduct => 'Produk Aktif';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jam yang lalu',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari yang lalu',
    );
    return '$_temp0';
  }

  @override
  String get supplierPriceUpdate => 'Pembaruan harga pemasok';

  @override
  String get costIncrease => 'Kenaikan biaya';

  @override
  String get duplicateProduct => 'Duplikat Produk';

  @override
  String get categoriesManagement => 'Manajemen Kategori';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kategori',
      zero: 'Tidak ada kategori',
    );
    return '$_temp0';
  }

  @override
  String get addCategory => 'Tambah Kategori';

  @override
  String get editCategory => 'Edit Kategori';

  @override
  String get deleteCategory => 'Hapus Kategori';

  @override
  String get categoryName => 'Nama Kategori';

  @override
  String get categoryNameAr => 'Nama (Arab)';

  @override
  String get categoryNameEn => 'Nama (Inggris)';

  @override
  String get parentCategory => 'Kategori Induk';

  @override
  String get noParentCategory => 'Tanpa kategori induk (Utama)';

  @override
  String get sortOrder => 'Urutan';

  @override
  String get categoryColor => 'Warna';

  @override
  String get categoryIcon => 'Ikon';

  @override
  String get categoryDetails => 'Detail Kategori';

  @override
  String get categoryCreatedAt => 'Tanggal Dibuat';

  @override
  String get categoryProducts => 'Produk Kategori';

  @override
  String get noCategorySelected => 'Pilih kategori untuk melihat detailnya';

  @override
  String get deleteCategoryConfirm =>
      'Apakah Anda yakin ingin menghapus kategori ini?';

  @override
  String get categoryDeletedSuccess => 'Kategori berhasil dihapus';

  @override
  String get categorySavedSuccess => 'Kategori berhasil disimpan';

  @override
  String get searchCategories => 'Cari kategori...';

  @override
  String get reorderCategories => 'Atur ulang';

  @override
  String get noCategories => 'Tidak ada kategori ditemukan';

  @override
  String get subcategories => 'Sub-kategori';

  @override
  String get activeStatus => 'Aktif';

  @override
  String get inactiveStatus => 'Tidak Aktif';

  @override
  String get invoicesTitle => 'Faktur';

  @override
  String get totalInvoices => 'Total Faktur';

  @override
  String get totalPaid => 'Total Dibayar';

  @override
  String get totalPending => 'Total Tertunda';

  @override
  String get totalOverdue => 'Total Terlambat';

  @override
  String get comparedToLastMonth => 'Dibandingkan bulan lalu';

  @override
  String ofTotalDue(String percent) {
    return '$percent% dari total jatuh tempo';
  }

  @override
  String invoicesWaitingPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faktur menunggu pembayaran',
      zero: 'Tidak ada faktur menunggu',
    );
    return '$_temp0';
  }

  @override
  String get sendReminderNow => 'Kirim Pengingat Sekarang';

  @override
  String get revenueAnalysis => 'Analisis Pendapatan';

  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get thisMonthPeriod => 'Bulan Ini';

  @override
  String get thisYearPeriod => 'Tahun Ini';

  @override
  String get paymentMethods => 'Metode Pembayaran';

  @override
  String get cashPayment => 'Tunai';

  @override
  String get cardPayment => 'Kartu';

  @override
  String get walletPayment => 'Dompet';

  @override
  String get saveCurrentFilter => 'Simpan Filter Saat Ini';

  @override
  String get statusAll => 'Status: Semua';

  @override
  String get statusPaid => 'Dibayar';

  @override
  String get statusPending => 'Tertunda';

  @override
  String get statusOverdue => 'Terlambat';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get resetFilters => 'Reset';

  @override
  String get createInvoice => 'Buat Faktur';

  @override
  String get invoiceNumberCol => 'No. Faktur';

  @override
  String get customerNameCol => 'Nama Pelanggan';

  @override
  String get dateCol => 'Tanggal';

  @override
  String get amountCol => 'Jumlah';

  @override
  String get statusCol => 'Status';

  @override
  String get paymentCol => 'Pembayaran';

  @override
  String get actionsCol => 'Aksi';

  @override
  String get viewInvoice => 'Lihat';

  @override
  String get printInvoice => 'Cetak';

  @override
  String get exportPdf => 'PDF';

  @override
  String get sendWhatsapp => 'WhatsApp';

  @override
  String get deleteInvoice => 'Hapus';

  @override
  String get reminder => 'Pengingat';

  @override
  String get exportAll => 'Ekspor Semua';

  @override
  String get printReport => 'Cetak Laporan';

  @override
  String get more => 'Lainnya';

  @override
  String showingResults(int from, int to, int total) {
    return 'Menampilkan $from hingga $to dari $total hasil';
  }

  @override
  String get newInvoice => 'Faktur Baru';

  @override
  String get selectCustomer => 'Pilih Pelanggan';

  @override
  String get cashCustomerGeneral => 'Pelanggan Tunai (Umum)';

  @override
  String get addNewCustomer => '+ Tambah Pelanggan Baru';

  @override
  String get productsSection => 'Produk';

  @override
  String get addProductToInvoice => '+ Tambah Produk';

  @override
  String get productCol => 'Produk';

  @override
  String get quantityCol => 'Qty';

  @override
  String get priceCol => 'Harga';

  @override
  String get dueDate => 'Tanggal Jatuh Tempo';

  @override
  String get invoiceTotal => 'Total:';

  @override
  String get saveInvoice => 'Simpan Faktur';

  @override
  String get deleteConfirm => 'Apakah Anda yakin?';

  @override
  String get deleteInvoiceMsg =>
      'Apakah Anda benar-benar ingin menghapus faktur ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get yesDelete => 'Ya, Hapus';

  @override
  String get copiedSuccess => 'Berhasil disalin';

  @override
  String get invoiceDeleted => 'Faktur berhasil dihapus';

  @override
  String get sat => 'Sab';

  @override
  String get sun => 'Min';

  @override
  String get mon => 'Sen';

  @override
  String get tue => 'Sel';

  @override
  String get wed => 'Rab';

  @override
  String get thu => 'Kam';

  @override
  String get fri => 'Jum';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      zero: 'Tidak ada yang dipilih',
    );
    return '$_temp0';
  }

  @override
  String get bulkPrint => 'Cetak';

  @override
  String get bulkExportPdf => 'Ekspor PDF';

  @override
  String get allRightsReservedFooter =>
      '© 2026 Alhai POS. Hak cipta dilindungi.';

  @override
  String get privacyPolicyFooter => 'Kebijakan Privasi';

  @override
  String get termsFooter => 'Syarat & Ketentuan';

  @override
  String get supportFooter => 'Dukungan Teknis';

  @override
  String get paid => 'Dibayar';

  @override
  String get overdue => 'Terlambat';

  @override
  String get creditCard => 'Kartu Kredit';

  @override
  String get electronicWallet => 'E-Wallet';

  @override
  String get searchInvoiceHint => 'Cari berdasarkan nomor faktur, pelanggan...';

  @override
  String get customerDetails => 'Detail Pelanggan';

  @override
  String get customerProfileAndTransactions => 'Ikhtisar profil dan transaksi';

  @override
  String get customerDetailTitle => 'Detail Pelanggan';

  @override
  String get totalPurchases => 'Total Pembelian';

  @override
  String get loyaltyPoints => 'Poin Loyalitas';

  @override
  String get lastVisit => 'Kunjungan Terakhir';

  @override
  String get newSaleAction => 'Penjualan Baru';

  @override
  String get editInfo => 'Edit Info';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get blockCustomer => 'Blokir Pelanggan';

  @override
  String get purchasesTab => 'Pembelian';

  @override
  String get accountTab => 'Akun';

  @override
  String get debtsTab => 'Hutang';

  @override
  String get analyticsTab => 'Analitik';

  @override
  String get recentOrdersLog => 'Log Pesanan Terbaru';

  @override
  String get exportCsv => 'Ekspor CSV';

  @override
  String get searchByInvoiceNumber => 'Cari berdasarkan nomor faktur...';

  @override
  String get items => 'Item';

  @override
  String get viewDetails => 'Lihat Detail';

  @override
  String get financialLedger => 'Buku Besar Keuangan';

  @override
  String get cashPaymentEntry => 'Pembayaran Tunai';

  @override
  String get walletTopup => 'Isi Ulang Dompet';

  @override
  String get loyaltyPointsDeduction => 'Potongan Poin Loyalitas';

  @override
  String redeemPoints(int count) {
    return 'Tukar $count poin';
  }

  @override
  String get viewFullLedger => 'Lihat Selengkapnya';

  @override
  String get currentBalance => 'Saldo Saat Ini';

  @override
  String get creditLimit => 'Batas Kredit';

  @override
  String get used => 'Digunakan';

  @override
  String get topUpBalance => 'Isi Ulang Saldo';

  @override
  String get overdueDebt => 'Terlambat';

  @override
  String get upcomingDebt => 'Akan Datang';

  @override
  String get payNow => 'Bayar Sekarang';

  @override
  String get remind => 'Ingatkan';

  @override
  String get monthlySpending => 'Pengeluaran Bulanan';

  @override
  String get purchaseDistribution =>
      'Distribusi Pembelian berdasarkan Kategori';

  @override
  String get last6Months => '6 Bulan Terakhir';

  @override
  String get thisYear => 'Tahun Ini';

  @override
  String get averageOrder => 'Rata-rata Pesanan';

  @override
  String get purchaseFrequency => 'Frekuensi Pembelian';

  @override
  String everyNDays(int count) {
    return 'Setiap $count hari';
  }

  @override
  String get spendingGrowth => 'Pertumbuhan Pengeluaran';

  @override
  String get favoriteProduct => 'Produk Favorit';

  @override
  String get internalNotes => 'Catatan Internal (hanya terlihat oleh staf)';

  @override
  String get addNote => 'Tambah';

  @override
  String get addNewNote => 'Tambahkan catatan baru...';

  @override
  String joinedDate(String date) {
    return 'Bergabung: $date';
  }

  @override
  String lastUpdated(String time) {
    return 'Terakhir diperbarui: $time';
  }

  @override
  String showingOrders(int from, int to, int total) {
    return 'Menampilkan $from-$to dari $total pesanan';
  }

  @override
  String get vegetables => 'Sayuran';

  @override
  String get dairy => 'Susu';

  @override
  String get meat => 'Daging';

  @override
  String get bakery => 'Roti';

  @override
  String get other => 'Lainnya';

  @override
  String get returns => 'Pengembalian';

  @override
  String get salesReturns => 'Retur Penjualan';

  @override
  String get purchaseReturns => 'Retur Pembelian';

  @override
  String get totalReturns => 'Total Pengembalian';

  @override
  String get totalRefundedAmount => 'Total Jumlah Dikembalikan';

  @override
  String get mostReturned => 'Paling Sering Dikembalikan';

  @override
  String get processed => 'Dikembalikan';

  @override
  String get newReturn => 'Retur Baru';

  @override
  String get createNewReturn => 'Buat Retur Baru';

  @override
  String get processReturnRequest => 'Proses permintaan retur penjualan';

  @override
  String get returnNumber => 'Nomor Retur';

  @override
  String get originalInvoice => 'Invoice Asli';

  @override
  String get returnReason => 'Alasan Pengembalian';

  @override
  String get returnAmount => 'Jumlah Pengembalian';

  @override
  String get returnStatus => 'Status';

  @override
  String get returnDate => 'Tanggal';

  @override
  String get returnActions => 'Aksi';

  @override
  String get returnRefunded => 'Dikembalikan';

  @override
  String get returnRejected => 'Ditolak';

  @override
  String get defectiveProduct => 'Produk Rusak';

  @override
  String get wrongProduct => 'Produk Salah';

  @override
  String get customerRequest => 'Permintaan Pelanggan';

  @override
  String get otherReason => 'Lainnya';

  @override
  String get quickSearch => 'Pencarian cepat...';

  @override
  String get exportData => 'Ekspor';

  @override
  String get printData => 'Cetak';

  @override
  String get approve => 'Setujui';

  @override
  String get reject => 'Tolak';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get invoiceStep => 'Invoice';

  @override
  String get itemsStep => 'Item';

  @override
  String get reasonStep => 'Alasan';

  @override
  String get confirmStep => 'Konfirmasi';

  @override
  String get enterInvoiceNumber => 'Nomor Invoice';

  @override
  String get invoiceExample => 'Contoh: #INV-889';

  @override
  String get loadInvoice => 'Muat';

  @override
  String invoiceLoaded(String number) {
    return 'Invoice #$number berhasil dimuat';
  }

  @override
  String invoiceLoadedCustomer(String customer, String date) {
    return 'Pelanggan: $customer | Tanggal: $date';
  }

  @override
  String get selectItemsInfo =>
      'Pilih item yang akan dikembalikan. Tidak bisa mengembalikan lebih dari yang dijual.';

  @override
  String availableToReturn(int count) {
    return 'Tersedia: $count';
  }

  @override
  String get alreadyReturnedFully => 'Jumlah penuh sudah dikembalikan';

  @override
  String get returnReasonLabel => 'Alasan Pengembalian (untuk item terpilih)';

  @override
  String get additionalDetails =>
      'Detail tambahan (diperlukan untuk Lainnya)...';

  @override
  String get confirmReturn => 'Konfirmasi Pengembalian';

  @override
  String get refundAmount => 'Jumlah Refund';

  @override
  String get refundMethod => 'Metode Refund';

  @override
  String get cashRefund => 'Tunai';

  @override
  String get storeCredit => 'Kredit Toko';

  @override
  String get returnCreatedSuccess => 'Retur berhasil dibuat';

  @override
  String get noReturns => 'Tidak Ada Pengembalian';

  @override
  String get noReturnsDesc => 'Belum ada operasi pengembalian yang tercatat.';

  @override
  String timesReturned(int count, int percent) {
    return '$count kali ($percent% dari total)';
  }

  @override
  String get fromInvoice => 'Dari invoice';

  @override
  String get dateFromTo => 'Tanggal dari - sampai';

  @override
  String get returnCopied => 'Nomor berhasil disalin';

  @override
  String ofTotalProcessed(int percent) {
    return '$percent% diproses';
  }

  @override
  String get invoiceDetails => 'Detail Faktur';

  @override
  String invoiceNumberLabel(String number) {
    return 'Nomor:';
  }

  @override
  String get additionalOptions => 'Opsi Tambahan';

  @override
  String get duplicateInvoice => 'Buat Duplikat';

  @override
  String get returnMerchandise => 'Pengembalian Barang';

  @override
  String get voidInvoice => 'Void Faktur';

  @override
  String get printBtn => 'Cetak';

  @override
  String get downloadBtn => 'Unduh';

  @override
  String get paidSuccessfully => 'Pembayaran Berhasil';

  @override
  String get amountReceivedFull => 'Jumlah penuh diterima';

  @override
  String get completedStatus => 'Selesai';

  @override
  String get pendingStatus => 'Tertunda';

  @override
  String get voidedStatus => 'Dibatalkan';

  @override
  String get storeName => 'Supermarket Lingkungan';

  @override
  String get storeAddress => 'Riyadh, Distrik Al-Malaz';

  @override
  String get simplifiedTaxInvoice => 'Faktur Pajak Sederhana';

  @override
  String get dateAndTime => 'Tanggal & Waktu';

  @override
  String get cashierLabel => 'Kasir';

  @override
  String get itemCol => 'Item';

  @override
  String get quantityColDetail => 'Qty';

  @override
  String get priceColDetail => 'Harga';

  @override
  String get totalCol => 'Total';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get discountVip => 'Diskon (Anggota VIP)';

  @override
  String get vatLabel => 'PPN (15%)';

  @override
  String get grandTotalLabel => 'Total Keseluruhan';

  @override
  String get paymentMethodLabel => 'Metode Pembayaran';

  @override
  String get amountPaidLabel => 'Jumlah Dibayar';

  @override
  String get zatcaElectronic => 'ZATCA - Faktur Elektronik';

  @override
  String get scanToVerify => 'Scan untuk verifikasi';

  @override
  String get includesVat15 => 'Termasuk PPN 15%';

  @override
  String get thankYouVisit => 'Terima kasih atas kunjungan Anda!';

  @override
  String get wishNiceDay => 'Semoga hari Anda menyenangkan';

  @override
  String get customerInfo => 'Informasi Pelanggan';

  @override
  String get editBtn => 'Edit';

  @override
  String vipSince(String year) {
    return 'Pelanggan VIP sejak $year';
  }

  @override
  String get activeStatusLabel => 'Aktif';

  @override
  String get callBtn => 'Telepon';

  @override
  String get recordBtn => 'Rekam';

  @override
  String get quickActions => 'Aksi Cepat';

  @override
  String get sendWhatsappAction => 'Kirim WhatsApp';

  @override
  String get sendEmailAction => 'Kirim Email';

  @override
  String get downloadPdfAction => 'Unduh PDF';

  @override
  String get shareLinkAction => 'Bagikan Link';

  @override
  String get eventLog => 'Log Kejadian';

  @override
  String get paymentCompleted => 'Pembayaran Selesai';

  @override
  String get processedViaGateway => 'Diproses melalui payment gateway';

  @override
  String minutesAgoDetail(int count) {
    return '$count menit lalu';
  }

  @override
  String get invoiceCreated => 'Faktur Dibuat';

  @override
  String byUser(String name) {
    return 'Oleh $name';
  }

  @override
  String todayAt(String time) {
    return 'Hari ini, $time';
  }

  @override
  String get orderStarted => 'Pesanan Dimulai';

  @override
  String get cashierSessionOpened => 'Sesi kasir dibuka';

  @override
  String get technicalData => 'Data Teknis';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get terminalLabel => 'Terminal';

  @override
  String get softwareVersion => 'Software V';

  @override
  String get voidInvoiceConfirm => 'Void Faktur?';

  @override
  String get voidInvoiceMsg =>
      'Faktur ini akan dibatalkan secara permanen. Apakah Anda yakin?';

  @override
  String get voidReasonLabel => 'Alasan Void (Wajib)';

  @override
  String get voidReasonEntry => 'Kesalahan Entri';

  @override
  String get voidReasonCustomer => 'Permintaan Pelanggan';

  @override
  String get voidReasonDamaged => 'Produk Rusak';

  @override
  String get voidReasonOther => 'Alasan Lain...';

  @override
  String get confirmVoid => 'Konfirmasi Void';

  @override
  String get invoiceVoided => 'Faktur berhasil di-void';

  @override
  String copiedText(String text) {
    return 'Disalin: $text';
  }

  @override
  String visaEnding(String digits) {
    return 'Visa berakhir $digits';
  }

  @override
  String get mobileActionPrint => 'Cetak';

  @override
  String get mobileActionWhatsapp => 'WhatsApp';

  @override
  String get mobileActionEmail => 'Email';

  @override
  String get mobileActionMore => 'Lainnya';

  @override
  String get sarCurrency => 'SAR';

  @override
  String skuLabel(String code) {
    return 'SKU: $code';
  }

  @override
  String get helpText => 'Bantuan';

  @override
  String get customerLedger => 'Buku Besar Pelanggan';

  @override
  String get accountStatement => 'Laporan Akun';

  @override
  String get allPeriods => 'Semua';

  @override
  String get threeMonths => '3 Bulan';

  @override
  String get allMovements => 'Semua Transaksi';

  @override
  String get adjustments => 'Penyesuaian';

  @override
  String get statementCol => 'Keterangan';

  @override
  String get referenceCol => 'Referensi';

  @override
  String get debitCol => 'Debit';

  @override
  String get creditCol => 'Kredit';

  @override
  String get balanceCol => 'Saldo';

  @override
  String get openingBalance => 'Saldo Awal';

  @override
  String get totalDebit => 'Total Debit';

  @override
  String get totalCredit => 'Total Kredit';

  @override
  String get finalBalance => 'Saldo Akhir';

  @override
  String get manualAdjustment => 'Penyesuaian Manual';

  @override
  String get adjustmentType => 'Jenis Penyesuaian';

  @override
  String get debitAdjustment => 'Penyesuaian Debit';

  @override
  String get creditAdjustment => 'Penyesuaian Kredit';

  @override
  String get adjustmentAmount => 'Jumlah Penyesuaian';

  @override
  String get adjustmentReason => 'Alasan Penyesuaian';

  @override
  String get adjustmentDate => 'Tanggal Penyesuaian';

  @override
  String get saveAdjustment => 'Simpan Penyesuaian';

  @override
  String get adjustmentSaved => 'Penyesuaian berhasil disimpan';

  @override
  String get enterValidAmount => 'Masukkan jumlah yang valid';

  @override
  String get dueOnCustomer => 'Tagihan pelanggan';

  @override
  String get customerHasCredit => 'Pelanggan memiliki saldo kredit';

  @override
  String get noTransactions => 'Tidak ada transaksi';

  @override
  String get recordPaymentBtn => 'Catat Pembayaran';

  @override
  String get returnEntry => 'Pengembalian';

  @override
  String get adjustmentEntry => 'Penyesuaian';

  @override
  String get ordersHistory => 'Riwayat Pesanan';

  @override
  String get totalOrdersLabel => 'Total Pesanan';

  @override
  String get completedOrders => 'Selesai';

  @override
  String get pendingOrders => 'Tertunda';

  @override
  String get cancelledOrders => 'Dibatalkan';

  @override
  String get searchOrderHint =>
      'Cari berdasarkan nomor pesanan, pelanggan, atau telepon...';

  @override
  String get channelLabel => 'Saluran';

  @override
  String get last30Days => '30 hari terakhir';

  @override
  String get orderDetails => 'Detail Pesanan';

  @override
  String get unpaidLabel => 'Belum Dibayar';

  @override
  String get voidTransaction => 'Batalkan Transaksi';

  @override
  String get voidSaleTransaction => 'Batalkan Transaksi Penjualan';

  @override
  String get voidWarningTitle =>
      'Peringatan Penting: Tindakan ini tidak dapat dibatalkan';

  @override
  String get voidWarningDesc =>
      'Membatalkan transaksi ini akan membatalkan invoice sepenuhnya dan mengembalikan semua item ke inventaris.';

  @override
  String get voidWarningShort =>
      'Tindakan ini akan membatalkan invoice sepenuhnya. Tidak dapat dibatalkan.';

  @override
  String get enterInvoiceToVoid => 'Masukkan nomor invoice untuk dibatalkan';

  @override
  String get searchByInvoiceOrBarcode =>
      'Cari dengan nomor invoice atau pemindai barcode';

  @override
  String get invoiceExampleVoid => 'Contoh: #INV-2024-8892';

  @override
  String get activateBarcode => 'Aktifkan pemindai barcode';

  @override
  String get scanBarcodeMobile => 'Pindai barcode';

  @override
  String get searchForInvoiceToVoid => 'Cari invoice untuk dibatalkan';

  @override
  String get enterNumberOrScan =>
      'Masukkan nomor atau gunakan pemindai barcode.';

  @override
  String get salesInvoice => 'Invoice Penjualan';

  @override
  String get invoiceCompleted => 'Selesai';

  @override
  String get paidCash => 'Dibayar: Tunai';

  @override
  String get customerLabel => 'Pelanggan';

  @override
  String get dateAndTimeLabel => 'Tanggal dan Waktu';

  @override
  String get voidImpactSummary => 'Ringkasan Dampak Pembatalan';

  @override
  String voidImpactItemsReturn(int count) {
    return '$count item akan dikembalikan ke inventaris secara otomatis.';
  }

  @override
  String voidImpactRefund(String amount, String currency) {
    return 'Jumlah $amount $currency akan dipotong/dikembalikan.';
  }

  @override
  String returnedItems(int count) {
    return 'Item Dikembalikan ($count)';
  }

  @override
  String get viewAllItems => 'Lihat Semua';

  @override
  String moreItemsHint(int count, String amount, String currency) {
    return '+ $count item lagi (total: $amount $currency)';
  }

  @override
  String get voidReason => 'Alasan Pembatalan';

  @override
  String get voidReasonRequired => 'Alasan Pembatalan *';

  @override
  String get customerRequestReason => 'Permintaan pelanggan';

  @override
  String get wrongItemsReason => 'Item salah';

  @override
  String get duplicateInvoiceReason => 'Invoice duplikat';

  @override
  String get systemErrorReason => 'Kesalahan sistem';

  @override
  String get otherReasonVoid => 'Lainnya';

  @override
  String get additionalNotesVoid => 'Catatan tambahan...';

  @override
  String get additionalDetailsRequired =>
      'Detail tambahan (diperlukan untuk Lainnya)...';

  @override
  String get managerApproval => 'Persetujuan Manajer';

  @override
  String get managerApprovalRequired => 'Persetujuan Manajer Diperlukan';

  @override
  String amountExceedsLimit(String amount, String currency) {
    return 'Jumlah melebihi batas ($amount $currency), masukkan PIN manajer.';
  }

  @override
  String get enterPinCode => 'Masukkan kode PIN';

  @override
  String get pinSentToManager => 'Kode sementara dikirim ke ponsel manajer';

  @override
  String get defaultManagerPin => 'Kode manajer default: 1234';

  @override
  String get confirmVoidAction =>
      'Saya mengkonfirmasi pembatalan transaksi ini';

  @override
  String get confirmVoidDesc =>
      'Saya telah meninjau detail dan bertanggung jawab penuh.';

  @override
  String get cancelAction => 'Batal';

  @override
  String get confirmFinalVoid => 'Konfirmasi Pembatalan Final';

  @override
  String get invoiceNotFound => 'Invoice tidak ditemukan';

  @override
  String get invoiceNotFoundDesc =>
      'Verifikasi nomor yang dimasukkan atau coba gunakan barcode.';

  @override
  String get trySearchAgain => 'Coba cari lagi';

  @override
  String get voidSuccess => 'Transaksi berhasil dibatalkan';

  @override
  String qtyLabel(int count) {
    return 'Jumlah: $count';
  }

  @override
  String get manageCustomersAndAccounts => 'Kelola pelanggan dan akun';

  @override
  String get totalCustomersCount => 'Total Pelanggan';

  @override
  String get outstandingDebts => 'Utang Tertunggak';

  @override
  String get creditBalance => 'Kredit Pelanggan';

  @override
  String get filterByLabel => 'Filter berdasarkan';

  @override
  String get debtors => 'Berutang';

  @override
  String get creditorsLabel => 'Berkredit';

  @override
  String get quickActionsLabel => 'Tindakan Cepat';

  @override
  String get sendDebtReminder => 'Kirim pengingat utang';

  @override
  String get exportAccountStatement => 'Ekspor laporan akun';

  @override
  String cancelSelectionCount(String count) {
    return 'Batalkan pilihan ($count)';
  }

  @override
  String get searchByNameOrPhone =>
      'Cari berdasarkan nama atau telepon... (Ctrl+F)';

  @override
  String get sortByBalance => 'Saldo';

  @override
  String get refreshF5 => 'Segarkan (F5)';

  @override
  String get loadingCustomers => 'Memuat pelanggan...';

  @override
  String get payDebt => 'Bayar Utang';

  @override
  String dueAmountLabel(String amount) {
    return 'Jatuh tempo: $amount SAR';
  }

  @override
  String get paymentAmountLabel => 'Jumlah Pembayaran';

  @override
  String get fullAmount => 'Penuh';

  @override
  String get payAction => 'Bayar';

  @override
  String paymentRecorded(String amount) {
    return 'Pembayaran $amount SAR tercatat';
  }

  @override
  String customerAddedSuccess(String name) {
    return '$name berhasil ditambahkan';
  }

  @override
  String get customerNameRequired => 'Nama Pelanggan *';

  @override
  String get owedLabel => 'Berutang';

  @override
  String get hasBalanceLabel => 'Kredit';

  @override
  String get zeroLabel => 'Nol';

  @override
  String get addAction => 'Tambah';

  @override
  String get expenses => 'Pengeluaran';

  @override
  String get expenseCategories => 'Kategori Pengeluaran';

  @override
  String get addExpense => 'Tambah Pengeluaran';

  @override
  String get totalExpenses => 'Total Pengeluaran';

  @override
  String get thisMonthExpenses => 'Bulan Ini';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNotes => 'Notes';

  @override
  String get noExpenses => 'Tidak ada pengeluaran tercatat';

  @override
  String get drawerStatus => 'Drawer Status';

  @override
  String get drawerOpen => 'Open';

  @override
  String get drawerClosed => 'Closed';

  @override
  String get cashIn => 'Cash In';

  @override
  String get cashOut => 'Cash Out';

  @override
  String get expectedAmount => 'Expected Amount';

  @override
  String get countedAmount => 'Counted Amount';

  @override
  String get difference => 'Difference';

  @override
  String get openDrawerAction => 'Open Drawer';

  @override
  String get closeDrawerAction => 'Close Drawer';

  @override
  String get totalReceivables => 'Total Receivables';

  @override
  String get closeMonth => 'Close Month';

  @override
  String get shiftsTitle => 'Shift';

  @override
  String get currentShift => 'Current Shift';

  @override
  String get shiftHistory => 'Shift History';

  @override
  String get openShiftAction => 'Open Shift';

  @override
  String get closeShiftAction => 'Close Shift';

  @override
  String get shiftStartTime => 'Start Time';

  @override
  String get shiftEndTime => 'End Time';

  @override
  String get shiftTotalSales => 'Total Sales';

  @override
  String get shiftTotalOrders => 'Total Orders';

  @override
  String get startingCash => 'Starting Cash';

  @override
  String get cashierName => 'Cashier Name';

  @override
  String get shiftDuration => 'Duration';

  @override
  String get noShifts => 'No shifts recorded';

  @override
  String get purchasesTitle => 'Pembelian';

  @override
  String get newPurchase => 'New Purchase';

  @override
  String get smartReorder => 'Smart Reorder';

  @override
  String get aiInvoiceImport => 'AI Invoice Import';

  @override
  String get aiInvoiceReview => 'AI Invoice Review';

  @override
  String get purchaseOrder => 'Purchase Order';

  @override
  String get purchaseTotal => 'Purchase Total';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get suppliersTitle => 'Pemasok';

  @override
  String get addSupplier => 'Add Supplier';

  @override
  String get supplierName => 'Supplier Name';

  @override
  String get supplierPhone => 'Phone';

  @override
  String get supplierEmail => 'Email';

  @override
  String get supplierAddress => 'Address';

  @override
  String get totalSuppliers => 'Total Suppliers';

  @override
  String get supplierDetails => 'Supplier Details';

  @override
  String get noSuppliers => 'No suppliers found';

  @override
  String get discountsTitle => 'Diskon';

  @override
  String get addDiscount => 'Add Discount';

  @override
  String get discountName => 'Discount Name';

  @override
  String get discountType => 'Discount Type';

  @override
  String get discountValue => 'Value';

  @override
  String get percentageDiscount => 'Percentage';

  @override
  String get fixedDiscount => 'Fixed Amount';

  @override
  String get activeDiscounts => 'Active Discounts';

  @override
  String get couponsTitle => 'Kupon';

  @override
  String get addCoupon => 'Add Coupon';

  @override
  String get couponCode => 'Coupon Code';

  @override
  String get couponUsage => 'Usage';

  @override
  String get couponExpiry => 'Expiry';

  @override
  String get totalCoupons => 'Total Coupons';

  @override
  String get activeCoupons => 'Active';

  @override
  String get expiredCoupons => 'Expired';

  @override
  String get specialOffersTitle => 'Penawaran Khusus';

  @override
  String get addOffer => 'Add Offer';

  @override
  String get offerName => 'Offer Name';

  @override
  String get offerStartDate => 'Start Date';

  @override
  String get offerEndDate => 'End Date';

  @override
  String get smartPromotionsTitle => 'Promosi Cerdas';

  @override
  String get activePromotions => 'Active Promotions';

  @override
  String get suggestedPromotions => 'AI Suggestions';

  @override
  String get loyaltyTitle => 'Program Loyalitas';

  @override
  String get loyaltyMembers => 'Members';

  @override
  String get loyaltyRewards => 'Rewards';

  @override
  String get loyaltyTiers => 'Tiers';

  @override
  String get totalMembers => 'Total Members';

  @override
  String get pointsIssued => 'Points Issued';

  @override
  String get pointsRedeemed => 'Points Redeemed';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get printQueueTitle => 'Antrean Cetak';

  @override
  String get printAll => 'Print All';

  @override
  String get cancelAll => 'Cancel All';

  @override
  String get noPrintJobs => 'No print jobs';

  @override
  String get syncStatusTitle => 'Status Sinkronisasi';

  @override
  String get lastSyncTime => 'Last Sync';

  @override
  String get pendingItems => 'Pending Items';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get pendingTransactionsTitle => 'Pending Transactions';

  @override
  String get conflictResolutionTitle => 'Conflict Resolution';

  @override
  String get localValue => 'Local';

  @override
  String get serverValue => 'Server';

  @override
  String get keepLocal => 'Keep Local';

  @override
  String get keepServer => 'Keep Server';

  @override
  String get driversTitle => 'Pengemudi';

  @override
  String get addDriver => 'Add Driver';

  @override
  String get driverName => 'Driver Name';

  @override
  String get driverStatus => 'Status';

  @override
  String get delivering => 'Delivering';

  @override
  String get totalDeliveries => 'Total Deliveries';

  @override
  String get driverRating => 'Rating';

  @override
  String get branchesTitle => 'Cabang';

  @override
  String get addBranchAction => 'Add Branch';

  @override
  String get branchName => 'Branch Name';

  @override
  String get branchEmployees => 'Employees';

  @override
  String get branchSales => 'Today\'s Sales';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get role => 'Role';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get storeSettings => 'Pengaturan Toko';

  @override
  String get posSettings => 'Pengaturan POS';

  @override
  String get printerSettings => 'Pengaturan Printer';

  @override
  String get paymentDevicesSettings => 'Payment Devices';

  @override
  String get barcodeSettings => 'Barcode Settings';

  @override
  String get receiptTemplate => 'Receipt Template';

  @override
  String get taxSettings => 'Tax Settings';

  @override
  String get discountSettings => 'Discount Settings';

  @override
  String get interestSettings => 'Interest Settings';

  @override
  String get languageSettings => 'Language';

  @override
  String get themeSettings => 'Theme';

  @override
  String get securitySettings => 'Keamanan';

  @override
  String get usersManagement => 'Manajemen Pengguna';

  @override
  String get rolesPermissions => 'Peran & Izin';

  @override
  String get activityLog => 'Log Aktivitas';

  @override
  String get backupSettings => 'Backup & Pemulihan';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get zatcaCompliance => 'Kepatuhan ZATCA';

  @override
  String get helpSupport => 'Bantuan & Dukungan';

  @override
  String get general => 'General';

  @override
  String get appearance => 'Appearance';

  @override
  String get securitySection => 'Security';

  @override
  String get advanced => 'Advanced';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get configure => 'Configure';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get manualBackup => 'Backup Now';

  @override
  String get restoreBackup => 'Restore';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get sessionTimeout => 'Session Timeout';

  @override
  String get changePin => 'Change PIN';

  @override
  String get twoFactorAuth => 'Two-Factor Auth';

  @override
  String get addUser => 'Add User';

  @override
  String get userName => 'Username';

  @override
  String get userEmail => 'Email';

  @override
  String get userPhone => 'Phone';

  @override
  String get addRole => 'Add Role';

  @override
  String get roleName => 'Role Name';

  @override
  String get permissions => 'Permissions';

  @override
  String get faq => 'FAQ';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get documentation => 'Documentation';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get zatcaRegistration => 'ZATCA Registration';

  @override
  String get eInvoicing => 'E-Invoicing';

  @override
  String get qrCode => 'QR Code';

  @override
  String get vatNumber => 'VAT Number';

  @override
  String get taxNumber => 'Tax Number';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get smsNotifications => 'SMS Notifications';

  @override
  String get orderNotifications => 'Order Notifications';

  @override
  String get stockNotifications => 'Stock Alerts';

  @override
  String get paymentNotifications => 'Payment Notifications';

  @override
  String get liveChat => 'Obrolan Langsung';

  @override
  String get emailSupport => 'Dukungan Email';

  @override
  String get phoneSupport => 'Dukungan Telepon';

  @override
  String get whatsappSupport => 'Dukungan WhatsApp';

  @override
  String get userGuide => 'Panduan Pengguna';

  @override
  String get videoTutorials => 'Tutorial Video';

  @override
  String get changelog => 'Log Perubahan';

  @override
  String get appInfo => 'Info Aplikasi';

  @override
  String get buildNumber => 'Nomor Build';

  @override
  String get notificationChannels => 'Saluran Notifikasi';

  @override
  String get alertTypes => 'Jenis Peringatan';

  @override
  String get salesAlerts => 'Peringatan Penjualan';

  @override
  String get inventoryAlerts => 'Peringatan Inventaris';

  @override
  String get securityAlerts => 'Peringatan Keamanan';

  @override
  String get reportAlerts => 'Peringatan Laporan';

  @override
  String get users => 'Pengguna';

  @override
  String get zatcaRegistered => 'Terdaftar di ZATCA';

  @override
  String get zatcaPhase2Active => 'Fase 2 Aktif';

  @override
  String get zatcaQueueReportTitle => 'Antrian Pengiriman ZATCA';

  @override
  String get zatcaSent => 'Terkirim';

  @override
  String get zatcaPendingLabel => 'Menunggu';

  @override
  String get zatcaRejected => 'Ditolak';

  @override
  String get zatcaPendingSection => 'Faktur menunggu';

  @override
  String get zatcaRejectedSection => 'Faktur ditolak';

  @override
  String get zatcaNoPendingInvoices => 'Tidak ada faktur menunggu';

  @override
  String get zatcaNoRejectedInvoices => 'Tidak ada faktur ditolak';

  @override
  String zatcaRetriesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count percobaan',
      one: '1 percobaan',
      zero: 'Tidak ada percobaan ulang',
    );
    return '$_temp0';
  }

  @override
  String get registrationInfo => 'Info Pendaftaran';

  @override
  String get businessName => 'Nama Bisnis';

  @override
  String get branchCode => 'Kode Cabang';

  @override
  String get qrCodeOnInvoice => 'Kode QR di Faktur';

  @override
  String get certificates => 'Sertifikat';

  @override
  String get csidCertificate => 'Sertifikat CSID';

  @override
  String get valid => 'Valid';

  @override
  String get privateKey => 'Kunci Privat';

  @override
  String get configured => 'Dikonfigurasi';

  @override
  String get aiSection => 'Artificial Intelligence';

  @override
  String get aiAssistantTitle => 'AI Assistant';

  @override
  String get aiAssistantSubtitle =>
      'Ask your smart assistant anything about your store';

  @override
  String get aiSalesForecastingTitle => 'Sales Forecasting';

  @override
  String get aiSalesForecastingSubtitle =>
      'Predict future sales using historical data';

  @override
  String get aiSmartPricingTitle => 'Smart Pricing';

  @override
  String get aiSmartPricingSubtitle =>
      'AI-powered price optimization suggestions';

  @override
  String get aiFraudDetectionTitle => 'Fraud Detection';

  @override
  String get aiFraudDetectionSubtitle =>
      'Detect suspicious patterns and protect your business';

  @override
  String get aiBasketAnalysisTitle => 'Basket Analysis';

  @override
  String get aiBasketAnalysisSubtitle =>
      'Discover products frequently bought together';

  @override
  String get aiCustomerRecommendationsTitle => 'Customer Recommendations';

  @override
  String get aiCustomerRecommendationsSubtitle =>
      'Personalized product suggestions for customers';

  @override
  String get aiSmartInventoryTitle => 'Smart Inventory';

  @override
  String get aiSmartInventorySubtitle =>
      'Optimal stock levels and waste prediction';

  @override
  String get aiCompetitorAnalysisTitle => 'Competitor Analysis';

  @override
  String get aiCompetitorAnalysisSubtitle =>
      'Compare your prices with competitors';

  @override
  String get aiSmartReportsTitle => 'Smart Reports';

  @override
  String get aiSmartReportsSubtitle =>
      'Generate reports using natural language';

  @override
  String get aiStaffAnalyticsTitle => 'Staff Analytics';

  @override
  String get aiStaffAnalyticsSubtitle =>
      'Employee performance analysis and optimization';

  @override
  String get aiProductRecognitionTitle => 'Product Recognition';

  @override
  String get aiProductRecognitionSubtitle => 'Identify products using camera';

  @override
  String get aiSentimentAnalysisTitle => 'Sentiment Analysis';

  @override
  String get aiSentimentAnalysisSubtitle =>
      'Analyze customer feedback and satisfaction';

  @override
  String get aiReturnPredictionTitle => 'Return Prediction';

  @override
  String get aiReturnPredictionSubtitle =>
      'Predict and prevent product returns';

  @override
  String get aiPromotionDesignerTitle => 'Promotion Designer';

  @override
  String get aiPromotionDesignerSubtitle =>
      'AI-generated promotions with ROI forecasting';

  @override
  String get aiChatWithDataTitle => 'Chat with Data';

  @override
  String get aiChatWithDataSubtitle => 'Query your data using natural language';

  @override
  String get aiConfidence => 'Confidence';

  @override
  String get aiHighConfidence => 'High confidence';

  @override
  String get aiMediumConfidence => 'Medium confidence';

  @override
  String get aiLowConfidence => 'Low confidence';

  @override
  String get aiAnalyzing => 'Analyzing...';

  @override
  String get aiGenerating => 'Generating...';

  @override
  String get aiNoData => 'No data available for analysis';

  @override
  String get aiRefresh => 'Refresh Analysis';

  @override
  String get aiExport => 'Export Results';

  @override
  String get aiApply => 'Apply Suggestions';

  @override
  String get aiDismiss => 'Dismiss';

  @override
  String get aiViewDetails => 'View Details';

  @override
  String get aiSuggestions => 'AI Suggestions';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get aiPrediction => 'Prediction';

  @override
  String get aiRecommendation => 'Recommendation';

  @override
  String get aiAlert => 'Alert';

  @override
  String get aiWarning => 'Warning';

  @override
  String get aiTrend => 'Tren';

  @override
  String get aiPositive => 'Positive';

  @override
  String get aiNegative => 'Negative';

  @override
  String get aiNeutral => 'Neutral';

  @override
  String get aiSendMessage => 'Send message...';

  @override
  String get aiQuickTemplates => 'Quick Templates';

  @override
  String get aiForecastPeriod => 'Forecast Period';

  @override
  String get aiWeekly => 'Weekly';

  @override
  String get aiMonthly => 'Monthly';

  @override
  String get aiQuarterly => 'Quarterly';

  @override
  String get aiWhatIfScenario => 'What-If Scenario';

  @override
  String get aiSeasonalPatterns => 'Seasonal Patterns';

  @override
  String get aiPriceSuggestion => 'Price Suggestion';

  @override
  String get aiCurrentPrice => 'Current Price';

  @override
  String get aiSuggestedPrice => 'Suggested Price';

  @override
  String get aiPriceImpact => 'Price Impact';

  @override
  String get aiDemandElasticity => 'Demand Elasticity';

  @override
  String get aiFraudAlerts => 'Fraud Alerts';

  @override
  String get aiFraudRiskScore => 'Risk Score';

  @override
  String get aiBehaviorScore => 'Behavior Score';

  @override
  String get aiInvestigation => 'Investigasi';

  @override
  String get aiAssociationRules => 'Association Rules';

  @override
  String get aiBundleSuggestions => 'Saran Bundel';

  @override
  String get aiRepurchaseReminder => 'Repurchase Reminder';

  @override
  String get aiCustomerSegment => 'Customer Segment';

  @override
  String get aiEoqCalculator => 'EOQ Calculator';

  @override
  String get aiAbcAnalysis => 'ABC Analysis';

  @override
  String get aiWastePrediction => 'Waste Prediction';

  @override
  String get aiReorderPoint => 'Reorder Point';

  @override
  String get aiCompetitorPrices => 'Competitor Prices';

  @override
  String get aiMarketPosition => 'Posisi Pasar';

  @override
  String get aiQueryInput => 'Ask anything about your data...';

  @override
  String get aiReportTemplate => 'Report Template';

  @override
  String get aiStaffPerformance => 'Staff Performance';

  @override
  String get aiShiftOptimization => 'Optimasi Shift';

  @override
  String get aiProductScan => 'Scan Product';

  @override
  String get aiOcrResults => 'OCR Results';

  @override
  String get aiSentimentScore => 'Sentiment Score';

  @override
  String get aiKeywords => 'Keywords';

  @override
  String get aiReturnRisk => 'Return Risk';

  @override
  String get aiPreventiveActions => 'Preventive Actions';

  @override
  String get aiRoiForecast => 'ROI Forecast';

  @override
  String get aiAbTesting => 'A/B Testing';

  @override
  String get aiQueryHistory => 'Query History';

  @override
  String get aiApplied => 'Applied';

  @override
  String get aiPending => 'Pending';

  @override
  String get aiHighPriority => 'High Priority';

  @override
  String get aiMediumPriority => 'Medium Priority';

  @override
  String get aiLowPriority => 'Low Priority';

  @override
  String get aiCritical => 'Critical';

  @override
  String get aiSar => 'SAR';

  @override
  String aiPercentChange(String percent) {
    return '$percent% change';
  }

  @override
  String aiItemsCount(int count) {
    return '$count items';
  }

  @override
  String aiLastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get connectedToServer => 'Connected to server';

  @override
  String lastSyncAt(String time) {
    return 'Last sync: $time';
  }

  @override
  String get pendingOperations => 'Pending Operations';

  @override
  String nPendingOperations(int count) {
    return '$count operations awaiting sync';
  }

  @override
  String get noPendingOperations => 'No pending operations';

  @override
  String get syncInfo => 'Sync Information';

  @override
  String get device => 'Device';

  @override
  String get appVersion => 'App Version';

  @override
  String get lastFullSync => 'Last Full Sync';

  @override
  String get databaseStatus => 'Database Status';

  @override
  String get healthy => 'Healthy';

  @override
  String get syncSuccessful => 'Sync completed successfully';

  @override
  String get justNow => 'Just now';

  @override
  String get allOperationsSynced => 'All operations synced';

  @override
  String get willSyncWhenOnline => 'Will sync when connected to internet';

  @override
  String get syncAll => 'Sync All';

  @override
  String get operationSynced => 'Operation synced';

  @override
  String get deleteOperation => 'Delete Operation';

  @override
  String get deleteOperationConfirm =>
      'Do you want to delete this operation from the queue?';

  @override
  String get insertOperation => 'Insert';

  @override
  String get updateOperation => 'Update';

  @override
  String get operationLabel => 'Operation';

  @override
  String nPendingCount(int count) {
    return '$count pending operation(s)';
  }

  @override
  String conflictsNeedResolution(int count) {
    return '$count conflicts need resolution';
  }

  @override
  String get chooseCorrectValue => 'Choose the correct value for each conflict';

  @override
  String get noConflicts => 'No conflicts';

  @override
  String get productPriceConflict => 'Product price conflict';

  @override
  String get stockQuantityConflict => 'Stock quantity conflict';

  @override
  String get useAllLocal => 'Use All Local';

  @override
  String get useAllServer => 'Use All from Server';

  @override
  String get conflictResolvedLocal => 'Conflict resolved using local value';

  @override
  String get conflictResolvedServer => 'Conflict resolved using server value';

  @override
  String get useLocalValues => 'Local values';

  @override
  String get useServerValues => 'Server values';

  @override
  String applyToAllConflicts(String choice) {
    return 'Will apply $choice to all conflicts';
  }

  @override
  String get allConflictsResolved => 'All conflicts resolved';

  @override
  String get localValueLabel => 'Local Value';

  @override
  String get serverValueLabel => 'Server Value';

  @override
  String get noteOptional => 'Catatan (opsional)';

  @override
  String get suspendInvoice => 'Tunda Faktur';

  @override
  String get invoiceSuspended => 'Faktur ditunda';

  @override
  String nItems(int count) {
    return '$count item';
  }

  @override
  String saveSaleError(String error) {
    return 'Error menyimpan penjualan: $error';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get stockGood => 'Stock is Good!';

  @override
  String get manageInventory => 'Manage Inventory';

  @override
  String pendingSyncCount(int count) {
    return '$count pending sync';
  }

  @override
  String get freshMilk => 'Fresh Milk';

  @override
  String get whiteBread => 'White Bread';

  @override
  String get localEggs => 'Local Eggs';

  @override
  String get yogurt => 'Yogurt';

  @override
  String minQuantityLabel(int count) {
    return 'Min: $count';
  }

  @override
  String get manageDiscounts => 'Manage Discounts';

  @override
  String get newDiscount => 'New Discount';

  @override
  String get totalLabel => 'Total';

  @override
  String get stopped => 'Stopped';

  @override
  String get allProducts => 'All Products';

  @override
  String get specificCategory => 'Specific Category';

  @override
  String get percentageLabel => 'Percentage %';

  @override
  String get fixedAmount => 'Fixed Amount';

  @override
  String get thePercentage => 'Percentage';

  @override
  String get theAmount => 'Amount';

  @override
  String discountOff(String value) {
    return '$value% discount';
  }

  @override
  String sarDiscountOff(String value) {
    return '$value SAR discount';
  }

  @override
  String get manageCoupons => 'Manage Coupons';

  @override
  String get newCoupon => 'New Coupon';

  @override
  String get expired => 'Expired';

  @override
  String get deactivated => 'Deactivated';

  @override
  String usageCount(int used, int max) {
    return '$used/$max uses';
  }

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String percentageDiscountLabel(int value) {
    return '$value% discount';
  }

  @override
  String fixedDiscountLabel(int value) {
    return '$value SAR discount';
  }

  @override
  String get couponTypeLabel => 'Type';

  @override
  String get percentageRate => 'Percentage Rate';

  @override
  String get minimumOrder => 'Minimum Order';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get copyCode => 'Salin';

  @override
  String get usages => 'Uses';

  @override
  String get percentageDiscountOption => 'Percentage Discount';

  @override
  String get fixedDiscountOption => 'Fixed Discount';

  @override
  String get freeDeliveryOption => 'Free Delivery';

  @override
  String get percentageField => 'Percentage %';

  @override
  String get manageSpecialOffers => 'Manage Special Offers';

  @override
  String get newOffer => 'New Offer';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get offerExpired => 'Expired';

  @override
  String bundleDiscount(String discount) {
    return 'Bundle - $discount% off';
  }

  @override
  String get buyAndGetFree => 'Buy & Get Free';

  @override
  String offerDiscountPercent(String discount) {
    return '$discount% discount';
  }

  @override
  String offerDiscountFixed(String discount) {
    return '$discount SAR discount';
  }

  @override
  String get bundleLabel => 'Bundle';

  @override
  String get buyAndGet => 'Buy & Get';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get productsLabel => 'Products';

  @override
  String get offerType => 'Type';

  @override
  String get theDiscount => 'Discount:';

  @override
  String get smartSuggestions => 'Smart Suggestions';

  @override
  String get suggestionsBasedOnAnalysis =>
      'Suggested offers based on sales and inventory analysis';

  @override
  String suggestedDiscountPercent(int percent) {
    return '$percent% suggested discount';
  }

  @override
  String stockLabelCount(int count) {
    return 'Stock: $count';
  }

  @override
  String validityDays(int days) {
    return 'Validity: $days days';
  }

  @override
  String get ignore => 'Ignore';

  @override
  String get applyAction => 'Apply';

  @override
  String usageCountTimes(int count) {
    return 'Usage: $count times';
  }

  @override
  String get promotionHistory => 'Previous Promotions History';

  @override
  String get createNewPromotion => 'Create New Promotion';

  @override
  String get percentageDiscountType => 'Percentage Discount';

  @override
  String get percentageDiscountDesc => '10%, 20%, etc.';

  @override
  String get buyXGetY => 'Buy X Get Y';

  @override
  String get buyXGetYDesc => 'Buy 2 Get 1 Free';

  @override
  String get fixedAmountDiscount => 'Fixed Amount Discount';

  @override
  String get fixedAmountDiscountDesc => '10 SAR off product';

  @override
  String promotionApplied(String product) {
    return 'Promotion applied to $product';
  }

  @override
  String promotionType(String type) {
    return 'Type: $type';
  }

  @override
  String promotionValue(String value) {
    return 'Value: $value';
  }

  @override
  String promotionUsage(int count) {
    return 'Usage: $count times';
  }

  @override
  String get percentageType => 'Percentage';

  @override
  String get buyXGetYType => 'Buy & Get';

  @override
  String get fixedAmountType => 'Fixed Amount';

  @override
  String get closeAction => 'Close';

  @override
  String get holdInvoices => 'Hold Invoices';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noHoldInvoices => 'No Hold Invoices';

  @override
  String get holdInvoicesDesc =>
      'When you hold an invoice from POS, it will appear here\nYou can hold multiple invoices and resume them later';

  @override
  String get deleteInvoiceTitle => 'Delete Invoice';

  @override
  String deleteInvoiceConfirmMsg(String name) {
    return 'Do you want to delete \"$name\"?\nThis action cannot be undone.';
  }

  @override
  String get cannotUndo => 'This action cannot be undone.';

  @override
  String get deleteAllLabel => 'Delete All';

  @override
  String get deleteAllInvoices => 'Delete All Invoices';

  @override
  String deleteAllInvoicesConfirm(int count) {
    return 'Do you want to delete all hold invoices ($count invoices)?\nThis action cannot be undone.';
  }

  @override
  String get invoiceDeletedMsg => 'Invoice deleted';

  @override
  String get allInvoicesDeleted => 'All invoices deleted';

  @override
  String resumedInvoice(String name) {
    return 'Resumed: $name';
  }

  @override
  String itemLabel(int count) {
    return '$count item';
  }

  @override
  String moreItems(int count) {
    return '+$count more items';
  }

  @override
  String get resume => 'Resume';

  @override
  String get justNowTime => 'Just now';

  @override
  String minutesAgoTime(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgoTime(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgoTime(int count) {
    return '$count days ago';
  }

  @override
  String get debtManagement => 'Debt Management';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortByAmount => 'By Amount';

  @override
  String get sortByDate => 'By Date';

  @override
  String get sendReminders => 'Send Reminders';

  @override
  String get allTab => 'All';

  @override
  String get overdueTab => 'Overdue';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get totalDebts => 'Total Debts';

  @override
  String get overdueDebts => 'Overdue Debts';

  @override
  String get debtorCustomers => 'Debtor Customers';

  @override
  String get noDebts => 'No Debts';

  @override
  String customerLabel2(int count) {
    return '$count customer';
  }

  @override
  String overdueDays(int days) {
    return 'Overdue $days days';
  }

  @override
  String remainingDays(int days) {
    return '$days days remaining';
  }

  @override
  String lastPaymentDate(String date) {
    return 'Last payment: $date';
  }

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get amountDue => 'Amount Due';

  @override
  String currentDebt(String amount) {
    return 'Current debt: $amount SAR';
  }

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get cashMethod => 'Cash';

  @override
  String get cardMethod => 'Card';

  @override
  String get transferMethod => 'Transfer';

  @override
  String get paymentRecordedSuccess => 'Payment recorded successfully';

  @override
  String get sendRemindersTitle => 'Send Reminders';

  @override
  String sendRemindersConfirm(int count) {
    return 'A reminder will be sent to $count customers with overdue debts';
  }

  @override
  String get sendAction => 'Send';

  @override
  String remindersSent(int count) {
    return '$count reminders sent';
  }

  @override
  String recordPaymentFor(String name) {
    return 'Record Payment - $name';
  }

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get tabAiSuggestions => 'AI Suggestions';

  @override
  String get tabActivePromotions => 'Active Promotions';

  @override
  String get tabHistory => 'History';

  @override
  String get fruitYogurt => 'Fruit Yogurt';

  @override
  String get buttermilk => 'Buttermilk';

  @override
  String get appleJuice => 'Apple Juice';

  @override
  String get whiteCheese => 'White Cheese';

  @override
  String get orangeJuice => 'Orange Juice';

  @override
  String slowMovementReason(String days) {
    return 'Slow movement - $days days without sale';
  }

  @override
  String get nearExpiryReason => 'Near expiry date';

  @override
  String get excessStockReason => 'Excess stock';

  @override
  String get weekendOffer => 'Weekend Offer';

  @override
  String get buy2Get1Free => 'Buy 2 Get 1 Free';

  @override
  String get productsListLabel => 'Products:';

  @override
  String get paymentMethodLabel2 => 'Payment Method';

  @override
  String get lastPaymentLabel => 'Last Payment';

  @override
  String get currencySAR => 'SAR';

  @override
  String debtAmountWithCurrency(String amount) {
    return '$amount SAR';
  }

  @override
  String get defaultUserName => 'Ahmed Mohammed';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsReset => 'Settings have been reset';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Reset all settings to default values';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all POS settings to default values?';

  @override
  String get resetAction => 'Atur Ulang';

  @override
  String get posSettingsSubtitle => 'Display, Cart, Payment, Receipt';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get productDisplayMode => 'Product Display Mode';

  @override
  String get productDisplayModeDesc =>
      'How products are displayed in POS screen';

  @override
  String get gridColumns => 'Number of Columns';

  @override
  String nColumns(int count) {
    return '$count columns';
  }

  @override
  String get showProductImages => 'Show Product Images';

  @override
  String get showProductImagesDesc => 'Show images on product cards';

  @override
  String get showPrices => 'Show Prices';

  @override
  String get showPricesDesc => 'Show price on product card';

  @override
  String get showStockLevel => 'Show Stock Level';

  @override
  String get showStockLevelDesc => 'Show available quantity';

  @override
  String get cartSettings => 'Cart Settings';

  @override
  String get autoFocusBarcode => 'Auto-focus Barcode Field';

  @override
  String get autoFocusBarcodeDesc => 'Focus on barcode field when screen opens';

  @override
  String get allowNegativeStock => 'Allow Negative Stock';

  @override
  String get allowNegativeStockDesc => 'Sell even when stock is zero';

  @override
  String get confirmBeforeDelete => 'Confirm Before Delete';

  @override
  String get confirmBeforeDeleteDesc =>
      'Ask for confirmation when removing product from cart';

  @override
  String get showItemNotes => 'Show Item Notes';

  @override
  String get showItemNotesDesc => 'Allow adding notes to each item';

  @override
  String get cashPaymentOption => 'Cash Payment';

  @override
  String get cardPaymentOption => 'Card Payment';

  @override
  String get creditPaymentOption => 'Credit Payment';

  @override
  String get bankTransferOption => 'Bank Transfer';

  @override
  String get allowSplitPayment => 'Allow Split Payment';

  @override
  String get allowSplitPaymentDesc => 'Pay with multiple methods';

  @override
  String get requireCustomerForCredit => 'Require Customer for Credit';

  @override
  String get requireCustomerForCreditDesc =>
      'Customer must be selected for credit payment';

  @override
  String get receiptSettings => 'Receipt Settings';

  @override
  String get autoPrintReceipt => 'Auto Print Receipt';

  @override
  String get autoPrintReceiptDesc => 'Print immediately after transaction';

  @override
  String get receiptCopies => 'Number of Receipt Copies';

  @override
  String get emailReceiptOption => 'Email Receipt';

  @override
  String get emailReceiptDesc => 'Send a copy to customer';

  @override
  String get smsReceiptOption => 'SMS Receipt';

  @override
  String get smsReceiptDesc => 'Text message to customer';

  @override
  String get printerSettingsDesc => 'Choose printer and its settings';

  @override
  String get receiptDesign => 'Receipt Design';

  @override
  String get receiptDesignDesc => 'Customize receipt appearance';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get allowHoldInvoices => 'Allow Hold Invoices';

  @override
  String get allowHoldInvoicesDesc => 'Save invoice temporarily';

  @override
  String get maxHoldInvoices => 'Max Hold Invoices';

  @override
  String get quickSaleMode => 'Quick Sale Mode';

  @override
  String get quickSaleModeDesc => 'Simplified screen for quick sales';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDesc => 'Sounds on scan and add';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc => 'Vibrate on button press';

  @override
  String get keyboardShortcuts => 'Keyboard Shortcuts';

  @override
  String get animationsToggle => 'Animasi';

  @override
  String get animationsToggleDesc => 'Transisi layar yang halus';

  @override
  String get customizeShortcuts => 'Customize shortcuts';

  @override
  String get shortcutSearchProduct => 'Search product';

  @override
  String get shortcutSearchCustomer => 'Search customer';

  @override
  String get shortcutHoldInvoice => 'Hold invoice';

  @override
  String get shortcutFavorites => 'Favorites';

  @override
  String get shortcutApplyDiscount => 'Apply discount';

  @override
  String get shortcutPayment => 'Payment';

  @override
  String get shortcutCancelBack => 'Cancel / Back';

  @override
  String get shortcutDeleteProduct => 'Delete product';

  @override
  String get paymentDevicesSubtitle => 'mada, STC Pay, Apple Pay';

  @override
  String get supportedPaymentMethods => 'Supported Payment Methods';

  @override
  String get madaLocalCards => 'Local mada cards';

  @override
  String get internationalCards => 'International cards';

  @override
  String get stcDigitalWallet => 'STC digital wallet';

  @override
  String get paymentTerminal => 'Payment Terminal';

  @override
  String get ingenicoDevices => 'Ingenico devices';

  @override
  String get verifoneDevices => 'Verifone devices';

  @override
  String get paxDevices => 'PAX devices';

  @override
  String get settlement => 'Settlement';

  @override
  String get autoSettlement => 'Auto Settlement';

  @override
  String get autoSettlementDesc => 'Automatic end-of-day settlement';

  @override
  String get manualSettlement => 'Manual Settlement';

  @override
  String get executeSettlementNow => 'Execute settlement now';

  @override
  String get settlingInProgress => 'Settling...';

  @override
  String get paymentDevicesSettingsSaved => 'Payment devices settings saved';

  @override
  String get printerType => 'Printer Type';

  @override
  String get thermalUsbPrinter => 'USB thermal printer';

  @override
  String get bluetoothPortablePrinter => 'Bluetooth portable printer';

  @override
  String get saveAsPdf => 'Save as PDF file';

  @override
  String get compactTemplate => 'Compact';

  @override
  String get basicInfoOnly => 'Basic info only';

  @override
  String get detailedTemplate => 'Detailed';

  @override
  String get allDetails => 'All details';

  @override
  String get printOptions => 'Print Options';

  @override
  String get autoPrinting => 'Auto Printing';

  @override
  String get autoPrintAfterSale => 'Auto print receipt after each sale';

  @override
  String get testPrintInProgress => 'Test printing...';

  @override
  String get testPrint => 'Test Print';

  @override
  String get printerSettingsSaved => 'Printer settings saved';

  @override
  String get printerSettingsSubtitle => 'Printer type, template, auto print';

  @override
  String get enableScanner => 'Enable Scanner';

  @override
  String get barcodeScanner => 'Barcode Scanner';

  @override
  String get barcodeScannerDesc => 'Use barcode scanner to add products';

  @override
  String get deviceCamera => 'Device Camera';

  @override
  String get bluetoothScanner => 'Bluetooth Scanner';

  @override
  String get externalScannerConnected => 'External scanner connected';

  @override
  String get alerts => 'Alerts';

  @override
  String get beepOnScan => 'Beep on Scan';

  @override
  String get vibrateOnScan => 'Vibrate on Scan';

  @override
  String get behavior => 'Behavior';

  @override
  String get autoAddToCart => 'Auto Add to Cart';

  @override
  String get autoAddToCartDesc => 'When scanning existing product';

  @override
  String get barcodeFormats => 'Barcode Formats';

  @override
  String get allFormats => 'All formats';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get qrCodeOnly => 'QR Code only';

  @override
  String get testing => 'Testing';

  @override
  String get testScanner => 'Test Scanner';

  @override
  String get testScanBarcode => 'Try scanning a barcode';

  @override
  String get pointCameraAtBarcode => 'Point camera at the barcode';

  @override
  String get scanArea => 'Scan area';

  @override
  String get barcodeSettingsSubtitle => 'Scanner, alerts, formats';

  @override
  String get taxSettingsSubtitle => 'VAT, ZATCA, e-invoicing';

  @override
  String get vatSettings => 'Value Added Tax';

  @override
  String get enableVat => 'Enable VAT';

  @override
  String get enableVatDesc => 'Apply VAT on all sales';

  @override
  String get taxRate => 'Tax Rate';

  @override
  String get taxNumberHint => '15 digits starting with 3';

  @override
  String get pricesIncludeTax => 'Prices Include Tax';

  @override
  String get pricesIncludeTaxDesc => 'Displayed prices include tax';

  @override
  String get showTaxOnReceipt => 'Show Tax on Receipt';

  @override
  String get showTaxOnReceiptDesc => 'Show tax details';

  @override
  String get zatcaEInvoicing => 'ZATCA - E-Invoicing';

  @override
  String get enableZatca => 'Enable ZATCA';

  @override
  String get enableZatcaDesc => 'Comply with e-invoicing system';

  @override
  String get phaseOne => 'Phase 1';

  @override
  String get phaseOneDesc => 'Invoice issuance';

  @override
  String get phaseTwo => 'Phase 2';

  @override
  String get phaseTwoDesc => 'Integration and linking';

  @override
  String get taxSettingsSaved => 'Tax settings saved';

  @override
  String get discountSettingsTitle => 'Discount Settings';

  @override
  String get discountSettingsSubtitle => 'Manual, VIP, volume, coupons';

  @override
  String get generalDiscounts => 'General Discounts';

  @override
  String get enableDiscountsOption => 'Enable Discounts';

  @override
  String get enableDiscountsDesc => 'Allow applying discounts';

  @override
  String get manualDiscount => 'Manual Discount';

  @override
  String get manualDiscountDesc => 'Allow cashier to enter manual discount';

  @override
  String get maxDiscountLimit => 'Max Discount Limit';

  @override
  String get requireApproval => 'Require Approval';

  @override
  String get requireApprovalDesc => 'Require manager approval for discount';

  @override
  String get vipCustomerDiscount => 'VIP Customer Discount';

  @override
  String get vipDiscount => 'VIP Discount';

  @override
  String get vipDiscountDesc => 'Auto discount for VIP customers';

  @override
  String get vipDiscountRate => 'VIP Discount Rate';

  @override
  String get otherDiscounts => 'Other Discounts';

  @override
  String get volumeDiscount => 'Volume Discount';

  @override
  String get volumeDiscountDesc => 'Auto discount on certain quantities';

  @override
  String get couponsOption => 'Coupons';

  @override
  String get couponsDesc => 'Support discount coupons';

  @override
  String get discountSettingsSaved => 'Discount settings saved';

  @override
  String get interestSettingsTitle => 'Interest Settings';

  @override
  String get interestSettingsSubtitle => 'Rate, grace period, auto calculation';

  @override
  String get monthlyInterest => 'Monthly Interest';

  @override
  String get enableInterest => 'Enable Interest';

  @override
  String get enableInterestDesc => 'Apply interest on credit debts';

  @override
  String get monthlyInterestRate => 'Monthly Interest Rate';

  @override
  String get maxInterestRateLabel => 'Max Interest Rate';

  @override
  String get gracePeriod => 'Grace Period';

  @override
  String get graceDays => 'Grace Days';

  @override
  String graceDaysLabel(int days) {
    return '$days days before interest calculation';
  }

  @override
  String get compoundInterest => 'Compound Interest';

  @override
  String get compoundInterestDesc => 'Calculate interest on interest';

  @override
  String get calculationAndAlerts => 'Calculation & Alerts';

  @override
  String get autoCalculation => 'Auto Calculation';

  @override
  String get autoCalculationDesc =>
      'Auto calculate interest at end of each month';

  @override
  String get customerNotification => 'Customer Notification';

  @override
  String get customerNotificationDesc =>
      'Send notification when interest is calculated';

  @override
  String get interestSettingsSaved => 'Interest settings saved';

  @override
  String get receiptTemplateTitle => 'Receipt Template';

  @override
  String get receiptTemplateSubtitle => 'Header, footer, fields, paper size';

  @override
  String get headerAndFooter => 'Header & Footer';

  @override
  String get receiptTitleField => 'Receipt Title';

  @override
  String get footerText => 'Footer Text';

  @override
  String get displayedFields => 'Displayed Fields';

  @override
  String get storeLogo => 'Store Logo';

  @override
  String get addressField => 'Address';

  @override
  String get phoneNumberField => 'Phone Number';

  @override
  String get vatNumberField => 'VAT Number';

  @override
  String get invoiceBarcode => 'Invoice Barcode';

  @override
  String get qrCodeField => 'QR Code';

  @override
  String get qrCodeEInvoice => 'QR code for e-invoice';

  @override
  String get paperSize => 'Paper Size';

  @override
  String get standardSize => 'Standard size';

  @override
  String get smallSize => 'Small size';

  @override
  String get normalPrint => 'Normal print';

  @override
  String get receiptTemplateSaved => 'Receipt template saved';

  @override
  String get instantNotifications => 'Instant notifications on device';

  @override
  String get emailNotificationsDesc => 'Send notifications via email';

  @override
  String get smsNotificationsDesc => 'Notifications via text messages';

  @override
  String get salesAlertsDesc => 'Sales and invoices alerts';

  @override
  String get inventoryAlertsDesc => 'Low stock alerts';

  @override
  String get securityAlertsDesc => 'Security and login alerts';

  @override
  String get reportAlertsDesc => 'Daily and weekly reports';

  @override
  String get contactSupportDesc => 'Available 24/7';

  @override
  String get systemGuide => 'System Guide';

  @override
  String get changeLog => 'Change Log';

  @override
  String get faqQuestion1 => 'How to add a new product?';

  @override
  String get faqAnswer1 =>
      'Go to Products > Add Product and fill in the details';

  @override
  String get faqQuestion2 => 'How to print invoices?';

  @override
  String get faqAnswer2 => 'After completing the sale, click Print Receipt';

  @override
  String get faqQuestion3 => 'How to set discounts?';

  @override
  String get faqAnswer3 =>
      'From Settings > Discount Settings, you can configure discounts';

  @override
  String get faqQuestion4 => 'How to add a new user?';

  @override
  String get faqAnswer4 => 'From Settings > User Management > Add User';

  @override
  String get faqQuestion5 => 'How to view reports?';

  @override
  String get faqAnswer5 =>
      'From the main menu > Reports, choose the desired report type';

  @override
  String get businessNameValue => 'Al-Hai Business';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get allFilter => 'All';

  @override
  String get loginLogoutFilter => 'Login/Logout';

  @override
  String get salesFilter => 'Sales';

  @override
  String get productsFilter => 'Products';

  @override
  String get usersFilter => 'Users';

  @override
  String get systemFilter => 'System';

  @override
  String get noActivities => 'No activities';

  @override
  String get pinSection => 'PIN Code';

  @override
  String get createPinOption => 'Create PIN';

  @override
  String get createPinDesc => 'Set a 4-digit PIN for fast login';

  @override
  String get changePinOption => 'Change PIN';

  @override
  String get changePinDesc => 'Update your current PIN';

  @override
  String get removePinOption => 'Remove PIN';

  @override
  String get removePinDesc => 'Delete PIN and use OTP login';

  @override
  String get biometricSection => 'Biometric Login';

  @override
  String get fingerprintOption => 'Fingerprint';

  @override
  String get fingerprintDesc => 'Login using fingerprint';

  @override
  String get faceIdOption => 'Face ID';

  @override
  String get faceIdDesc => 'Login using face recognition';

  @override
  String get sessionSection => 'Session';

  @override
  String get autoLockOption => 'Auto Lock';

  @override
  String get autoLockDesc => 'Lock screen after inactivity';

  @override
  String get autoLockTimeout => 'Auto Lock Timeout';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get logoutAllDevices => 'Logout All Devices';

  @override
  String get logoutAllDevicesDesc => 'End all active sessions';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc => 'Delete all local data';

  @override
  String get createPinTitle => 'Create PIN';

  @override
  String get enterNewPin => 'Enter new 4-digit PIN';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPinChange => 'Enter new PIN';

  @override
  String get removePinTitle => 'Remove PIN';

  @override
  String get removePinConfirm => 'Are you sure you want to remove PIN login?';

  @override
  String get removeAction => 'Remove';

  @override
  String get pinCreated => 'PIN created successfully';

  @override
  String get pinChangedSuccess => 'PIN changed successfully';

  @override
  String get pinRemovedSuccess => 'PIN removed';

  @override
  String get logoutAllTitle => 'Logout All Devices';

  @override
  String get logoutAllConfirm =>
      'This will end all active sessions. You will need to login again.';

  @override
  String get logoutAllAction => 'Logout All';

  @override
  String get loggedOutAll => 'All devices logged out';

  @override
  String get clearDataTitle => 'Clear All Data';

  @override
  String get clearDataConfirm =>
      'This will delete all local data. This action cannot be undone.';

  @override
  String get clearDataAction => 'Clear Data';

  @override
  String get dataCleared => 'All data cleared';

  @override
  String afterMinutes(int count) {
    return 'After $count minutes';
  }

  @override
  String get storeInfo => 'Store Information';

  @override
  String get storeNameField => 'Store Name';

  @override
  String get addressLabel => 'Address';

  @override
  String get taxInfo => 'Tax Information';

  @override
  String get vatNumberFieldLabel => 'VAT Number (VAT)';

  @override
  String get vatNumberHintText => '15 digits starting with 3';

  @override
  String get commercialRegister => 'Commercial Register';

  @override
  String get enableVatOption => 'Enable VAT';

  @override
  String get taxRateField => 'Tax Rate';

  @override
  String get languageAndCurrency => 'Language & Currency';

  @override
  String get currencyFieldLabel => 'Currency';

  @override
  String get saudiRiyal => 'Saudi Riyal (SAR)';

  @override
  String get usDollar => 'US Dollar (USD)';

  @override
  String get storeLogoSection => 'Store Logo';

  @override
  String get storeLogoDesc => 'Appears on invoices and receipts';

  @override
  String get changeButton => 'Change';

  @override
  String get storeSettingsSaved => 'Store settings saved';

  @override
  String get ownerRole => 'Owner';

  @override
  String get managerRole => 'Manager';

  @override
  String get supervisorRole => 'Supervisor';

  @override
  String get cashierRole => 'Cashier';

  @override
  String get disabledStatus => 'Disabled';

  @override
  String get editMenuAction => 'Edit';

  @override
  String get disableMenuAction => 'Disable';

  @override
  String get enableMenuAction => 'Enable';

  @override
  String get addUserTitle => 'Add User';

  @override
  String get editUserTitle => 'Edit User';

  @override
  String get nameRequired => 'Name *';

  @override
  String get roleLabel => 'Role';

  @override
  String get userDetailsTitle => 'User Details';

  @override
  String get rolesTab => 'Roles';

  @override
  String get permissionsTab => 'Permissions';

  @override
  String get newRoleButton => 'New Role';

  @override
  String get systemBadge => 'System';

  @override
  String userCountLabel(int count) {
    return '$count users';
  }

  @override
  String permissionCountLabel(int count) {
    return '$count permissions';
  }

  @override
  String get editRoleMenu => 'Edit';

  @override
  String get duplicateRoleMenu => 'Duplicate';

  @override
  String get deleteRoleMenu => 'Delete';

  @override
  String get addRoleTitle => 'Add Role';

  @override
  String get editRoleTitle => 'Edit Role';

  @override
  String get roleNameField => 'Role Name';

  @override
  String get roleDescField => 'Description';

  @override
  String get rolePermissionsLabel => 'Permissions';

  @override
  String get permViewSales => 'View Sales';

  @override
  String get permViewSalesDesc => 'View sales and invoices';

  @override
  String get permCreateSale => 'Create Sale';

  @override
  String get permCreateSaleDesc => 'Create new sales';

  @override
  String get permApplyDiscount => 'Apply Discount';

  @override
  String get permApplyDiscountDesc => 'Apply discounts to invoices';

  @override
  String get permVoidSale => 'Void Sale';

  @override
  String get permVoidSaleDesc => 'Cancel and void sales';

  @override
  String get permViewProducts => 'View Products';

  @override
  String get permViewProductsDesc => 'View product list';

  @override
  String get permEditProducts => 'Edit Products';

  @override
  String get permEditProductsDesc => 'Edit product details and prices';

  @override
  String get permManageInventory => 'Manage Inventory';

  @override
  String get permManageInventoryDesc => 'Manage stock and inventory';

  @override
  String get permViewReports => 'View Reports';

  @override
  String get permViewReportsDesc => 'View all reports';

  @override
  String get permExportReports => 'Export Reports';

  @override
  String get permExportReportsDesc => 'Export reports as PDF/Excel';

  @override
  String get permViewCustomers => 'View Customers';

  @override
  String get permViewCustomersDesc => 'View customer list';

  @override
  String get permManageCustomers => 'Manage Customers';

  @override
  String get permManageCustomersDesc => 'Add and edit customers';

  @override
  String get permManageDebts => 'Manage Debts';

  @override
  String get permManageDebtsDesc => 'Manage customer debts';

  @override
  String get permOpenCloseShift => 'Open/Close Shift';

  @override
  String get permOpenCloseShiftDesc => 'Open and close work shifts';

  @override
  String get permManageCashDrawer => 'Manage Cash Drawer';

  @override
  String get permManageCashDrawerDesc => 'Add and withdraw cash';

  @override
  String get permManageUsers => 'Manage Users';

  @override
  String get permManageUsersDesc => 'Add and edit users';

  @override
  String get permManageRoles => 'Manage Roles';

  @override
  String get permManageRolesDesc => 'Manage roles and permissions';

  @override
  String get permViewSettings => 'View Settings';

  @override
  String get permViewSettingsDesc => 'View system settings';

  @override
  String get permEditSettings => 'Edit Settings';

  @override
  String get permEditSettingsDesc => 'Modify system settings';

  @override
  String get permViewAuditLog => 'View Audit Log';

  @override
  String get permViewAuditLogDesc => 'View activity log';

  @override
  String get permManageBackup => 'Manage Backup';

  @override
  String get permManageBackupDesc => 'Backup and restore';

  @override
  String get permCategorySales => 'Sales';

  @override
  String get permCategoryProducts => 'Products';

  @override
  String get permCategoryReports => 'Reports';

  @override
  String get permCategoryCustomers => 'Customers';

  @override
  String get permCategoryShifts => 'Shifts';

  @override
  String get permCategoryUsers => 'Users';

  @override
  String get permCategorySettings => 'Settings';

  @override
  String get permCategorySecurity => 'Security';

  @override
  String get autoBackupEnabled => 'Auto backup enabled';

  @override
  String get autoBackupDisabledLabel => 'Disabled';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get everyHour => 'Every hour';

  @override
  String get dailyBackup => 'Daily';

  @override
  String get weeklyBackup => 'Weekly';

  @override
  String get manualBackupSection => 'Manual Backup';

  @override
  String get createBackupNow => 'Create Backup Now';

  @override
  String get lastBackupTime => 'Last backup: 3 hours ago';

  @override
  String get restoreSection => 'Restore';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get restoreFromBackupDesc => 'Restore data from a previous backup';

  @override
  String get backupHistoryLabel => 'Backup History';

  @override
  String get backupInProgress => 'Creating backup...';

  @override
  String get backupCreated => 'Backup created successfully';

  @override
  String get restoreConfirmTitle => 'Restore from Backup';

  @override
  String get restoreConfirmMessage =>
      'This will replace all current data. This action cannot be undone.';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreInProgress => 'Restoring...';

  @override
  String get restoreComplete => 'Restore complete';

  @override
  String get pasteCode => 'Tempel kode';

  @override
  String devOtpMessage(String otp) {
    return 'Dev OTP: $otp';
  }

  @override
  String get orderHistory => 'Riwayat Pesanan';

  @override
  String get history => 'Riwayat';

  @override
  String get selectDateRange => 'Select Period';

  @override
  String get orderSearchHint => 'Search by order number or customer ID...';

  @override
  String get noOrders => 'Tidak ada pesanan';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusDelivering => 'Delivering';

  @override
  String get filterOrders => 'Filter Orders';

  @override
  String get channelApp => 'App';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get channelPos => 'POS';

  @override
  String get paymentCashType => 'Cash';

  @override
  String get paymentMixed => 'Mixed';

  @override
  String get paymentOnline => 'Online';

  @override
  String get shareAction => 'Bagikan';

  @override
  String get exportOrders => 'Export Orders';

  @override
  String get selectExportFormat => 'Select export format';

  @override
  String get exportedAsExcel => 'Exported as Excel';

  @override
  String get exportedAsPdf => 'Exported as PDF';

  @override
  String get alertSettings => 'Alert Settings';

  @override
  String get acknowledgeAll => 'Terima Semua';

  @override
  String allWithCount(int count) {
    return 'All ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'Low Stock ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'Near Expiry ($count)';
  }

  @override
  String get urgentAlerts => 'Urgent Alerts';

  @override
  String get nearExpiry => 'Near Expiry';

  @override
  String get noAlerts => 'Tidak ada peringatan';

  @override
  String get alertDismissed => 'Peringatan diabaikan';

  @override
  String get undo => 'Urungkan';

  @override
  String get criticalPriority => 'Critical';

  @override
  String get highPriority => 'Urgent';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'Quantity: $current (Minimum: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'Expiry alert';

  @override
  String get currentQuantity => 'Jumlah Saat Ini';

  @override
  String get minimumThreshold => 'Minimum';

  @override
  String get dismissAction => 'Abaikan';

  @override
  String get lowStockNotifications => 'Low Stock Notifications';

  @override
  String get expiryNotifications => 'Expiry Notifications';

  @override
  String get minimumStockLevel => 'Minimum Stock Level';

  @override
  String thresholdUnits(int count) {
    return '$count units';
  }

  @override
  String get acknowledgeAllAlerts => 'Terima Semua Peringatan';

  @override
  String willDismissAlerts(int count) {
    return 'Will dismiss $count alerts';
  }

  @override
  String get allAlertsAcknowledged => 'All alerts acknowledged';

  @override
  String get createPurchaseOrder => 'Create Purchase Order';

  @override
  String productLabelName(String name) {
    return 'Product: $name';
  }

  @override
  String get requiredQuantity => 'Required Quantity';

  @override
  String get createAction => 'Buat';

  @override
  String get purchaseOrderCreated => 'Purchase order created';

  @override
  String get newCategory => 'New Category';

  @override
  String productCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produk',
      zero: 'Tidak ada produk',
    );
    return '$_temp0';
  }

  @override
  String get iconLabel => 'Icon:';

  @override
  String get colorLabel => 'Color:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'Delete category \"$name\"?\n$count products will be moved to \"Uncategorized\".';
  }

  @override
  String productNumber(int number) {
    return 'Product $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price SAR';
  }

  @override
  String get currentlyOpenShift => 'Currently Open Shift';

  @override
  String get since => 'Since';

  @override
  String get transaction => 'transaction';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get openShifts => 'Open Shifts';

  @override
  String get closedShifts => 'Closed Shifts';

  @override
  String get shiftsLog => 'Shifts Log';

  @override
  String get noShiftsToday => 'No shifts today';

  @override
  String get open => 'Open';

  @override
  String get customPeriod => 'Custom Period';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get salesReportDesc => 'Sales and invoices details';

  @override
  String get profitReport => 'Profit Report';

  @override
  String get profitReportDesc => 'Net profit and losses';

  @override
  String get inventoryReport => 'Inventory Report';

  @override
  String get inventoryReportDesc => 'Inventory movements and stocktaking';

  @override
  String get vatReport => 'VAT Report';

  @override
  String get vatReportDesc => 'Value Added Tax 15%';

  @override
  String get customerReport => 'Customer Report';

  @override
  String get customerReportDesc => 'Customer activity and debts';

  @override
  String get purchasesReport => 'Purchases Report';

  @override
  String get purchasesReportDesc => 'Purchase invoices and suppliers';

  @override
  String get costs => 'Costs';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get salesTax => 'Sales Tax';

  @override
  String get purchasesTax => 'Purchases Tax';

  @override
  String get taxDue => 'Tax Due';

  @override
  String get debts => 'Debts';

  @override
  String get paidDebts => 'Paid';

  @override
  String get averageAmount => 'Average';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get todayExpenses => 'Today\'s Expenses';

  @override
  String get transactionCount => 'Transactions Count';

  @override
  String get salaries => 'Salaries';

  @override
  String get rent => 'Rent';

  @override
  String get purchases => 'Purchases';

  @override
  String get noDriversRegistered => 'No drivers registered';

  @override
  String get addDriversForDelivery => 'Add drivers to manage delivery';

  @override
  String get onDelivery => 'On Delivery';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get totalDrivers => 'Total Drivers';

  @override
  String get availableDrivers => 'Available Drivers';

  @override
  String get inDelivery => 'In Delivery';

  @override
  String get excellentRating => 'Excellent Rating';

  @override
  String get delivery => 'delivery';

  @override
  String get track => 'Track';

  @override
  String get percentage => 'Percentage';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get totalUsage => 'Total Usage';

  @override
  String get times => 'times';

  @override
  String get activeOffers => 'Active Offers';

  @override
  String get upcomingOffers => 'Upcoming Offers';

  @override
  String get expiredOffers => 'Expired Offers';

  @override
  String get bundle => 'Bundle';

  @override
  String get dueDebts => 'Due Debts';

  @override
  String get collected => 'Collected';

  @override
  String get newNotification => 'New Notification';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get twoHoursAgo => '2 hours ago';

  @override
  String get trackingMap => 'Tracking Map';

  @override
  String deliveriesToday(int count) {
    return '$count deliveries today';
  }

  @override
  String get assignOrder => 'Assign Order';

  @override
  String get driversTrackingMap => 'Drivers Tracking Map';

  @override
  String get gpsSubscriptionRequired => '(Requires GPS subscription)';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get vehicleHint => 'e.g.: Hilux - White';

  @override
  String get plateNumberLabel => 'Plate Number';

  @override
  String assignOrderTo(String name) {
    return 'Assign order to $name';
  }

  @override
  String get orderLabel => 'Order';

  @override
  String orderAssignedTo(String name) {
    return 'Order assigned to $name';
  }

  @override
  String closingPeriod(String period) {
    return 'Closing period: $period';
  }

  @override
  String lastClosing(String date) {
    return 'Last closing: $date';
  }

  @override
  String get selectedCustomers => 'Selected Customers';

  @override
  String debtLabel(String amount) {
    return 'Debt: $amount SAR';
  }

  @override
  String expectedInterestLabel(String amount) {
    return 'Expected interest: $amount SAR';
  }

  @override
  String selectedCustomerCount(int count) {
    return '$count customer(s) selected';
  }

  @override
  String get processingClose => 'Processing...';

  @override
  String get executeClose => 'Execute Close';

  @override
  String interestWillBeAdded(int count) {
    return 'Interest will be added to $count customer(s)';
  }

  @override
  String get readAll => 'Read All';

  @override
  String get averageExpense => 'Average Expense';

  @override
  String get expensesList => 'Expenses List';

  @override
  String get electricity => 'Electricity';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get services => 'Services';

  @override
  String get expense => 'Expense';

  @override
  String get filterExpenses => 'Filter Expenses';

  @override
  String get openedNotification => 'Opened';

  @override
  String get openTime => 'Open Time';

  @override
  String get closeTime => 'Close Time';

  @override
  String get expectedCash => 'Expected Cash';

  @override
  String get closingCash => 'Closing Cash';

  @override
  String get printAction => 'Print';

  @override
  String get exportAction => 'Export';

  @override
  String get viewReport => 'View Report';

  @override
  String get exportingReport => 'Exporting report...';

  @override
  String get chartsUnderDev => 'Charts under development...';

  @override
  String get reportsAnalysis => 'Performance and sales analysis';

  @override
  String aiAssociationFrequency(
      String productA, String productB, int frequency) {
    return '$productA + $productB: diulang $frequency kali';
  }

  @override
  String aiBundleActivated(String name) {
    return 'Bundel diaktifkan: $name';
  }

  @override
  String aiPromotionsGeneratedCount(int count) {
    return '$count promosi dihasilkan berdasarkan analisis data toko';
  }

  @override
  String aiPromotionApplied(String title) {
    return 'Diterapkan: $title';
  }

  @override
  String aiConfidencePercent(String percent) {
    return 'Kepercayaan: $percent%';
  }

  @override
  String aiAlertsWithCount(int count) {
    return 'Peringatan ($count)';
  }

  @override
  String aiStaffCurrentSuggested(int current, int suggested) {
    return '$current staf saat ini → $suggested disarankan';
  }

  @override
  String aiMinutesAgo(int minutes) {
    return '$minutes menit yang lalu';
  }

  @override
  String aiHoursAgo(int hours) {
    return '$hours jam yang lalu';
  }

  @override
  String aiDaysAgo(int days) {
    return '$days hari yang lalu';
  }

  @override
  String aiDetectedCount(int count) {
    return 'Terdeteksi: $count';
  }

  @override
  String aiMatchedCount(int count) {
    return 'Cocok: $count';
  }

  @override
  String aiAccuracyPercent(String percent) {
    return 'Akurasi: $percent%';
  }

  @override
  String aiProductAccepted(String name) {
    return '$name diterima';
  }

  @override
  String aiErrorOccurred(String error) {
    return 'Terjadi kesalahan: $error';
  }

  @override
  String aiErrorWithMessage(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get aiBasketAnalysis => 'AI Analisis Keranjang';

  @override
  String get aiAssociations => 'Asosiasi';

  @override
  String get aiCrossSell => 'Cross-Sell';

  @override
  String get aiAvgBasketSize => 'Rata-rata Ukuran Keranjang';

  @override
  String get aiProductUnit => 'produk';

  @override
  String get aiAvgBasketValue => 'Rata-rata Nilai Keranjang';

  @override
  String get aiSaudiRiyal => 'SAR';

  @override
  String get aiStrongestAssociation => 'Asosiasi Terkuat';

  @override
  String get aiConversionRate => 'Tingkat Konversi';

  @override
  String get aiFromSuggestions => 'dari saran';

  @override
  String get aiAssistant => 'AI Asisten';

  @override
  String get aiAskAboutStore => 'Tanyakan apa saja tentang toko Anda';

  @override
  String get aiClearChat => 'Hapus Chat';

  @override
  String get aiAssistantReady => 'AI Asisten siap membantu!';

  @override
  String get aiAskAboutSalesStock =>
      'Tanyakan tentang penjualan, stok, pelanggan, atau apa saja tentang toko Anda';

  @override
  String get aiCompetitorAnalysis => 'Analisis Pesaing';

  @override
  String get aiPriceComparison => 'Perbandingan Harga';

  @override
  String get aiTrackedProducts => 'Produk yang Dilacak';

  @override
  String get aiCheaperThanCompetitors => 'Lebih murah dari pesaing';

  @override
  String get aiMoreExpensive => 'Lebih mahal dari pesaing';

  @override
  String get aiAvgPriceDiff => 'Rata-rata Selisih Harga';

  @override
  String get aiSortByName => 'Urutkan berdasarkan nama';

  @override
  String get aiSortByPriceDiff => 'Urutkan berdasarkan selisih harga';

  @override
  String get aiSortByOurPrice => 'Urutkan berdasarkan harga kami';

  @override
  String get aiSortByCategory => 'Urutkan berdasarkan kategori';

  @override
  String get aiSortLabel => 'Urutkan';

  @override
  String get aiPriceIndex => 'Indeks Harga';

  @override
  String get aiQuality => 'Kualitas';

  @override
  String get aiBranches => 'Cabang';

  @override
  String get aiMarkAllRead => 'Tandai semua sebagai dibaca';

  @override
  String get aiNoAlertsCurrently => 'Tidak ada peringatan saat ini';

  @override
  String get aiFraudDetection => 'AI Deteksi Penipuan';

  @override
  String get aiTotalAlerts => 'Total Peringatan';

  @override
  String get aiCriticalAlerts => 'Peringatan Kritis';

  @override
  String get aiNeedsReview => 'Perlu Tinjauan';

  @override
  String get aiRiskLevel => 'Tingkat Risiko';

  @override
  String get aiBehaviorScores => 'Skor Perilaku';

  @override
  String get aiRiskMeter => 'Pengukur Risiko';

  @override
  String get aiHighRisk => 'Risiko Tinggi';

  @override
  String get aiLowRisk => 'Risiko Rendah';

  @override
  String get aiPatternRefund => 'Pengembalian';

  @override
  String get aiPatternAfterHours => 'Di Luar Jam Kerja';

  @override
  String get aiPatternVoid => 'Void';

  @override
  String get aiPatternDiscount => 'Diskon';

  @override
  String get aiPatternSplit => 'Bagi';

  @override
  String get aiPatternCashDrawer => 'Laci Kas';

  @override
  String get aiNoFraudAlerts => 'Tidak ada peringatan';

  @override
  String get aiSelectAlertToInvestigate =>
      'Pilih peringatan dari daftar untuk diselidiki';

  @override
  String get aiStaffAnalytics => 'Analitik Staf';

  @override
  String get aiLeaderboard => 'Papan Peringkat';

  @override
  String get aiIndividualPerformance => 'Kinerja Individu';

  @override
  String get aiAvgPerformance => 'Rata-rata Kinerja';

  @override
  String get aiTotalSalesLabel => 'Total Penjualan';

  @override
  String get aiTotalTransactions => 'Total Transaksi';

  @override
  String get aiAvgVoidRate => 'Rata-rata Tingkat Void';

  @override
  String get aiTeamGrowth => 'Pertumbuhan Tim';

  @override
  String get aiLeaderboardThisWeek => 'Papan Peringkat - Minggu Ini';

  @override
  String get aiSalesForecasting => 'Peramalan Penjualan';

  @override
  String get aiSmartForecastSubtitle =>
      'Analisis cerdas untuk prediksi penjualan masa depan';

  @override
  String get aiForecastAccuracy => 'Akurasi Peramalan';

  @override
  String get aiTrendUp => 'Naik';

  @override
  String get aiTrendDown => 'Turun';

  @override
  String get aiTrendStable => 'Stabil';

  @override
  String get aiNextWeekForecast => 'Peramalan Minggu Depan';

  @override
  String get aiMonthForecast => 'Peramalan Bulan';

  @override
  String get aiForecastSummary => 'Ringkasan Peramalan';

  @override
  String get aiSalesTrendingUp => 'Penjualan meningkat - teruskan!';

  @override
  String get aiSalesDeclining => 'Penjualan menurun - aktifkan penawaran';

  @override
  String get aiSalesStable => 'Penjualan stabil - pertahankan kinerja';

  @override
  String get aiProductRecognition => 'Pengenalan Produk';

  @override
  String get aiSingleProduct => 'Produk Tunggal';

  @override
  String get aiShelfScan => 'Scan Rak';

  @override
  String get aiBarcodeOcr => 'Barcode OCR';

  @override
  String get aiPriceTag => 'Label Harga';

  @override
  String get aiCameraArea => 'Area Kamera';

  @override
  String get aiPointCameraAtProduct => 'Arahkan kamera ke produk atau rak';

  @override
  String get aiStartScan => 'Mulai Scan';

  @override
  String get aiAnalyzingImage => 'Menganalisis gambar...';

  @override
  String get aiStartScanToSeeResults => 'Mulai scan untuk melihat hasil';

  @override
  String get aiScanResults => 'Hasil Scan';

  @override
  String get aiProductSaved => 'Produk berhasil disimpan';

  @override
  String get aiPromotionDesigner => 'AI Perancang Promosi';

  @override
  String get aiSuggestedPromotions => 'Promosi yang Disarankan';

  @override
  String get aiRoiAnalysis => 'Analisis ROI';

  @override
  String get aiAbTest => 'A/B Test';

  @override
  String get aiSmartPromotionDesigner => 'Perancang Promosi Cerdas';

  @override
  String get aiProjectedRevenue => 'Pendapatan yang Diproyeksikan';

  @override
  String get aiAiConfidence => 'Kepercayaan AI';

  @override
  String get aiSelectPromotionForRoi =>
      'Pilih promosi dari tab pertama untuk melihat analisis ROI';

  @override
  String get aiRevenueLabel => 'Pendapatan';

  @override
  String get aiCostLabel => 'Biaya';

  @override
  String get aiDiscountLabel => 'Diskon';

  @override
  String get aiAbTestDescription =>
      'A/B test membagi pelanggan Anda menjadi dua grup dan menunjukkan penawaran berbeda ke setiap grup untuk menentukan yang terbaik.';

  @override
  String get aiAbTestLaunched => 'A/B test berhasil diluncurkan!';

  @override
  String get aiChatWithData => 'Chat dengan Data - AI';

  @override
  String get aiChatWithYourData => 'Chat dengan Data Anda';

  @override
  String get aiAskAboutDataInArabic =>
      'Tanyakan apa saja tentang penjualan, stok, dan pelanggan Anda';

  @override
  String get aiTrySampleQuestions => 'Coba salah satu pertanyaan ini';

  @override
  String get aiTip => 'Tips';

  @override
  String get aiTipDescription =>
      'Anda bisa bertanya dalam Bahasa Indonesia atau Inggris. AI memahami konteks dan memilih cara terbaik untuk menampilkan hasil: angka, tabel, atau grafik.';

  @override
  String get loadingApp => 'Loading...';

  @override
  String get initializingSearch => 'Initializing search...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get initializingDemoData => 'Initializing demo data...';

  @override
  String get pointOfSale => 'Point of Sale';

  @override
  String get managerPinSetup => 'Manager PIN Setup';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get createNewPin => 'Create New PIN';

  @override
  String get reenterPinToConfirm => 'Re-enter PIN to confirm';

  @override
  String get enterFourDigitPin => 'Enter a 4-digit PIN';

  @override
  String get pinsMismatch => 'PINs do not match';

  @override
  String get managerPinCreatedSuccess => 'Manager PIN created successfully';

  @override
  String get enterManagerPin => 'Enter manager PIN';

  @override
  String get operationRequiresApproval =>
      'This operation requires manager approval';

  @override
  String get approvalGranted => 'Approved';

  @override
  String accountLockedWaitMinutes(int minutes) {
    return 'Account locked. Wait $minutes minutes';
  }

  @override
  String wrongPinAttemptsRemaining(int remaining) {
    return 'Wrong PIN. Remaining attempts: $remaining';
  }

  @override
  String get selectYourBranchToContinue => 'Select your branch to continue';

  @override
  String get branchClosed => 'Closed';

  @override
  String get noResultsFoundSearch => 'No results found';

  @override
  String branchSelectedMessage(String branchName) {
    return '$branchName selected';
  }

  @override
  String get shiftIsClosed => 'Shift Closed';

  @override
  String get noOpenShiftCurrently => 'No open shift currently';

  @override
  String get shiftIsOpen => 'Shift Open';

  @override
  String shiftOpenSince(String time) {
    return 'Since: $time';
  }

  @override
  String get balanceSummary => 'Balance Summary';

  @override
  String get cashIncoming => 'Cash In';

  @override
  String get cashOutgoing => 'Cash Out';

  @override
  String get expectedBalance => 'Expected Balance';

  @override
  String get noCashMovementsYet => 'No cash movements yet';

  @override
  String get noteLabel => 'Catatan';

  @override
  String get depositDone => 'Deposit completed';

  @override
  String get withdrawalDone => 'Withdrawal completed';

  @override
  String get amPeriod => 'AM';

  @override
  String get pmPeriod => 'PM';

  @override
  String get newPurchaseInvoice => 'New Purchase Invoice';

  @override
  String get supplierData => 'Supplier Information';

  @override
  String get selectSupplierRequired => 'Select Supplier *';

  @override
  String get supplierInvoiceNumber => 'Supplier Invoice Number';

  @override
  String get noProductsAddedYet => 'No products added yet';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get paidStatus => 'Paid';

  @override
  String get deferredPayment => 'Deferred';

  @override
  String get productNameRequired => 'Product Name *';

  @override
  String get purchasePrice => 'Purchase Price';

  @override
  String get pleaseSelectSupplier => 'Please select a supplier';

  @override
  String purchaseInvoiceSavedTotal(String total) {
    return 'Purchase invoice saved with total $total SAR';
  }

  @override
  String get smartReorderAi => 'AI Smart Reorder';

  @override
  String get smartReorderDescription =>
      'Set your budget and let AI optimize your purchases';

  @override
  String get orderSettings => 'Order Settings';

  @override
  String get availableBudget => 'Available Budget';

  @override
  String get enterAvailableAmount => 'Enter available purchase amount';

  @override
  String supplierLabel(String name) {
    return 'Supplier';
  }

  @override
  String get calculating => 'Calculating...';

  @override
  String get calculateSmartDistribution => 'Calculate Smart Distribution';

  @override
  String get setBudgetAndCalculate => 'Set budget and press calculate';

  @override
  String get numberOfProducts => 'Number of Products';

  @override
  String get suggestedProducts => 'Suggested Products';

  @override
  String get sendOrder => 'Send Order';

  @override
  String get emailLabel => 'Email';

  @override
  String get confirmSending => 'Confirm Sending';

  @override
  String sendOrderToSupplier(String supplier) {
    return 'Send order to $supplier?';
  }

  @override
  String get orderSentSuccess => 'Order sent successfully';

  @override
  String turnoverRate(String rate) {
    return 'Turnover: $rate%';
  }

  @override
  String get editSupplier => 'Edit Supplier';

  @override
  String get addNewSupplier => 'Add New Supplier';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get supplierContactName => 'Supplier / Contact Name *';

  @override
  String get companyNameRequired => 'Company Name *';

  @override
  String get generalCategory => 'General';

  @override
  String get foodMaterials => 'Food Materials';

  @override
  String get beverages => 'Beverages';

  @override
  String get vegetablesFruits => 'Vegetables & Fruits';

  @override
  String get equipment => 'Equipment';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get primaryPhoneRequired => 'Primary Phone *';

  @override
  String get secondaryPhoneOptional => 'Secondary Phone (Optional)';

  @override
  String get emailField => 'Email';

  @override
  String get addressField2 => 'Address';

  @override
  String get commercialInfo => 'Commercial Information';

  @override
  String get taxNumberVat => 'Tax Number (VAT)';

  @override
  String get commercialRegNumber => 'Commercial Registration (CR)';

  @override
  String get financialInfo => 'Financial Information';

  @override
  String get paymentTerms => 'Payment Terms';

  @override
  String get payOnDelivery => 'Pay on Delivery';

  @override
  String get sevenDays => '7 Days';

  @override
  String get fourteenDays => '14 Days';

  @override
  String get thirtyDays => '30 Days';

  @override
  String get sixtyDays => '60 Days';

  @override
  String get bankName => 'Bank Name';

  @override
  String get ibanNumber => 'IBAN Number';

  @override
  String get additionalSettings => 'Additional Settings';

  @override
  String get supplierIsActive => 'Supplier Active';

  @override
  String get notesField => 'Notes';

  @override
  String get savingData => 'Saving...';

  @override
  String get updateSupplier => 'Update Supplier';

  @override
  String get addSupplierBtn => 'Add Supplier';

  @override
  String get deleteSupplier => 'Delete Supplier';

  @override
  String get supplierUpdatedSuccess => 'Supplier updated successfully';

  @override
  String get supplierAddedSuccess => 'Supplier added successfully';

  @override
  String get supplierDeletedSuccess => 'Supplier deleted';

  @override
  String get deleteSupplierConfirmTitle => 'Delete Supplier';

  @override
  String get deleteSupplierConfirmMessage =>
      'Are you sure you want to delete this supplier? This action cannot be undone.';

  @override
  String get supplierDetailsTitle => 'Supplier Details';

  @override
  String get backButton => 'Back';

  @override
  String get editButton => 'Edit';

  @override
  String get newPurchaseOrder => 'New Purchase Order';

  @override
  String get deleteButton => 'Delete';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get supplierEmailLabel => 'Email';

  @override
  String get supplierAddressLabel => 'Address';

  @override
  String get dueToSupplier => 'Due to Supplier';

  @override
  String get balanceInOurFavor => 'Balance in Our Favor';

  @override
  String get paymentBtn => 'Pay';

  @override
  String get totalPurchasesLabel => 'Total Purchases';

  @override
  String get lastPurchaseDate => 'Last Purchase';

  @override
  String get recentPurchases => 'Recent Purchases';

  @override
  String get noPurchasesYet => 'No purchases yet';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get deleteSupplierDialogTitle => 'Delete Supplier';

  @override
  String get deleteSupplierDialogMessage =>
      'All supplier data will be deleted. Continue?';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get employeeRole => 'Employee';

  @override
  String get operationCount => 'operation';

  @override
  String get dayCount => 'day';

  @override
  String get personalInfoSection => 'Personal Information';

  @override
  String get emailInfoLabel => 'Email';

  @override
  String get phoneInfoLabel => 'Phone';

  @override
  String get branchInfoLabel => 'Branch';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get mainBranchDefault => 'Main Branch';

  @override
  String get changePassword => 'Change Password';

  @override
  String get activityLogLink => 'Activity Log';

  @override
  String get logoutButton => 'Logout';

  @override
  String get systemAdminRole => 'System Admin';

  @override
  String get noBranchesRegistered => 'No branches registered';

  @override
  String get branchEmailLabel => 'Email';

  @override
  String get branchCityLabel => 'City';

  @override
  String get importSupplierInvoice => 'Import Supplier Invoice';

  @override
  String get captureOrSelectPhoto =>
      'Capture a photo or select from gallery\nData will be extracted automatically';

  @override
  String get captureImage => 'Capture Image';

  @override
  String get galleryPick => 'Gallery';

  @override
  String get anotherImage => 'Another Image';

  @override
  String get aiProcessingBtn => 'AI Processing';

  @override
  String get processingInvoice => 'Processing invoice...';

  @override
  String get extractingDataWithAi => 'Extracting data with AI';

  @override
  String get dataExtracted => 'Data Extracted';

  @override
  String get purchaseInvoiceCreated => 'Purchase invoice created';

  @override
  String get reviewInvoice => 'Review Invoice';

  @override
  String get confirmAllItems => 'Confirm All';

  @override
  String get unknownSupplier => 'Unknown Supplier';

  @override
  String itemCount(int count) {
    return '$count item';
  }

  @override
  String progressLabel(int confirmed, int total) {
    return 'Progress: $confirmed / $total';
  }

  @override
  String needsReviewCount(int count) {
    return '$count needs review';
  }

  @override
  String get notMatchedStatus => 'Not Matched';

  @override
  String get matchedStatus => 'Matched';

  @override
  String get matchedProductLabel => 'Matched Product';

  @override
  String matchedWithName(String name) {
    return 'Matched: $name';
  }

  @override
  String get searchForProduct => 'Search for product...';

  @override
  String get createNewProduct => 'Create New Product';

  @override
  String get savingInvoice => 'Saving...';

  @override
  String get invoiceSavedSuccess => 'Purchase invoice saved successfully';

  @override
  String get customerAnalytics => 'Customer Analytics';

  @override
  String get weekPeriod => 'Week';

  @override
  String get monthPeriod => 'Month';

  @override
  String get yearPeriod => 'Year';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String get newCustomers => 'New Customers';

  @override
  String get returningCustomers => 'Returning Customers';

  @override
  String get averageSpending => 'Average Spending';

  @override
  String get topCustomers => 'Top Customers';

  @override
  String orderCount(int count) {
    return '$count orders';
  }

  @override
  String get customerDistribution => 'Customer Distribution';

  @override
  String get vipCustomers => 'VIP (over 5,000 SAR)';

  @override
  String get regularCustomers => 'Regular (1,000-5,000 SAR)';

  @override
  String get normalCustomers => 'Normal (under 1,000 SAR)';

  @override
  String get customerActivity => 'Customer Activity';

  @override
  String get activeLabel => 'Active';

  @override
  String get dormantLabel => 'Dormant';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get noPrintJobsPending => 'No pending print jobs';

  @override
  String get printerConnected => 'Printer connected';

  @override
  String get totalPrintLabel => 'Total';

  @override
  String get waitingPrintLabel => 'Waiting';

  @override
  String get failedPrintLabel => 'Failed';

  @override
  String pendingJobsCount(int count) {
    return '$count pending jobs';
  }

  @override
  String get printingInProgress => 'Printing...';

  @override
  String get failedRetry => 'Failed - Try again';

  @override
  String get waitingStatus => 'Waiting';

  @override
  String printingOrderId(String orderId) {
    return 'Printing $orderId...';
  }

  @override
  String get allJobsPrinted => 'All jobs printed';

  @override
  String get clearPrintQueueTitle => 'Clear Print Queue';

  @override
  String get clearPrintQueueConfirm => 'Clear all pending print jobs?';

  @override
  String get clearBtn => 'Clear';

  @override
  String get gotIt => 'Mengerti';

  @override
  String get print => 'Cetak';

  @override
  String get display => 'Display';

  @override
  String get item => 'Item';

  @override
  String get invoice => 'Faktur';

  @override
  String get accept => 'Terima';

  @override
  String get details => 'Detail';

  @override
  String get newLabel => 'Baru';

  @override
  String get mixed => 'Campuran';

  @override
  String get lowStockLabel => 'Rendah';

  @override
  String get stocktakingTitle => 'Stok Opname';

  @override
  String get expectedQty => 'Diharapkan';

  @override
  String get countedQty => 'Dihitung';

  @override
  String get stockDelta => 'Selisih';

  @override
  String get saveAllAdjustments => 'Simpan penyesuaian';

  @override
  String stocktakingSavedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count penyesuaian disimpan',
      one: '1 penyesuaian disimpan',
      zero: 'Tidak ada penyesuaian',
    );
    return '$_temp0';
  }

  @override
  String stocktakingAdjustedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count penyesuaian',
      one: '1 penyesuaian',
    );
    return '$_temp0';
  }

  @override
  String get stockTransfersTitle => 'Transfer antar cabang';

  @override
  String get stockTransferNewTitle => 'Transfer stok baru';

  @override
  String get stockTransferTabOutgoing => 'Keluar';

  @override
  String get stockTransferTabIncoming => 'Masuk';

  @override
  String get stockTransferFromStore => 'Dari cabang';

  @override
  String get stockTransferToStore => 'Ke cabang';

  @override
  String get stockTransferAddItem => 'Tambah item';

  @override
  String get stockTransferNoItems => 'Belum ada item yang ditambahkan';

  @override
  String get stockTransferCreate => 'Buat transfer';

  @override
  String get stockTransferApprove => 'Setujui';

  @override
  String get stockTransferReceive => 'Terima';

  @override
  String get stockTransferReject => 'Tolak';

  @override
  String get stockTransferStatusPending => 'Tertunda';

  @override
  String get stockTransferStatusApproved => 'Disetujui';

  @override
  String get stockTransferStatusInTransit => 'Dalam perjalanan';

  @override
  String get stockTransferStatusReceived => 'Diterima';

  @override
  String get stockTransferStatusCancelled => 'Dibatalkan';

  @override
  String get stockTransferNoOutgoing => 'Tidak ada transfer keluar';

  @override
  String get stockTransferNoIncoming => 'Tidak ada transfer masuk';

  @override
  String get stockTransferCreatedSuccess => 'Transfer dibuat';

  @override
  String stockTransferItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get debtor => 'Debtor';

  @override
  String get creditor => 'Creditor';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get returnLabel => 'Pengembalian';

  @override
  String get skip => 'Lewati';

  @override
  String get send => 'Kirim';

  @override
  String get cloud => 'Cloud';

  @override
  String get defaultLabel => 'Default';

  @override
  String get closed => 'Tutup';

  @override
  String get owes => 'Owes';

  @override
  String get due => 'Jatuh tempo';

  @override
  String get balanced => 'Balanced';

  @override
  String get offlineModeTitle => 'Offline Mode';

  @override
  String get offlineModeDescription => 'You can continue using the app:';

  @override
  String get offlineCanSell => 'Make sales';

  @override
  String get offlineCanAddToCart => 'Add products to cart';

  @override
  String get offlineCanPrint => 'Print receipts';

  @override
  String get offlineAutoSync =>
      'Data will sync automatically when connection is restored.';

  @override
  String get offlineSavingLocally => 'Offline - saving operations locally';

  @override
  String get seconds => 'Detik';

  @override
  String get errors => 'Error';

  @override
  String get syncLabel => 'Sync';

  @override
  String get slow => 'Lambat';

  @override
  String get myGrocery => 'My Grocery';

  @override
  String get cashier => 'Kasir';

  @override
  String get goBack => 'Kembali';

  @override
  String get menuLabel => 'Menu';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get diamond => 'Diamond';

  @override
  String get bronze => 'Bronze';

  @override
  String get saudiArabia => 'Saudi Arabia';

  @override
  String get uae => 'UAE';

  @override
  String get kuwait => 'Kuwait';

  @override
  String get bahrain => 'Bahrain';

  @override
  String get qatar => 'Qatar';

  @override
  String get oman => 'Oman';

  @override
  String get control => 'Control';

  @override
  String get strong => 'Kuat';

  @override
  String get medium => 'Sedang';

  @override
  String get weak => 'Lemah';

  @override
  String get good => 'Baik';

  @override
  String get danger => 'Bahaya';

  @override
  String get currentLabel => 'Saat Ini';

  @override
  String get suggested => 'Suggested';

  @override
  String get actual => 'Actual';

  @override
  String get forecast => 'Prakiraan';

  @override
  String get critical => 'Critical';

  @override
  String get high => 'Tinggi';

  @override
  String get low => 'Rendah';

  @override
  String get investigation => 'Investigation';

  @override
  String get apply => 'Terapkan';

  @override
  String get run => 'Jalankan';

  @override
  String get positive => 'Positive';

  @override
  String get neutral => 'Neutral';

  @override
  String get negative => 'Negative';

  @override
  String get elastic => 'Elastic';

  @override
  String get demand => 'Permintaan';

  @override
  String get quality => 'Kualitas';

  @override
  String get luxury => 'Luxury';

  @override
  String get economic => 'Economic';

  @override
  String get ourStore => 'Our Store';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get cost => 'Biaya';

  @override
  String get duration => 'Durasi';

  @override
  String get quiet => 'Quiet';

  @override
  String get busy => 'Busy';

  @override
  String get outstanding => 'Belum dibayar';

  @override
  String get donate => 'Donate';

  @override
  String get day => 'Hari';

  @override
  String get days => 'Hari';

  @override
  String get projected => 'Projected';

  @override
  String get analysis => 'Analisis';

  @override
  String get review => 'Tinjauan';

  @override
  String get productCategory => 'Kategori';

  @override
  String get ourPrice => 'Our Price';

  @override
  String get position => 'Posisi';

  @override
  String get cheapest => 'Termurah';

  @override
  String get mostExpensive => 'Most Expensive';

  @override
  String get soldOut => 'Habis';

  @override
  String get noDataAvailable => 'Tidak ada data tersedia';

  @override
  String get noDataFoundMessage => 'No data was found';

  @override
  String get noSearchResultsFound => 'No results found';

  @override
  String get noProductsFound => 'Produk tidak ditemukan';

  @override
  String get noCustomers => 'Tidak ada pelanggan';

  @override
  String get addCustomersToStart => 'Add new customers to start';

  @override
  String get noOrdersYet => 'You haven\'t made any orders yet';

  @override
  String get noConnection => 'No connection';

  @override
  String get checkInternet => 'Periksa koneksi internet Anda';

  @override
  String get cartIsEmpty => 'Keranjang kosong';

  @override
  String get browseProducts => 'Jelajahi Produk';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get paidLabel => 'Dibayar';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get completeLabel => 'Complete';

  @override
  String get addPayment => 'Add';

  @override
  String get payments => 'Pembayaran';

  @override
  String get now => 'Sekarang';

  @override
  String get ecommerce => 'Online Store';

  @override
  String get ecommerceSection => 'E-Commerce';

  @override
  String get wallet => 'Wallet';

  @override
  String get subscription => 'Subscription';

  @override
  String get complaintsReport => 'Complaints Report';

  @override
  String get mediaLibrary => 'Media Library';

  @override
  String get deviceLog => 'Device Log';

  @override
  String get shippingGateways => 'Shipping Gateways';

  @override
  String get systemSection => 'System';

  @override
  String get averageInvoice => 'Rata-rata Faktur';

  @override
  String errorPrefix(String message, Object error) {
    return 'Error: $error';
  }

  @override
  String get vipMember => 'VIP Member';

  @override
  String get activeSuppliers => 'Pemasok Aktif';

  @override
  String get duePayments => 'Due Payments';

  @override
  String get productCatalog => 'Product Catalog';

  @override
  String get comingSoonBrowseSuppliers =>
      'Coming Soon - Browse supplier products';

  @override
  String get comingSoonTag => 'Coming Soon';

  @override
  String get supplierNotFound => 'Supplier not found';

  @override
  String get viewAllPurchases => 'View All Purchases';

  @override
  String get completedLabel => 'Completed';

  @override
  String get pendingStatusLabel => 'Pending';

  @override
  String get registerPayment => 'Register Payment';

  @override
  String errorLoadingSuppliers(Object error) {
    return 'Error loading suppliers: $error';
  }

  @override
  String get cancelLabel => 'Batal';

  @override
  String get addLabel => 'Tambah';

  @override
  String get saveLabel => 'Simpan';

  @override
  String purchaseInvoiceSaved(Object total) {
    return 'Purchase invoice saved - Total: $total SAR';
  }

  @override
  String errorSavingPurchase(Object error) {
    return 'Error saving purchase: $error';
  }

  @override
  String get smartReorderTitle => 'Smart Reorder';

  @override
  String get smartReorderAiTitle => 'AI Smart Reorder';

  @override
  String get budgetDescription =>
      'Set the budget and the system will distribute it based on turnover rate';

  @override
  String get enterValidBudget => 'Please enter a valid budget';

  @override
  String get confirmSendTitle => 'Confirm Send';

  @override
  String sendOrderToMsg(Object supplier) {
    return 'Send order to $supplier?';
  }

  @override
  String get orderSentSuccessMsg => 'Order sent successfully';

  @override
  String sendingOrderVia(Object method) {
    return 'Sending order via $method...';
  }

  @override
  String stockQuantity(Object qty) {
    return 'Stock: $qty';
  }

  @override
  String turnoverLabel(Object rate) {
    return 'Turnover: $rate%';
  }

  @override
  String failedCapture(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String failedPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedProcessInvoice(Object error) {
    return 'Failed to process invoice: $error';
  }

  @override
  String matchLabel(Object name) {
    return 'Match: $name';
  }

  @override
  String suggestedProduct(Object index) {
    return 'Suggested Product $index';
  }

  @override
  String get barcodeLabel => 'Barcode: 123456789';

  @override
  String get purchaseInvoiceSavedSuccess =>
      'Purchase invoice saved successfully';

  @override
  String get aiImportedInvoice => 'AI imported invoice';

  @override
  String aiInvoiceNote(Object number) {
    return 'AI Invoice: $number';
  }

  @override
  String get supplierCanCreateOrders =>
      'Can create purchase orders from this supplier';

  @override
  String get notesFieldHint => 'Any additional notes about the supplier...';

  @override
  String get deleteConfirmCancel => 'Cancel';

  @override
  String get deleteConfirmBtn => 'Hapus';

  @override
  String get supplierUpdatedMsg => 'Supplier data updated';

  @override
  String errorOccurredMsg(Object error) {
    return 'Error occurred: $error';
  }

  @override
  String errorDuringDeleteMsg(Object error) {
    return 'Error during delete: $error';
  }

  @override
  String get fortyFiveDays => '45 Days';

  @override
  String get expenseCategoriesTitle => 'Expense Categories';

  @override
  String get noCategoriesFound => 'No expense categories found';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get spentAmount => 'Spent';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get overBudget => 'Over Budget';

  @override
  String expenseCount(Object count) {
    return '$count expenses';
  }

  @override
  String spentLabel(Object amount) {
    return 'Spent: $amount SAR';
  }

  @override
  String remainingLabel2(Object amount) {
    return 'Remaining: $amount SAR';
  }

  @override
  String expensesThisMonth(Object count) {
    return '$count expenses this month';
  }

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String expenseNumber(Object id) {
    return 'Expense #$id';
  }

  @override
  String get budgetLabel => 'Anggaran';

  @override
  String get monthlyBudgetLabel => 'Monthly Budget';

  @override
  String get categoryNameHint => 'Example: Employee Salaries';

  @override
  String get productNameLabel => 'Product Name *';

  @override
  String get quantityLabel => 'Jumlah';

  @override
  String get purchasePriceLabel => 'Purchase Price';

  @override
  String get saveInvoiceBtn => 'Save Invoice';

  @override
  String get ibanLabel => 'IBAN Account Number';

  @override
  String get supplierActiveLabel => 'Supplier Active';

  @override
  String get notesLabel => 'Catatan';

  @override
  String get deleteSupplierConfirm =>
      'Are you sure you want to delete this supplier? All associated data will be deleted.';

  @override
  String get supplierDeletedMsg => 'Supplier deleted';

  @override
  String get savingLabel => 'Saving...';

  @override
  String get supplierDetailTitle => 'Supplier Details';

  @override
  String get supplierNotFoundMsg => 'Supplier not found';

  @override
  String get lastPurchaseLabel => 'Last Purchase';

  @override
  String get recentPurchasesLabel => 'Recent Purchases';

  @override
  String get noPurchasesLabel => 'No purchases yet';

  @override
  String get supplierAddedMsg => 'Supplier added';

  @override
  String get openingCashLabel => 'Opening Cash';

  @override
  String get importantNotes => 'Important Notes';

  @override
  String get countCashBeforeShift =>
      'Make sure to count the cash in the drawer before opening the shift';

  @override
  String get shiftTimeAutoRecorded =>
      'Shift open time will be recorded automatically';

  @override
  String get oneShiftAtATime =>
      'Cannot open more than one shift at the same time';

  @override
  String get pleaseEnterOpeningCash =>
      'Please enter opening cash amount (greater than zero)';

  @override
  String shiftOpenedWithAmount(String amount, String currency) {
    return 'Shift opened with $amount $currency';
  }

  @override
  String get errorOpeningShift => 'Error opening shift';

  @override
  String get noOpenShift => 'No open shift';

  @override
  String get shiftInfoLabel => 'Shift Information';

  @override
  String get salesSummaryLabel => 'Sales Summary';

  @override
  String get cashRefundsLabel => 'Cash Refunds';

  @override
  String get cashDepositLabel => 'Cash Deposit';

  @override
  String get cashWithdrawalLabel => 'Cash Withdrawal';

  @override
  String get expectedInDrawer => 'Expected in Drawer';

  @override
  String get actualCashInDrawer => 'Actual Cash in Drawer';

  @override
  String get drawerMatched => 'Matched';

  @override
  String get surplusStatus => 'Surplus';

  @override
  String get deficitStatus => 'Deficit';

  @override
  String expectedAmountCurrency(String amount, String currency) {
    return 'Expected: $amount $currency';
  }

  @override
  String actualAmountCurrency(String amount, String currency) {
    return 'Actual: $amount $currency';
  }

  @override
  String get drawerMatchedMessage => 'Drawer is matched';

  @override
  String surplusAmount(String amount, String currency) {
    return 'Surplus: +$amount $currency';
  }

  @override
  String deficitAmount(String amount, String currency) {
    return 'Deficit: $amount $currency';
  }

  @override
  String get confirmCloseShift => 'Do you want to close the shift?';

  @override
  String get errorClosingShift => 'Error closing shift';

  @override
  String get shiftClosedSuccessfully => 'Shift closed successfully';

  @override
  String get shiftStatsLabel => 'Shift Statistics';

  @override
  String get shiftDurationLabel => 'Shift Duration';

  @override
  String get invoiceCountLabel => 'Invoice Count';

  @override
  String get invoiceUnit => 'invoice';

  @override
  String get cardSalesLabel => 'Card Sales';

  @override
  String get cashSalesLabel => 'Cash Sales';

  @override
  String get refundsLabel => 'Refunds';

  @override
  String get expectedInDrawerLabel => 'Expected in Drawer';

  @override
  String get actualInDrawerLabel => 'Actual in Drawer';

  @override
  String get differenceLabel => 'Difference';

  @override
  String get printingReport => 'Printing report...';

  @override
  String get sharingInProgress => 'Sharing...';

  @override
  String get openNewShift => 'Open New Shift';

  @override
  String hoursAndMinutes(int hours, int minutes) {
    return '$hours hours $minutes minutes';
  }

  @override
  String hoursOnly(int hours) {
    return '$hours hours';
  }

  @override
  String minutesOnly(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get rejectedNotApproved => 'Operation rejected - not approved';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get inventoryManagement => 'Manage & track inventory';

  @override
  String get bulkEdit => 'Bulk Edit';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get inventoryValue => 'Inventory Value';

  @override
  String get exportInventoryReport => 'Export Inventory Report';

  @override
  String get printOrderList => 'Print Order List';

  @override
  String get inventoryMovementLog => 'Inventory Movement Log';

  @override
  String get editSelected => 'Edit Selected';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get noOutOfStockProducts => 'No out of stock products';

  @override
  String get allProductsAvailable => 'All products are available in stock';

  @override
  String get editStock => 'Edit Stock';

  @override
  String get newQuantity => 'New Quantity';

  @override
  String get receiveGoods => 'Receive Goods';

  @override
  String get damaged => 'Rusak';

  @override
  String get correction => 'Correction';

  @override
  String get stockUpdatedTo => 'Stock updated for';

  @override
  String get featureUnderDevelopment => 'This feature is under development...';

  @override
  String get newest => 'Newest';

  @override
  String get adjustStock => 'Sesuaikan Stok';

  @override
  String get adjustmentHistory => 'Adjustment History';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get selectProduct => 'Select Product';

  @override
  String get subtract => 'Kurangi';

  @override
  String get setQuantity => 'Atur';

  @override
  String get enterQuantity => 'Masukkan jumlah';

  @override
  String get enterValidQuantity => 'Enter valid quantity';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get enterAdditionalNotes => 'Enter any additional notes...';

  @override
  String get adjustmentSummary => 'Adjustment Summary';

  @override
  String get newStock => 'New Stock';

  @override
  String get warningNegativeStock => 'Warning: Stock will become negative!';

  @override
  String get saving => 'Saving...';

  @override
  String get storeNotSelected => 'Store not selected';

  @override
  String get noInventoryMovements => 'No inventory movements';

  @override
  String get adjustmentSavedSuccess => 'Adjustment saved successfully';

  @override
  String get errorSaving => 'Error saat menyimpan';

  @override
  String get enterBarcode => 'Masukkan barcode';

  @override
  String get theft => 'Theft';

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get stockTransfer => 'Stock Transfer';

  @override
  String get newTransfer => 'New Transfer';

  @override
  String get fromBranch => 'From Branch';

  @override
  String get toBranch => 'To Branch';

  @override
  String get selectSourceBranch => 'Select source branch';

  @override
  String get selectTargetBranch => 'Select target branch';

  @override
  String get selectProductsForTransfer => 'Select products for transfer';

  @override
  String get creating => 'Creating...';

  @override
  String get createTransferRequest => 'Create Transfer Request';

  @override
  String get errorLoadingTransfers => 'Error loading transfers';

  @override
  String get noPreviousTransfers => 'No previous transfers';

  @override
  String get approved => 'Disetujui';

  @override
  String get inTransit => 'In Transit';

  @override
  String get complete => 'Selesai';

  @override
  String get completeTransfer => 'Complete Transfer';

  @override
  String get completeTransferConfirm =>
      'Do you want to complete this transfer? Quantities will be deducted from source and added to target branch.';

  @override
  String get transferCompletedSuccess => 'Transfer completed and stock updated';

  @override
  String get errorCompletingTransfer => 'Error completing transfer';

  @override
  String get transferCreatedSuccess => 'Transfer request created successfully';

  @override
  String get errorCreatingTransfer => 'Error creating transfer';

  @override
  String get stockTake => 'Stock Take';

  @override
  String get startStockTake => 'Start Stock Take';

  @override
  String get counted => 'Counted';

  @override
  String get variances => 'Variances';

  @override
  String get of_ => 'of';

  @override
  String get system => 'Sistem';

  @override
  String get count => 'Jumlah';

  @override
  String get finishStockTake => 'Finish Stock Take';

  @override
  String get stockTakeDescription =>
      'Count stock products and compare with system';

  @override
  String get noProductsInStock => 'No products in stock';

  @override
  String get noProductsToCount => 'No products to start counting';

  @override
  String get errorCreatingStockTake => 'Error creating stock take';

  @override
  String get saveStockTakeConfirm =>
      'Save stock take results and update inventory?';

  @override
  String get stockTakeSavedSuccess =>
      'Stock take saved and inventory updated successfully';

  @override
  String get errorCompletingStockTake => 'Error completing stock take';

  @override
  String get stockTakeHistory => 'Stock Take History';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get noStockTakeHistory => 'No previous stock take history';

  @override
  String get inProgress => 'In Progress';

  @override
  String get expiryTracking => 'Expiry Tracking';

  @override
  String get errorLoadingExpiryData => 'Error loading expiry data';

  @override
  String get withinMonth => 'Within Month';

  @override
  String get noProductsExpiringIn7Days => 'No products expiring in 7 days';

  @override
  String get noProductsExpiringInMonth => 'No products expiring in a month';

  @override
  String get noExpiredProducts => 'No expired products';

  @override
  String get batch => 'Batch';

  @override
  String expiredSinceDays(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get remove => 'Hapus';

  @override
  String get pressToAddExpiryTracking => 'Press + to add new expiry tracking';

  @override
  String get applyDiscountTo => 'Apply discount to';

  @override
  String get confirmRemoval => 'Confirm Removal';

  @override
  String get removeExpiryTrackingFor => 'Remove expiry tracking for';

  @override
  String get expiryTrackingRemoved => 'Expiry tracking removed';

  @override
  String get errorRemovingExpiryTracking => 'Error removing expiry tracking';

  @override
  String get addExpiryDate => 'Add Expiry Date';

  @override
  String get barcodeOrProductName => 'Barcode or product name';

  @override
  String get selectDate => 'Pilih tanggal';

  @override
  String get batchNumberOptional => 'Batch number (optional)';

  @override
  String get expiryTrackingAdded => 'Expiry tracking added successfully';

  @override
  String get errorAddingExpiryTracking => 'Error adding expiry tracking';

  @override
  String get barcodeScanner2 => 'Barcode Scanner';

  @override
  String get scanning => 'Scanning...';

  @override
  String get pressToStart => 'Press to start';

  @override
  String get stop => 'Berhenti';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get enterBarcodeManually => 'Enter barcode manually';

  @override
  String get noScannedProducts => 'No scanned products';

  @override
  String get enterBarcodeToSearch => 'Enter barcode to search database';

  @override
  String get useManualInputToSearch =>
      'Use manual input to search for products';

  @override
  String get found => 'Ditemukan';

  @override
  String get productNotFoundForBarcode => 'Product not found';

  @override
  String get addNewProduct => 'Tambah Produk Baru';

  @override
  String get willOpenAddProductScreen => 'Will open add product screen';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get addedToCart => 'Ditambahkan';

  @override
  String get barcodePrint => 'Barcode Print';

  @override
  String get noProductsWithBarcode => 'No products with barcode';

  @override
  String get addBarcodeFirst => 'Add barcode to products first';

  @override
  String get searchProduct => 'Cari produk...';

  @override
  String get totalLabels => 'Total Labels';

  @override
  String get printLabels => 'Print Labels';

  @override
  String get printList => 'Print List';

  @override
  String get selectProductsToPrint => 'Select products to print';

  @override
  String get willPrint => 'Will print';

  @override
  String get label => 'label';

  @override
  String get printing => 'Printing...';

  @override
  String get messageAddedToQueue => 'Message added to send queue';

  @override
  String get messageSendFailed => 'Failed to send message';

  @override
  String get noPhoneForCustomer => 'No phone number for customer';

  @override
  String get inputContainsDangerousContent =>
      'Input contains prohibited content';

  @override
  String whatsappGreeting(String name) {
    return 'Hello $name\nHow can we help you?';
  }

  @override
  String get segmentVip => 'VIP';

  @override
  String get segmentRegular => 'Regular';

  @override
  String get segmentAtRisk => 'At Risk';

  @override
  String get segmentLost => 'Lost';

  @override
  String get segmentNewCustomer => 'New';

  @override
  String customerCount(int count) {
    return '$count pelanggan';
  }

  @override
  String revenueK(String amount) {
    return '${amount}K SAR';
  }

  @override
  String get tabRecommendations => 'Recommendations';

  @override
  String get tabRepurchase => 'Repurchase';

  @override
  String get tabSegments => 'Segments';

  @override
  String lastVisitLabel(String time) {
    return 'Last visit: $time';
  }

  @override
  String visitCountLabel(int count) {
    return '$count visits';
  }

  @override
  String avgSpendLabel(String amount) {
    return 'Avg: $amount SAR';
  }

  @override
  String totalSpentLabel(String amount) {
    return 'Total: ${amount}K SAR';
  }

  @override
  String get recommendedProducts => 'Recommended Products';

  @override
  String get sendWhatsAppOffer => 'Send WhatsApp Offer';

  @override
  String get totalRevenueLabel => 'Total Revenue';

  @override
  String get avgSpendStat => 'Average Spend';

  @override
  String amountSar(String amount) {
    return '$amount SAR';
  }

  @override
  String get specialOfferMissYou => 'Special offer for you! We miss your visit';

  @override
  String friendlyReminderPurchase(String product) {
    return 'Friendly reminder to purchase $product';
  }

  @override
  String get timeAgoToday => 'Today';

  @override
  String get timeAgoYesterday => 'Yesterday';

  @override
  String timeAgoDays(int days) {
    return '$days days ago';
  }

  @override
  String get riskAnalysisTab => 'Risk Analysis';

  @override
  String get preventiveActionsTab => 'Preventive Actions';

  @override
  String errorOccurredDetail(String error) {
    return 'Error occurred: $error';
  }

  @override
  String get returnRateTitle => 'Return Rate';

  @override
  String get avgLast6Months => 'Average last 6 months';

  @override
  String get amountAtRiskTitle => 'Amount at Risk';

  @override
  String get highRiskOperations => 'High Risk Operations';

  @override
  String get needsImmediateAction => 'Needs immediate action';

  @override
  String get returnTrendTitle => 'Return Trend';

  @override
  String operationsAtRiskCount(int count) {
    return 'Operations at risk ($count)';
  }

  @override
  String get riskFilterAll => 'All';

  @override
  String get riskFilterVeryHigh => 'Very High';

  @override
  String get riskFilterHigh => 'High';

  @override
  String get riskFilterMedium => 'Medium';

  @override
  String get riskFilterLow => 'Low';

  @override
  String get totalExpectedSavings => 'Total Expected Savings';

  @override
  String fromPreventiveActions(int count) {
    return 'From $count preventive actions';
  }

  @override
  String get suggestedPreventiveActions => 'Suggested Preventive Actions';

  @override
  String get applyPreventiveHint =>
      'Apply these actions to reduce returns and increase customer satisfaction';

  @override
  String actionApplied(String action) {
    return 'Applied: $action';
  }

  @override
  String actionDismissed(String action) {
    return 'Dismissed: $action';
  }

  @override
  String get veryPositiveSentiment => 'Very Positive';

  @override
  String get positiveSentiment => 'Positive';

  @override
  String get neutralSentiment => 'Neutral';

  @override
  String get negativeSentiment => 'Negative';

  @override
  String get veryNegativeSentiment => 'Very Negative';

  @override
  String get ratingsDistribution => 'Ratings Distribution';

  @override
  String get sentimentTrendTitle => 'Sentiment Trend';

  @override
  String get sentimentIndicator => 'Sentiment Indicator';

  @override
  String minutesAgoSentiment(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgoSentiment(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgoSentiment(int count) {
    return '$count days ago';
  }

  @override
  String get totalProductsTitle => 'Total Products';

  @override
  String get categoryATitle => 'Category A';

  @override
  String get mostImportant => 'Most Important';

  @override
  String get withinDays => 'Within 7 days';

  @override
  String get needReorder => 'Need Reorder';

  @override
  String estimatedLossSar(String amount) {
    return '$amount SAR estimated loss';
  }

  @override
  String get tabAbcAnalysis => 'ABC Analysis';

  @override
  String get tabWastePrediction => 'Waste Prediction';

  @override
  String get tabReorder => 'Reorder';

  @override
  String get filterAllLabel => 'Semua';

  @override
  String get categoryALabel => 'Category A';

  @override
  String get categoryBLabel => 'Category B';

  @override
  String get categoryCLabel => 'Category C';

  @override
  String orderUnitsSnack(int qty, String name) {
    return 'Order $qty units of $name';
  }

  @override
  String get urgencyCritical => 'Critical';

  @override
  String get urgencyHigh => 'High';

  @override
  String get urgencyMedium => 'Medium';

  @override
  String get urgencyLow => 'Low';

  @override
  String get currentStockLabel => 'Current Stock';

  @override
  String get reorderPointLabel => 'Reorder Point';

  @override
  String get suggestedQtyLabel => 'Suggested Qty';

  @override
  String get daysOfStockLabel => 'Days of Stock';

  @override
  String estimatedCostLabel(String amount) {
    return 'Estimated cost: $amount SAR';
  }

  @override
  String purchaseOrderCreatedFor(String name) {
    return 'Purchase order created: $name';
  }

  @override
  String orderUnitsButton(int qty) {
    return 'Order $qty units';
  }

  @override
  String get actionDiscount => 'Diskon';

  @override
  String get actionTransfer => 'Transfer';

  @override
  String get actionDonate => 'Donasi';

  @override
  String actionOnProduct(String name) {
    return 'Action on: $name';
  }

  @override
  String get totalSuggestionsLabel => 'Total Suggestions';

  @override
  String get canIncreaseLabel => 'Can Increase';

  @override
  String get shouldDecreaseLabel => 'Should Decrease';

  @override
  String get expectedMonthlyImpact => 'Expected Monthly Impact';

  @override
  String get noSuggestionsInFilter => 'No suggestions in this filter';

  @override
  String get selectProductForDetails => 'Select a product to view details';

  @override
  String get selectProductHint =>
      'Click on a product from the list to view impact calculator and demand elasticity';

  @override
  String priceApplied(String price, String product) {
    return 'Price $price SAR applied to $product';
  }

  @override
  String errorOccurredShort(String error) {
    return 'Error: $error';
  }

  @override
  String get readyTemplates => 'Ready Templates';

  @override
  String get hideTemplates => 'Hide Templates';

  @override
  String get showTemplates => 'Show Templates';

  @override
  String get askAboutStore => 'Ask any question about your store';

  @override
  String get writeQuestionHint =>
      'Write your question and we will generate the appropriate report automatically';

  @override
  String get quickActionTodaySales => 'How much sales today?';

  @override
  String get quickActionTop10 => 'Top 10 products';

  @override
  String get quickActionMonthlyCompare => 'Monthly comparison';

  @override
  String get analyzingData => 'Analyzing data and generating report...';

  @override
  String get profileScreenTitle => 'Profil';

  @override
  String get unknownUserName => 'Unknown';

  @override
  String get defaultEmployeeRole => 'Employee';

  @override
  String get transactionUnit => 'transaction';

  @override
  String get dayUnit => 'day';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get phoneFieldLabel => 'Telepon';

  @override
  String get branchFieldLabel => 'Branch';

  @override
  String get mainBranchName => 'Main Branch';

  @override
  String get employeeNumberLabel => 'Employee Number';

  @override
  String get changePasswordLabel => 'Ubah Kata Sandi';

  @override
  String get activityLogLabel => 'Activity Log';

  @override
  String get logoutDialogTitle => 'Keluar';

  @override
  String get logoutDialogBody => 'Apakah Anda ingin keluar dari sistem?';

  @override
  String get cancelButton => 'Batal';

  @override
  String get exitButton => 'Keluar';

  @override
  String get editProfileSnack => 'Edit Profile';

  @override
  String get changePasswordSnack => 'Change Password';

  @override
  String get roleAdmin => 'System Admin';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get onboardingTitle1 => 'Fast Point of Sale';

  @override
  String get onboardingDesc1 =>
      'Complete sales quickly and easily with a simple and comfortable interface';

  @override
  String get onboardingTitle2 => 'Work Offline';

  @override
  String get onboardingDesc2 =>
      'Keep working even without connection, and sync will happen automatically';

  @override
  String get onboardingTitle3 => 'Inventory Management';

  @override
  String get onboardingDesc3 =>
      'Track your inventory accurately with shortage and expiry alerts';

  @override
  String get onboardingTitle4 => 'Smart Reports';

  @override
  String get onboardingDesc4 =>
      'Get detailed reports and analytics for your store performance';

  @override
  String get startNow => 'Mulai Sekarang';

  @override
  String get favorites => 'Favorit';

  @override
  String get editMode => 'Edit';

  @override
  String get doneMode => 'Selesai';

  @override
  String get errorLoadingFavorites => 'Error loading favorites';

  @override
  String get noFavoriteProducts => 'No favorite products';

  @override
  String get addFavoritesFromProducts =>
      'Add products to favorites from the products screen';

  @override
  String get tapProductToAddToCart => 'Tap a product to add it to cart';

  @override
  String addedProductToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get addToCartAction => 'Tambah ke Keranjang';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String removedProductFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get backEsc => 'Kembali (Esc)';

  @override
  String get completePayment => 'Selesaikan Pembayaran';

  @override
  String get enterToConfirm => 'Enter to confirm';

  @override
  String get cashOnlyOffline => 'Cash only in offline mode';

  @override
  String get cardsDisabledInSettings => 'Cards disabled in settings';

  @override
  String get creditPayment => 'Credit';

  @override
  String get unavailableOffline => 'Unavailable offline';

  @override
  String get disabledInSettings => 'Disabled in settings';

  @override
  String get amountReceived => 'Jumlah Diterima';

  @override
  String get quickAmounts => 'Quick Amounts';

  @override
  String get requiredAmount => 'Required Amount';

  @override
  String get changeLabel => 'Kembalian:';

  @override
  String get insufficientAmount => 'Insufficient amount';

  @override
  String get rrnLabel => 'Reference Number (RRN)';

  @override
  String get enterRrnFromDevice => 'Enter transaction number from device';

  @override
  String get cardPaymentInstructions =>
      'Ask the customer to pay via card terminal, then enter the transaction number (RRN) from the receipt';

  @override
  String get creditSale => 'Penjualan Kredit';

  @override
  String get creditSaleWarning =>
      'This amount will be recorded as a debt for the customer. Make sure to select the customer before completing the transaction.';

  @override
  String get orderSummary => 'Ringkasan Pesanan';

  @override
  String get taxLabel => 'Tax (15%)';

  @override
  String discountLabel(String value) {
    return 'Diskon';
  }

  @override
  String get payCash => 'Bayar Tunai';

  @override
  String get payCard => 'Bayar dengan Kartu';

  @override
  String get payCreditSale => 'Credit Sale';

  @override
  String get confirmPayment => 'Konfirmasi Pembayaran';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get pleaseWait => 'Mohon tunggu';

  @override
  String get paymentSuccessful => 'Pembayaran berhasil!';

  @override
  String get printingReceipt => 'Printing receipt...';

  @override
  String get whatsappReceipt => 'WhatsApp receipt';

  @override
  String get storeOrUserNotSet => 'Store or user not set';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get receiptTitle => 'Struk';

  @override
  String get invoiceNotSpecified => 'Invoice number not specified';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String get notSynced => 'Not synced';

  @override
  String receiptNumberLabel(String number) {
    return 'No: $number';
  }

  @override
  String get itemColumnHeader => 'Item';

  @override
  String totalAmount(String amount) {
    return 'Total';
  }

  @override
  String get paymentMethodField => 'Payment Method';

  @override
  String get zatcaQrCode => 'ZATCA Tax QR Code';

  @override
  String get whatsappSentLabel => 'Sent ✓';

  @override
  String get whatsappLabel => 'WhatsApp';

  @override
  String get whatsappReceiptSent => 'Receipt sent via WhatsApp ✓';

  @override
  String whatsappSendFailed(String error) {
    return 'Send failed: $error';
  }

  @override
  String get cannotPrintNoInvoice =>
      'Cannot print - invoice number not available';

  @override
  String get invoiceAddedToPrintQueue => 'Invoice added to print queue';

  @override
  String get mixedMethod => 'Mixed';

  @override
  String get creditMethod => 'Credit';

  @override
  String get walletMethod => 'Wallet';

  @override
  String get bankTransferMethod => 'Bank Transfer';

  @override
  String get scanBarcodeHint => 'Scan barcode or enter it (F1)';

  @override
  String get openCamera => 'Open camera';

  @override
  String get searchProductHint => 'Search product (F2)';

  @override
  String get hideCart => 'Hide cart';

  @override
  String get showCart => 'Show cart';

  @override
  String get cartTitle => 'Keranjang';

  @override
  String get clearAction => 'Hapus';

  @override
  String get allCategories => 'Semua';

  @override
  String get otherCategory => 'Other';

  @override
  String get storeNotSet => 'Store not set';

  @override
  String get retryAction => 'Coba Lagi';

  @override
  String get vatTax15 => 'VAT (15%)';

  @override
  String get totalGrand => 'Total';

  @override
  String get holdOrder => 'Tahan';

  @override
  String get payActionLabel => 'Bayar';

  @override
  String get f12QuickPay => 'F12 for quick pay';

  @override
  String productNotFoundBarcode(String barcode) {
    return 'Product not found for barcode: $barcode';
  }

  @override
  String get clearCartTitle => 'Hapus Keranjang';

  @override
  String get clearCartMessage =>
      'Do you want to remove all products from the cart?';

  @override
  String get orderOnHold => 'Order on hold';

  @override
  String get deleteItem => 'Hapus';

  @override
  String itemsCountPrice(int count, String price) {
    return '$count items - $price SAR';
  }

  @override
  String get taxReportTitle => 'Tax Report';

  @override
  String get exportReportAction => 'Export Report';

  @override
  String get printReportAction => 'Print Report';

  @override
  String get quarterly => 'Triwulanan';

  @override
  String get netTaxDue => 'Net Tax Due';

  @override
  String get salesTaxCollected => 'Sales Tax';

  @override
  String get salesTaxSubtitle => 'Collected';

  @override
  String get purchasesTaxPaid => 'Purchases Tax';

  @override
  String get purchasesTaxSubtitle => 'Paid';

  @override
  String get taxByPaymentMethod => 'Tax by Payment Method';

  @override
  String invoiceCount(int count) {
    return '$count invoices';
  }

  @override
  String get taxDetailsTitle => 'Tax Details';

  @override
  String get taxableSales => 'Taxable Sales';

  @override
  String get salesTax15 => 'Sales Tax (15%)';

  @override
  String get taxablePurchases => 'Taxable Purchases';

  @override
  String get purchasesTax15 => 'Purchases Tax (15%)';

  @override
  String get netTax => 'Net Tax';

  @override
  String get zatcaReminder => 'ZATCA Reminder';

  @override
  String get zatcaDeadline => 'Filing deadline: end of next month';

  @override
  String get historyAction => 'History';

  @override
  String get sendToAuthority => 'Send to Authority';

  @override
  String get cashPaymentMethod => 'Tunai';

  @override
  String get cardPaymentMethod => 'Kartu';

  @override
  String get mixedPaymentMethod => 'Mixed';

  @override
  String get creditPaymentMethod => 'Credit';

  @override
  String get vatReportTitle => 'VAT Report';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get salesVat => 'Sales VAT';

  @override
  String get totalSalesIncVat => 'Total Sales (incl. VAT)';

  @override
  String get vatCollected => 'VAT Collected';

  @override
  String get purchasesVat => 'Purchases VAT';

  @override
  String get totalPurchasesIncVat => 'Total Purchases (incl. VAT)';

  @override
  String get vatPaid => 'VAT Paid';

  @override
  String get netVatDue => 'Net VAT Due';

  @override
  String get dueToAuthority => 'Due to authority';

  @override
  String get dueFromAuthority => 'Due from authority';

  @override
  String get exportingPdfReport => 'Exporting report...';

  @override
  String get debtsReportTitle => 'Debts Report';

  @override
  String get sortByLastPayment => 'By last payment';

  @override
  String get customersCount => 'Pelanggan';

  @override
  String get noOutstandingDebts => 'No outstanding debts';

  @override
  String lastUpdate(String date) {
    return 'Last update: $date';
  }

  @override
  String get paymentAmountField => 'Payment Amount';

  @override
  String get recordAction => 'Record';

  @override
  String get paymentRecordedMsg => 'Payment recorded';

  @override
  String showDetails(String name) {
    return 'View details: $name';
  }

  @override
  String get debtsReportPdf => 'Debts Report';

  @override
  String dateFieldLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get debtsDetails => 'Debt Details:';

  @override
  String get customerCol => 'Pelanggan';

  @override
  String get phoneCol => 'Telepon';

  @override
  String get refundReceiptTitle => 'Refund Receipt';

  @override
  String get noRefundId => 'No refund ID';

  @override
  String get refundNotFound => 'Refund data not found';

  @override
  String get refundSuccessful => 'Refund successful';

  @override
  String refundNumberLabel(String number) {
    return 'Refund No: $number';
  }

  @override
  String get refundReceipt => 'Refund Receipt';

  @override
  String get originalInvoiceNumber => 'Original Invoice Number';

  @override
  String get refundDate => 'Refund Date';

  @override
  String get refundMethodField => 'Refund Method';

  @override
  String get returnedProducts => 'Returned Products';

  @override
  String get totalRefund => 'Total Refund';

  @override
  String get reasonLabel => 'Alasan';

  @override
  String get homeAction => 'Beranda';

  @override
  String printError(String error) {
    return 'Print error: $error';
  }

  @override
  String get damagedProduct => 'Damaged product';

  @override
  String get wrongOrder => 'Wrong order';

  @override
  String get customerChangedMind => 'Customer changed mind';

  @override
  String get expiredProduct => 'Expired product';

  @override
  String get unsatisfactoryQuality => 'Unsatisfactory quality';

  @override
  String get cashRefundMethod => 'Cash';

  @override
  String get cardRefundMethod => 'Card';

  @override
  String get walletRefundMethod => 'Wallet';

  @override
  String get refundReasonTitle => 'Refund Reason';

  @override
  String get noRefundData =>
      'No refund data. Please go back and select products.';

  @override
  String invoiceFieldLabel(String receiptNo) {
    return 'Invoice: $receiptNo';
  }

  @override
  String productsCountAmount(int count, String amount) {
    return '$count products - $amount SAR';
  }

  @override
  String get selectRefundReason => 'Select refund reason';

  @override
  String get additionalNotesOptional => 'Additional notes (optional)';

  @override
  String get addNotesHint => 'Add any additional notes...';

  @override
  String get processingAction => 'Processing...';

  @override
  String get nextSupervisorApproval => 'Next - Supervisor Approval';

  @override
  String refundCreationError(String error) {
    return 'Error creating refund: $error';
  }

  @override
  String get refundRequestTitle => 'Refund Request';

  @override
  String get invoiceNumberHint => 'Invoice number';

  @override
  String get searchAction => 'Cari';

  @override
  String get selectProductsForRefund => 'Select products to return';

  @override
  String get selectAll => 'Pilih semua';

  @override
  String quantityTimesPrice(int qty, String price) {
    return 'Qty: $qty × $price SAR';
  }

  @override
  String productsSelected(int count) {
    return '$count products selected';
  }

  @override
  String refundAmountValue(String amount) {
    return 'Amount: $amount SAR';
  }

  @override
  String get nextAction => 'Berikutnya';

  @override
  String get enterInvoiceToSearch => 'Enter invoice number to search';

  @override
  String get invoiceNotFoundMsg => 'Invoice not found';

  @override
  String get shippingGatewaysTitle => 'Shipping Gateways';

  @override
  String get availableShippingGateways => 'Available Shipping Gateways';

  @override
  String get activateShippingGateways =>
      'Activate and configure shipping gateways for order delivery';

  @override
  String get aramexName => 'Aramex';

  @override
  String get aramexDesc => 'Global shipping company with multiple services';

  @override
  String get smsaDesc => 'Fast domestic shipping';

  @override
  String get fastloName => 'Fastlo';

  @override
  String get fastloDesc => 'Same day fast delivery';

  @override
  String get dhlDesc => 'Fast and reliable international shipping';

  @override
  String get jtDesc => 'Economy shipping';

  @override
  String get customDeliveryName => 'Custom Delivery';

  @override
  String get customDeliveryDesc => 'Manage delivery with your own drivers';

  @override
  String get settingsAction => 'Pengaturan';

  @override
  String get hourlyView => 'Hourly';

  @override
  String get dailyView => 'Harian';

  @override
  String get peakHourLabel => 'Peak Hour';

  @override
  String transactionsWithCount(int count) {
    return '$count transactions';
  }

  @override
  String get peakDayLabel => 'Peak Day';

  @override
  String get avgPerHour => 'Avg/Hour';

  @override
  String get transactionWord => 'transactions';

  @override
  String get transactionsByHour => 'Transactions by Hour';

  @override
  String get transactionsByDay => 'Transactions by Day';

  @override
  String get activityHeatmap => 'Activity Heatmap';

  @override
  String get lowLabel => 'Low';

  @override
  String get highLabel => 'High';

  @override
  String get analysisRecommendations => 'Recommendations Based on Analysis';

  @override
  String get staffRecommendation => 'Staff';

  @override
  String get staffRecommendationDesc =>
      'Increase cashiers during 12:00-13:00 and 17:00-19:00 (peak sales)';

  @override
  String get offersRecommendation => 'Offers';

  @override
  String get offersRecommendationDesc =>
      'Offer special deals during 14:00-16:00 to boost sales in quiet period';

  @override
  String get inventoryRecommendation => 'Inventory';

  @override
  String get inventoryRecommendationDesc =>
      'Prepare inventory before Thursday and Friday (highest sales days)';

  @override
  String get shiftsRecommendation => 'Shifts';

  @override
  String get shiftsRecommendationDesc =>
      'Distribute shifts: morning 8-15, evening 15-22 with overlap at peak';

  @override
  String get topProductsTab => 'Top Products';

  @override
  String get byCategoryTab => 'By Category';

  @override
  String get performanceAnalysisTab => 'Performance Analysis';

  @override
  String get noSalesDataForPeriod => 'No sales data for the selected period';

  @override
  String get categoryFilter => 'Kategori';

  @override
  String get allCategoriesFilter => 'Semua Kategori';

  @override
  String get sortByField => 'Sort by';

  @override
  String get revenueSort => 'Revenue';

  @override
  String get unitsSort => 'Units';

  @override
  String get profitSort => 'Profit';

  @override
  String get revenueLabel => 'Revenue';

  @override
  String get unitsLabel => 'Units';

  @override
  String get profitLabel => 'Keuntungan';

  @override
  String get stockLabel => 'Stok';

  @override
  String get revenueByCategoryTitle => 'Revenue Distribution by Category';

  @override
  String get noRevenueForPeriod => 'No revenue for this period';

  @override
  String get unclassified => 'Unclassified';

  @override
  String get productUnit => 'produk';

  @override
  String get unitsSoldUnit => 'units';

  @override
  String get totalRevenueKpi => 'Total Revenue';

  @override
  String get unitsSoldKpi => 'Units Sold';

  @override
  String get totalProfitKpi => 'Total Profit';

  @override
  String get profitMarginKpi => 'Profit Margin';

  @override
  String get performanceOverview => 'Performance Overview';

  @override
  String get trendingUpProducts => 'Trending Up';

  @override
  String get stableProducts => 'Stable';

  @override
  String get trendingDownProducts => 'Trending Down';

  @override
  String noSalesProducts(int count) {
    return 'No sales products ($count)';
  }

  @override
  String inStockCount(int count) {
    return '$count in stock';
  }

  @override
  String get slowMovingLabel => 'Slow';

  @override
  String needsReorder(int count) {
    return 'Needs reorder ($count)';
  }

  @override
  String soldUnitsStock(int sold, int stock) {
    return 'Sold: $sold units | Stock: $stock';
  }

  @override
  String get reorderLabel => 'Reorder';

  @override
  String get totalComplaintsLabel => 'Total Complaints';

  @override
  String get openComplaints => 'Open';

  @override
  String get closedComplaints => 'Closed';

  @override
  String get avgResolutionTime => 'Avg Resolution Time';

  @override
  String daysUnit(String count) {
    return '$count days';
  }

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get statusFilter => 'Status';

  @override
  String get departmentFilter => 'Department';

  @override
  String get paymentDepartment => 'Payment';

  @override
  String get technicalDepartment => 'Technical';

  @override
  String get otherDepartment => 'Other';

  @override
  String get noComplaintsRecorded => 'No complaints recorded yet';

  @override
  String get overviewTab => 'Overview';

  @override
  String get topCustomersTab => 'Top Customers';

  @override
  String get growthAnalysisTab => 'Growth Analysis';

  @override
  String get loyaltyTab => 'Loyalty';

  @override
  String get totalCustomersLabel => 'Total Customers';

  @override
  String get activeCustomersLabel => 'Pelanggan Aktif';

  @override
  String get avgOrderValueLabel => 'Avg Order Value';

  @override
  String get tierDistribution => 'Customer Distribution by Tier';

  @override
  String get activitySummary => 'Activity Summary';

  @override
  String get totalRevenueFromCustomers =>
      'Total revenue from registered customers';

  @override
  String get avgOrderPerCustomer => 'Average order value per customer';

  @override
  String get activeCustomersLast30 => 'Active customers (last 30 days)';

  @override
  String get newCustomersLast30 => 'New customers (last 30 days)';

  @override
  String topCustomersTitle(int count) {
    return 'Top $count Customers';
  }

  @override
  String get bySpending => 'By Spending';

  @override
  String get byOrders => 'By Orders';

  @override
  String get byPoints => 'By Points';

  @override
  String ordersCount(int count) {
    return '$count orders';
  }

  @override
  String get avgOrderStat => 'Avg Order';

  @override
  String get loyaltyPointsStat => 'Loyalty Points';

  @override
  String get lastOrderStat => 'Pesanan Terakhir';

  @override
  String get newCustomerGrowth => 'New Customer Growth';

  @override
  String get customerRetentionRate => 'Customer Retention Rate';

  @override
  String get monthlyPeriod => 'Bulanan';

  @override
  String get totalCustomersPeriod => 'Total Customers';

  @override
  String get activePeriod => 'Active';

  @override
  String get activeCustomersInfo =>
      'Active customers: purchased within the last 30 days';

  @override
  String get cohortAnalysis => 'Cohort Analysis';

  @override
  String get cohortDescription => 'Return rate after first purchase';

  @override
  String get cohortGroup => 'Group';

  @override
  String get month1 => 'Month 1';

  @override
  String get month2 => 'Month 2';

  @override
  String get month3 => 'Month 3';

  @override
  String get loyaltyProgramStats => 'Loyalty Program Stats';

  @override
  String get totalPointsGranted => 'Total Points Granted';

  @override
  String get remainingPoints => 'Remaining Points';

  @override
  String get pointsValue => 'Points Value';

  @override
  String get pointsByTier => 'Points by Tier';

  @override
  String get pointsUnit => 'points';

  @override
  String get redemptionPatterns => 'Redemption Patterns';

  @override
  String get purchaseDiscount => 'Purchase Discount';

  @override
  String get freeProducts => 'Free Products';

  @override
  String get couponsLabel => 'Coupons';

  @override
  String get diamondTier => 'Diamond';

  @override
  String get goldTier => 'Gold';

  @override
  String get silverTier => 'Silver';

  @override
  String get bronzeTier => 'Bronze';

  @override
  String get todayDate => 'Hari ini';

  @override
  String get yesterdayDate => 'Kemarin';

  @override
  String daysCountLabel(int count) {
    return '$count days';
  }

  @override
  String ofTotalLabel(String active, String total) {
    return '$active of $total';
  }

  @override
  String get exportingReportMsg => 'Exporting report...';

  @override
  String get januaryMonth => 'January';

  @override
  String get februaryMonth => 'February';

  @override
  String get marchMonth => 'March';

  @override
  String get aprilMonth => 'April';

  @override
  String get mayMonth => 'May';

  @override
  String get juneMonth => 'June';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get saturdayDay => 'Saturday';

  @override
  String get sundayDay => 'Sunday';

  @override
  String get mondayDay => 'Monday';

  @override
  String get tuesdayDay => 'Tuesday';

  @override
  String get wednesdayDay => 'Wednesday';

  @override
  String get thursdayDay => 'Thursday';

  @override
  String get fridayDay => 'Friday';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get errorLoadingVatReport => 'Error loading VAT report';

  @override
  String get errorLoadingComplaints => 'Error loading complaints';

  @override
  String get errorLoadingCustomerReport => 'Error loading customer report';

  @override
  String get reprintReceipt => 'Reprint Receipt';

  @override
  String get searchByInvoiceOrCustomer => 'Search by invoice or customer...';

  @override
  String get selectInvoiceToPrint => 'Select an invoice to reprint';

  @override
  String get receiptPreview => 'Receipt Preview';

  @override
  String get receiptPrinted => 'Receipt printed successfully';

  @override
  String get refunded => 'Refunded';

  @override
  String get cashMovement => 'Cash Movement';

  @override
  String get movementType => 'Movement Type';

  @override
  String get reasonHint => 'Enter reason...';

  @override
  String get bankDeposit => 'Bank Deposit';

  @override
  String get bankWithdrawal => 'Bank Withdrawal';

  @override
  String get changeForDrawer => 'Change for Drawer';

  @override
  String get confirmDeposit => 'Confirm Deposit';

  @override
  String get confirmWithdrawal => 'Confirm Withdrawal';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get netRevenue => 'Net Revenue';

  @override
  String get afterRefunds => 'After Refunds';

  @override
  String get shiftsCount => 'Shifts Count';

  @override
  String get todayShifts => 'Today\'s Shifts';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get confirmOrder => 'Konfirmasi Pesanan';

  @override
  String get orderNow => 'Pesan Sekarang';

  @override
  String get orderCart => 'Keranjang Pesanan';

  @override
  String get orderReceived => 'Pesanan Anda telah diterima!';

  @override
  String get orderBeingPrepared => 'Pesanan Anda akan segera disiapkan';

  @override
  String get redirectingToHome => 'Otomatis kembali ke halaman utama...';

  @override
  String get kioskOrderNote => 'Pesanan kiosk';

  @override
  String pricePerUnit(String price) {
    return '$price SAR per unit';
  }

  @override
  String get selectFromMenu => 'Pilih dari menu';

  @override
  String orderCartWithCount(int count) {
    return 'Keranjang Pesanan ($count item)';
  }

  @override
  String amountWithSar(String amount) {
    return '$amount SAR';
  }

  @override
  String qtyTimesPrice(int qty, String price) {
    return '$qty x $price SAR';
  }

  @override
  String get applyCoupon => 'Terapkan Kupon';

  @override
  String get enterCouponCode => 'Masukkan kode kupon';

  @override
  String get invalidCoupon => 'Kupon tidak valid atau tidak ditemukan';

  @override
  String get couponExpired => 'Kupon telah kedaluwarsa';

  @override
  String minimumPurchaseRequired(String amount) {
    return 'Pembelian minimum $amount SAR';
  }

  @override
  String couponDiscountApplied(String amount) {
    return 'Diskon $amount SAR diterapkan';
  }

  @override
  String get couponInvalid => 'Kupon tidak valid';

  @override
  String get customerAddFailed => 'Gagal menambahkan pelanggan';

  @override
  String get quantityColon => 'Jumlah:';

  @override
  String get riyal => 'SAR';

  @override
  String get mobileNumber => 'Nomor HP';

  @override
  String get banknotes => 'Uang Kertas';

  @override
  String get coins => 'Koin';

  @override
  String get totalAmountLabel => 'Jumlah Total';

  @override
  String denominationRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String denominationHalala(String amount) {
    return '$amount Halala';
  }

  @override
  String get countCurrency => 'Hitung Mata Uang';

  @override
  String confirmAmountSar(String amount) {
    return 'Konfirmasi: $amount SAR';
  }

  @override
  String amountRiyal(String amount) {
    return '$amount SAR';
  }

  @override
  String get itemDeletedMsg => 'Item dihapus';

  @override
  String get pressBackAgainToExit => 'Tekan lagi untuk keluar';

  @override
  String get deleteHeldInvoiceConfirm => 'Hapus faktur tertunda ini?';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get noInvoices => 'No invoices';

  @override
  String get noReports => 'No reports';

  @override
  String get noOffers => 'No offers';

  @override
  String get emptyStateStartAddProducts => 'Start adding your products now';

  @override
  String get emptyStateStartAddCustomers => 'Start adding your customers now';

  @override
  String get emptyStateAddProductsToCart =>
      'Add products to cart to start selling';

  @override
  String get emptyStateInvoicesAppearAfterSale =>
      'Invoices will appear here after completing sales';

  @override
  String get emptyStateNewOrdersAppearHere => 'New orders will appear here';

  @override
  String get emptyStateNewNotificationsAppearHere =>
      'New notifications will appear here';

  @override
  String get emptyStateCheckYourConnection => 'Check your internet connection';

  @override
  String get emptyStateReportsAppearAfterSale =>
      'Reports will appear after completing sales';

  @override
  String get emptyStateNoNeedToRestock => 'No products need restocking';

  @override
  String get emptyStateAllCustomersPaid => 'All customers have paid';

  @override
  String get emptyStateReturnsAppearHere => 'Returns will appear here';

  @override
  String get emptyStateAddOffersToAttract =>
      'Add offers to attract more customers';

  @override
  String get errorNoInternetConnection => 'No internet connection';

  @override
  String get errorCheckConnectionAndRetry =>
      'Check your internet connection and try again';

  @override
  String get errorServerError => 'Server error';

  @override
  String get errorServerConnectionFailed =>
      'An error occurred while connecting to the server';

  @override
  String get errorUnexpectedError => 'An unexpected error occurred';

  @override
  String get customerGroups => 'Customer Groups';

  @override
  String get allCustomersGroup => 'All Customers';

  @override
  String get vipCustomersGroup => 'VIP Customers';

  @override
  String get regularCustomersGroup => 'Regular Customers';

  @override
  String get newCustomersGroup => 'New Customers';

  @override
  String get newCustomers30Days => 'New Customers (30 days)';

  @override
  String get customersWithDebt => 'Customers with Debts';

  @override
  String get haveDebts => 'Have Debts';

  @override
  String get inactive90Days => 'Inactive (90+ days)';

  @override
  String customerCountLabel(int count) {
    return '$count customer';
  }

  @override
  String get selectGroupToViewCustomers => 'Select a group to view customers';

  @override
  String get noCustomersInGroup => 'No customers in this group';

  @override
  String get debtWord => 'Debt';

  @override
  String get employeeProfile => 'Employee Profile';

  @override
  String get employeeNotFound => 'Employee not found';

  @override
  String get profileTab => 'Profile';

  @override
  String get salesTab => 'Sales';

  @override
  String get shiftsTab => 'Shifts';

  @override
  String get permissionsTab2 => 'Permissions';

  @override
  String get mobilePhone => 'Mobile';

  @override
  String get joinDate => 'Join Date';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get neverLoggedIn => 'Never logged in';

  @override
  String get accountActive => 'Account Active';

  @override
  String get canLogin => 'Can log in';

  @override
  String get blockedFromLogin => 'Blocked from login';

  @override
  String get employeeFallback => 'Employee';

  @override
  String get weekLabel => 'Week';

  @override
  String get monthLabel => 'Month';

  @override
  String get loadSalesData => 'Load Sales Data';

  @override
  String get invoiceCountLabel2 => 'Invoice Count';

  @override
  String get hourlySalesDistribution => 'Hourly Sales Distribution';

  @override
  String shiftOpenTime(String time) {
    return 'Open: $time';
  }

  @override
  String shiftCloseTime(String time) {
    return 'Close: $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get shiftOpenStatus => 'Open';

  @override
  String invoiceCountWithNum(int count) {
    return '$count invoice';
  }

  @override
  String get permissionsSaved => 'Permissions saved';

  @override
  String get jobRole => 'Job Role';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get viewReports => 'View Reports';

  @override
  String get refundOperations => 'Refund Operations';

  @override
  String get manageCustomersPermission => 'Manage Customers';

  @override
  String get manageOffers => 'Manage Offers';

  @override
  String get savePermissions => 'Save Permissions';

  @override
  String get deactivateAccount => 'Deactivate Account';

  @override
  String get activateAccount => 'Activate Account';

  @override
  String confirmDeactivateAccount(String name) {
    return 'Do you want to deactivate $name\'s account?';
  }

  @override
  String confirmActivateAccount(String name) {
    return 'Do you want to activate $name\'s account?';
  }

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get accountActivated => 'Account activated';

  @override
  String get accountDeactivated => 'Account deactivated';

  @override
  String get employeeAttendance => 'Employee Attendance';

  @override
  String get presentLabel => 'Present';

  @override
  String get absentLabel => 'Absent';

  @override
  String get attendanceCount => 'Attendance';

  @override
  String get absencesCount => 'Absences';

  @override
  String get lateCount => 'Late';

  @override
  String get totalEmployees => 'Total Employees';

  @override
  String noAttendanceRecordsForDay(int day, int month) {
    return 'No attendance records for $day/$month';
  }

  @override
  String get workingNow => 'Working Now';

  @override
  String get loyaltyTierCustomizeHint =>
      'You can customize loyalty program tiers and define points and benefits for each tier.';

  @override
  String memberCount(int count) {
    return '$count member';
  }

  @override
  String get pointsRequired => 'Points Required';

  @override
  String get discountPercentage => 'Discount Percentage';

  @override
  String get pointsMultiplier => 'Points Multiplier';

  @override
  String get addTier => 'Add Tier';

  @override
  String get addNewTier => 'Add New Tier';

  @override
  String get nameArabic => 'Name (Arabic)';

  @override
  String get nameEnglish => 'Name (English)';

  @override
  String get minPoints => 'Minimum Points';

  @override
  String get maxPointsHint => 'Maximum (leave empty = unlimited)';

  @override
  String multiplierLabel(String value) {
    return 'Points Multiplier: ${value}x';
  }

  @override
  String tierBenefits(String tier) {
    return 'Benefits of $tier tier';
  }

  @override
  String discountOnPurchases(String value) {
    return '• $value% discount on purchases';
  }

  @override
  String pointsPerPurchase(String value) {
    return '• ${value}x points on every purchase';
  }

  @override
  String get whatsappManagement => 'WhatsApp Management';

  @override
  String get messageQueue => 'Message Queue';

  @override
  String get templates => 'Templates';

  @override
  String get sentStatus => 'Sent';

  @override
  String get failedStatus => 'Failed';

  @override
  String get noMessages => 'No messages';

  @override
  String get retrySend => 'Retry Send';

  @override
  String get requeuedMessage => 'Message re-queued for sending';

  @override
  String templateCount(int count) {
    return '$count template';
  }

  @override
  String get newTemplate => 'New Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get templateName => 'Template Name';

  @override
  String get messageText => 'Message Text';

  @override
  String templateVariablesHint(
      Object customer_name, Object store_name, Object total) {
    return 'Use $store_name $customer_name $total as variables';
  }

  @override
  String get apiSettings => 'API Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get sendSettings => 'Send Settings';

  @override
  String get autoSend => 'Auto Send';

  @override
  String get autoSendDescription =>
      'Automatically send messages after each transaction';

  @override
  String get dailyMessageLimit => 'Daily Message Limit';

  @override
  String messagesPerDay(int count) {
    return '$count messages/day';
  }

  @override
  String get salesInvoiceTemplate => 'Sales Invoice';

  @override
  String get debtReminderTemplate => 'Debt Reminder';

  @override
  String get newCustomerWelcomeTemplate => 'New Customer Welcome';

  @override
  String get supplierReturns => 'Purchase Returns';

  @override
  String get addItemForReturn => 'Add Item for Return';

  @override
  String get itemName => 'Item Name';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get sarSuffix => 'SAR';

  @override
  String get pleaseAddItems => 'Please add items for return';

  @override
  String get creditNoteWillBeRecorded =>
      'A credit note will be recorded and inventory adjusted.';

  @override
  String get issueCreditNote => 'Issue Credit Note';

  @override
  String returnRecordedSuccess(String amount) {
    return 'Return recorded successfully - Credit note: $amount SAR';
  }

  @override
  String get selectSupplier => 'Select Supplier';

  @override
  String get damagedDefective => 'Damaged / Defective';

  @override
  String get wrongItem => 'Wrong Item';

  @override
  String get overstockExcess => 'Overstock';

  @override
  String get addItem => 'Add Item';

  @override
  String get noItemsAddedYet => 'No items added yet';

  @override
  String get notes => 'Notes';

  @override
  String get additionalNotesHint => 'Any additional notes...';

  @override
  String get totalReturn => 'Total Return';

  @override
  String issueCreditNoteWithAmount(String amount) {
    return 'Issue Credit Note ($amount SAR)';
  }

  @override
  String get deliveryZones => 'Delivery Zones';

  @override
  String get addDeliveryZone => 'Add Zone';

  @override
  String get editDeliveryZone => 'Edit Delivery Zone';

  @override
  String get addDeliveryZoneTitle => 'Add Delivery Zone';

  @override
  String get zoneName => 'Zone Name';

  @override
  String get fromKm => 'From (km)';

  @override
  String get toKm => 'To (km)';

  @override
  String get kmUnit => 'km';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get minOrderAmount => 'Minimum Order';

  @override
  String get estimatedDeliveryTime => 'Estimated Delivery Time';

  @override
  String get minuteUnit => 'min';

  @override
  String get zoneUpdated => 'Zone updated';

  @override
  String get zoneAdded => 'Zone added';

  @override
  String get deleteZone => 'Delete Zone';

  @override
  String get deleteZoneConfirm => 'Do you want to delete this zone?';

  @override
  String get activeZones => 'Active Zones';

  @override
  String get lowestFee => 'Lowest Fee';

  @override
  String get highestFee => 'Highest Fee';

  @override
  String get noDeliveryZones => 'No delivery zones';

  @override
  String get addDeliveryZonesDescription =>
      'Add delivery zones to define delivery prices and ranges';

  @override
  String get deliveryTime => 'Delivery Time';

  @override
  String get minuteAbbr => 'm';

  @override
  String get giftCards => 'Gift Cards';

  @override
  String get redeemCard => 'Redeem Card';

  @override
  String get issueGiftCard => 'Issue Gift Card';

  @override
  String get cardValue => 'Card Value (SAR)';

  @override
  String giftCardIssued(String amount) {
    return 'Gift card issued worth $amount SAR';
  }

  @override
  String get issueCard => 'Issue Card';

  @override
  String get redeemGiftCard => 'Redeem Gift Card';

  @override
  String get cardCode => 'Card Code';

  @override
  String get noCardWithCode => 'No card found with this code';

  @override
  String get cardBalanceZero => 'Card balance is zero';

  @override
  String cardBalance(String amount) {
    return 'Card balance: $amount SAR';
  }

  @override
  String get verify => 'Verify';

  @override
  String get cardsTab => 'Cards';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get searchByCode => 'Search by code...';

  @override
  String get activeFilter => 'Active';

  @override
  String get usedFilter => 'Used';

  @override
  String get expiredFilter => 'Expired';

  @override
  String get noGiftCards => 'No gift cards';

  @override
  String get issueGiftCardsDescription => 'Issue gift cards for your customers';

  @override
  String get totalActiveBalance => 'Total Active Balance';

  @override
  String get totalIssuedValue => 'Total Issued Value';

  @override
  String get activeCards => 'Active Cards';

  @override
  String get usedCards => 'Used Cards';

  @override
  String get giftCardStatusActive => 'Active';

  @override
  String get giftCardStatusPartiallyUsed => 'Partially Used';

  @override
  String get giftCardStatusFullyUsed => 'Fully Used';

  @override
  String get giftCardStatusExpired => 'Expired';

  @override
  String balanceDisplay(String balance, String total) {
    return 'Balance: $balance/$total SAR';
  }

  @override
  String expiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get onlineOrders => 'Online Orders';

  @override
  String get statusNew => 'New';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusReadyForPickup => 'Ready for Pickup';

  @override
  String get nextStatusAcceptOrder => 'Accept Order';

  @override
  String get nextStatusReady => 'Ready';

  @override
  String get nextStatusShipped => 'Shipped';

  @override
  String get nextStatusDelivered => 'Delivered';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours hr ago';
  }

  @override
  String get damagedAndLostGoods => 'Damaged & Lost Goods';

  @override
  String get damagedDefectiveShort => 'Damaged';

  @override
  String get expiredShort => 'Expired';

  @override
  String get theftLoss => 'Theft / Loss';

  @override
  String get wasteBreakage => 'Waste / Breakage';

  @override
  String get unknownProduct => 'Unknown product';

  @override
  String get recordDamagedGoods => 'Record Damaged Goods';

  @override
  String get costPerUnit => 'Cost/Unit';

  @override
  String get lossType => 'Loss Type';

  @override
  String get damagedGoodsRecorded => 'Damaged goods recorded successfully';

  @override
  String get periodLabel => 'Period';

  @override
  String get totalLosses => 'Total Losses';

  @override
  String get noDamagedGoods => 'No damaged goods';

  @override
  String get noDamagedGoodsInPeriod => 'No damaged goods in this period';

  @override
  String get recordDamagedGoodsFab => 'Record Damaged Goods';

  @override
  String quantityWithValue(String qty) {
    return 'Qty: $qty';
  }

  @override
  String get purchaseDetails => 'Purchase Details';

  @override
  String get purchaseNotFound => 'Purchase order not found';

  @override
  String get backToList => 'Back to List';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get supplierInfoLabel => 'Supplier';

  @override
  String get dateLabel => 'Date';

  @override
  String get orderTimeline => 'Order Timeline';

  @override
  String get actionsLabel => 'Actions';

  @override
  String get sendToDistributor => 'Send to Distributor';

  @override
  String get awaitingDistributorResponse => 'Awaiting distributor response';

  @override
  String get goodsReceived => 'Goods received';

  @override
  String get orderItems => 'Order Items';

  @override
  String itemCountLabel(int count) {
    return '$count item';
  }

  @override
  String get productColumn => 'Product';

  @override
  String get quantityColumn => 'Quantity';

  @override
  String get receivedColumn => 'Received';

  @override
  String get unitPriceColumn => 'Unit Price';

  @override
  String get totalColumn => 'Total';

  @override
  String quantityInfo(int qty, int received, String price) {
    return 'Qty: $qty  |  Received: $received  |  $price SAR';
  }

  @override
  String get receivingGoods => 'Receiving Goods';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get leaveWithoutSaving =>
      'Do you want to leave without saving changes?';

  @override
  String get leave => 'Leave';

  @override
  String receivingGoodsTitle(String number) {
    return 'Receiving Goods - $number';
  }

  @override
  String get orderData => 'Order Data';

  @override
  String get receivedItems => 'Received Items';

  @override
  String orderedQty(int qty) {
    return 'Ordered: $qty';
  }

  @override
  String get receivedQtyLabel => 'Received';

  @override
  String get receivingInfo => 'Receiving Info';

  @override
  String get receiverName => 'Receiver Name *';

  @override
  String get receivingNotes => 'Receiving Notes';

  @override
  String get confirmingReceipt => 'Confirming...';

  @override
  String get confirmReceipt => 'Confirm Receipt';

  @override
  String get purchaseOrders => 'Purchase Orders';

  @override
  String get statusApprovedShort => 'Approved';

  @override
  String get orderNumberColumn => 'Order Number';

  @override
  String get statusColumn => 'Status';

  @override
  String get noPurchaseOrders => 'No purchase orders';

  @override
  String get createPurchaseToStart =>
      'Create a new purchase order to get started';

  @override
  String get errorLoadingData => 'An error occurred while loading data';

  @override
  String get sendToDistributorTitle => 'Send Order to Distributor';

  @override
  String get orderInfo => 'Order Information';

  @override
  String get currentSupplier => 'Current Supplier';

  @override
  String get itemsSummary => 'Items Summary';

  @override
  String get distributorSupplier => 'Distributor / Supplier';

  @override
  String get additionalMessage => 'Additional Message';

  @override
  String get addNotesForDistributor =>
      'Add notes or a message for the distributor...';

  @override
  String get sending => 'Sending...';

  @override
  String get pleaseSelectDistributor => 'Please select the distributor';

  @override
  String errorSendingOrder(String message) {
    return 'Error sending order: $message';
  }

  @override
  String get employeeCommissions => 'Employee Commissions';

  @override
  String get totalDueCommissions => 'Total Due Commissions';

  @override
  String forEmployees(int count) {
    return 'For $count employee';
  }

  @override
  String get noCommissions => 'No commissions';

  @override
  String get noSalesInPeriod => 'No sales in this period';

  @override
  String invoicesSales(int count, String amount) {
    return '$count invoice - Sales: $amount SAR';
  }

  @override
  String get commissionLabel => 'Commission';

  @override
  String targetLabel(String amount) {
    return 'Target: $amount SAR';
  }

  @override
  String achievedPercent(String percent) {
    return '$percent% achieved';
  }

  @override
  String commissionRate(String percent) {
    return 'Commission rate: $percent%';
  }

  @override
  String get priceLists => 'Price Lists';

  @override
  String get retailPrice => 'Retail Price';

  @override
  String get retailPriceDesc => 'Standard price for individual customers';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get wholesalePriceDesc => 'Discounted prices for bulk quantities';

  @override
  String get vipPrice => 'VIP Price';

  @override
  String get vipPriceDesc => 'Special prices for VIP customers';

  @override
  String get costPriceList => 'Cost Price';

  @override
  String get costPriceDesc => 'For internal use only';

  @override
  String editPrice(String name) {
    return 'Edit Price - $name';
  }

  @override
  String basePriceLabel(String price) {
    return 'Base price: $price SAR';
  }

  @override
  String costPriceLabel(String price) {
    return 'Cost price: $price SAR';
  }

  @override
  String newPriceLabel(String listName) {
    return 'New Price ($listName)';
  }

  @override
  String priceUpdated(String name, String price) {
    return 'Price of \"$name\" updated to $price SAR';
  }

  @override
  String productCount(int count) {
    return '$count product';
  }

  @override
  String baseLabel(String price) {
    return 'Base: $price SAR';
  }

  @override
  String get errorLoadingHeldInvoices => 'Error loading held invoices';

  @override
  String get saleSaveFailed => 'Sale save failed';

  @override
  String errorSavingSaleMessage(String error) {
    return 'An error occurred while saving the sale. Cart was not cleared.\n\n$error';
  }

  @override
  String get ok => 'OK';

  @override
  String get invoiceNote => 'Invoice Note';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get clearNote => 'Clear';

  @override
  String get quickNoteDelivery => 'Delivery';

  @override
  String get quickNoteGiftWrap => 'Gift wrapping';

  @override
  String get quickNoteFragile => 'Fragile';

  @override
  String get quickNoteUrgent => 'Urgent';

  @override
  String get quickNoteReservation => 'Reservation';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String whatsappSendError(String error) {
    return 'Could not send WhatsApp: $error';
  }

  @override
  String get sendReceiptViaWhatsapp => 'Send receipt via WhatsApp';

  @override
  String get invoiceNumberTitle => 'Invoice Number';

  @override
  String get amountPaidTitle => 'Amount Paid';

  @override
  String get sentLabel => 'Sent';

  @override
  String get newSaleButton => 'New Sale';

  @override
  String get enterValidAmountError => 'Enter a valid amount';

  @override
  String get amountExceedsMaxError => 'Amount must not exceed 999,999.99';

  @override
  String get amountExceedsRemainingError => 'Amount exceeds remaining';

  @override
  String get amountBetweenZeroAndMax =>
      'Amount must be between 0 and 999,999.99';

  @override
  String get amountLessThanTotal => 'Amount received is less than total';

  @override
  String get selectCustomerFirstError => 'Select a customer first';

  @override
  String get debtLimitExceededError => 'Customer debt limit exceeded';

  @override
  String get completePaymentFirstError => 'Complete payment first';

  @override
  String get completePaymentLabel => 'Complete Payment';

  @override
  String get receivedAmountLabel => 'Amount Received';

  @override
  String get sarPrefix => 'SAR ';

  @override
  String get selectCustomerLabel => 'Select Customer';

  @override
  String get currentBalanceTitle => 'Current Balance';

  @override
  String get creditLimitTitle => 'Credit Limit';

  @override
  String get creditLimitAmount => '500.00 SAR';

  @override
  String get debtLimitExceededWarning => 'Debt limit exceeded!';

  @override
  String get selectCustomerFirstButton => 'Select customer first';

  @override
  String get splitPaymentTitle => 'Split Payment';

  @override
  String splitPaymentDone(int count) {
    return 'Split Payment done ($count methods)';
  }

  @override
  String get splitPaymentLabel => 'Split Payment';

  @override
  String get addPaymentEntry => 'Add Payment';

  @override
  String get confirmSplitPayment => 'Confirm Payment';

  @override
  String get completePaymentToConfirm => 'Complete payment first';

  @override
  String get enterValidAmountSplit => 'Enter a valid amount';

  @override
  String get amountExceedsSplit => 'Amount exceeds remaining';

  @override
  String get bestSellingPress19 => 'Best Selling (Press 1-9)';

  @override
  String get quickSearchHintFull => 'Quick search (name / code / barcode)...';

  @override
  String noResultsForQuery(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String addQtyToCart(int qty) {
    return 'Add $qty to cart';
  }

  @override
  String availableStock(String qty) {
    return 'Available: $qty';
  }

  @override
  String priceSar(String price) {
    return '$price SAR';
  }

  @override
  String loyaltyPointsDiscountLabel(int points) {
    return 'Loyalty points discount ($points points)';
  }

  @override
  String pointsRedemptionInvoice(String id) {
    return 'Points redemption - Invoice $id';
  }

  @override
  String pointsEarnedInvoice(String id) {
    return 'Points earned - Invoice $id';
  }

  @override
  String availableLoyaltyPoints(String points, String amount) {
    return 'Available loyalty points: $points points (equals $amount SAR)';
  }

  @override
  String get useLoyaltyPoints => 'Use Loyalty Points';

  @override
  String pointsCountHint(String max) {
    return 'Number of points (max $max)';
  }

  @override
  String get pointsUnitLabel => 'points';

  @override
  String discountAmountSar(String amount) {
    return 'Discount: $amount SAR';
  }

  @override
  String get allPointsLabel => 'All Points';

  @override
  String pointsCountLabel(String count) {
    return '$count points';
  }

  @override
  String newOrderNotification(String id) {
    return 'New order #$id';
  }

  @override
  String get onlineOrdersTooltip => 'Online Orders';

  @override
  String productCountItems(int count) {
    return '$count product';
  }

  @override
  String get acceptAndPrint => 'Accept & Print';

  @override
  String get deliverToDriver => 'Deliver to Driver';

  @override
  String get onTheWayStatus => 'On the way';

  @override
  String driverNameLabel(String name) {
    return 'Driver: $name';
  }

  @override
  String get deliveredStatus => 'Delivered';

  @override
  String agoMinutes(int count) {
    return '$count minutes ago';
  }

  @override
  String agoHours(int count) {
    return '$count hours ago';
  }

  @override
  String moreProductsLabel(int count) {
    return '+ $count more products';
  }

  @override
  String get onlineOrdersTitle => 'Online Orders';

  @override
  String pendingOrdersCount(int count) {
    return '$count orders pending acceptance';
  }

  @override
  String get inPreparationTab => 'In Preparation';

  @override
  String get inDeliveryTab => 'In Delivery';

  @override
  String get noOrdersMessage => 'No orders';

  @override
  String get newOrdersAppearHere => 'New orders will appear here';

  @override
  String get rejectOrderTitle => 'Reject Order';

  @override
  String get rejectOrderConfirm =>
      'Are you sure you want to reject this order?';

  @override
  String get rejectedBySeller => 'Rejected by seller';

  @override
  String printingOrderMessage(String id) {
    return 'Printing order $id...';
  }

  @override
  String get selectDriverTitle => 'Select Driver';

  @override
  String orderDeliveredToDriver(String name) {
    return 'Order delivered to driver $name';
  }

  @override
  String get walkInCustomerLabel => 'Walk-in Customer';

  @override
  String get continueWithoutCustomer => 'Continue without selecting a customer';

  @override
  String get addNewCustomerButton => 'Add New Customer';

  @override
  String loyaltyPointsCountLabel(String count) {
    return '$count points';
  }

  @override
  String customerBalanceAmount(String amount) {
    return '$amount SAR';
  }

  @override
  String get noResultsFoundTitle => 'No results found';

  @override
  String get tryAnotherSearch => 'Try searching with another keyword';

  @override
  String get selectCustomerTitle => 'Select Customer';

  @override
  String get searchByNameOrPhoneHint => 'Search by name or phone number...';

  @override
  String quickSaleHold(String time) {
    return 'Quick sale $time';
  }

  @override
  String get holdInvoiceTitle => 'Hold Invoice';

  @override
  String get holdInvoiceNameLabel => 'Held invoice name';

  @override
  String get holdAction => 'Hold';

  @override
  String heldMessage(String name) {
    return 'Held: $name';
  }

  @override
  String holdError(String error) {
    return 'Hold error: $error';
  }

  @override
  String get storeLabel => 'Store';

  @override
  String get featureNotAvailableNow => 'This feature is not available yet';

  @override
  String get cancelInvoiceError =>
      'An error occurred while canceling the invoice';

  @override
  String get invoiceLoadError => 'An error occurred while loading the invoice';

  @override
  String get syncConflicts => 'Sync conflicts';

  @override
  String itemsNeedReview(int count) {
    return '$count items need review';
  }

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get seriousProblems => 'Serious problems';

  @override
  String syncPartialSuccess(int success, int failed) {
    return 'Synced $success items, $failed failed';
  }

  @override
  String syncErrorMessage(String error) {
    return 'Sync error: $error';
  }

  @override
  String get networkError => 'Server connection error';

  @override
  String get dataLoadFailed => 'Failed to load data';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get cashierPerformance => 'Cashier Performance';

  @override
  String get resetStatsAction => 'Reset';

  @override
  String get statsReset => 'Statistics have been reset';

  @override
  String get averageSaleTime => 'Average sale time';

  @override
  String get operationsPerHour => 'Operations/hour';

  @override
  String get errorRateLabel => 'Error rate';

  @override
  String get completedOperations => 'Completed operations';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String operationsPendingSync(int count) {
    return '$count operations pending sync';
  }

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String get connectedLabel => 'Connected';

  @override
  String get disconnectedLabel => 'Disconnected';

  @override
  String offlineWithPending(int count) {
    return 'Offline - $count operations pending';
  }

  @override
  String syncingWithCount(int count) {
    return 'Syncing... ($count operations)';
  }

  @override
  String syncErrorWithCount(int count) {
    return 'Sync error - $count operations pending';
  }

  @override
  String pendingSyncWithCount(int count) {
    return '$count operations pending sync';
  }

  @override
  String get connectedAllSynced => 'Connected - all data synced';

  @override
  String get dataSavedLocally =>
      'Data saved locally and will sync when connected';

  @override
  String get uploadingData => 'Uploading data to server...';

  @override
  String get errorWillRetry => 'An error occurred, will retry automatically';

  @override
  String get syncSoon => 'Will sync in seconds';

  @override
  String get allDataSynced => 'All data is up to date and synced';

  @override
  String get cashierMode => 'Cashier mode';

  @override
  String get collapseMenu => 'Collapse menu';

  @override
  String get expandMenu => 'Expand menu';

  @override
  String get screenLoadError => 'An error occurred while loading the screen';

  @override
  String get screenLoadTimeout => 'Screen loading timed out';

  @override
  String get timeoutCheckConnection =>
      'Timed out. Check your internet connection.';

  @override
  String get retryLaterMessage => 'Please try again later.';

  @override
  String get howWasOperation => 'How was this operation?';

  @override
  String get fastLabel => 'Fast';

  @override
  String get whatToImprove => 'What can be improved?';

  @override
  String get helpUsImprove => 'Your help improves the app';

  @override
  String get writeNoteOptional => 'Write your note (optional)...';

  @override
  String get thanksFeedback => 'Thanks for your feedback!';

  @override
  String get thanksWillImprove => 'Thanks! We will work on improving';

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String get customerRatings => 'Customer ratings';

  @override
  String get fastOperations => 'Fast operations';

  @override
  String get averageRating => 'Average rating';

  @override
  String get totalRatings => 'Total ratings';

  @override
  String undoCompleted(String description) {
    return 'Undone: $description';
  }

  @override
  String get payables => 'Payables';

  @override
  String get notAvailableLabel => 'Not available';

  @override
  String get browseSupplierCatalogNotAvailable =>
      'Browse supplier catalog - not available yet';

  @override
  String get selectedSuffix => ', selected';

  @override
  String get disabledSuffix => ', disabled';

  @override
  String get doubleTapToToggle => 'Double tap to toggle';

  @override
  String get loadingPleaseWait => 'Loading...';

  @override
  String get posSystemLabel => 'POS System';

  @override
  String get pageNotFoundTitle => 'Error';

  @override
  String pageNotFoundMessage(String path) {
    return 'Page not found: $path';
  }

  @override
  String get noShipmentsToReceive => 'No shipments to receive';

  @override
  String get approvedOrdersAppearHere =>
      'Approved orders ready for receiving will appear here';

  @override
  String get unspecifiedSupplier => 'Unspecified supplier';

  @override
  String get viewItems => 'View Items';

  @override
  String get receivingInProgress => 'Receiving...';

  @override
  String get confirmReceivingBtn => 'Confirm Receiving';

  @override
  String orderItemsTitle(String number) {
    return 'Order Items $number';
  }

  @override
  String get noOrderItems => 'No items';

  @override
  String get confirmReceiveGoodsTitle => 'Confirm Receiving Goods';

  @override
  String confirmReceiveGoodsBody(String number) {
    return 'Are you sure you want to receive order $number?\nInventory will be updated automatically.';
  }

  @override
  String orderReceivedSuccess(String number) {
    return 'Order $number received successfully';
  }

  @override
  String get quickPurchaseRequest => 'Quick Purchase Request';

  @override
  String get searchAndAddProducts =>
      'Search for products and add them to the request';

  @override
  String get requestedProducts => 'Requested Products';

  @override
  String get productCountSummary => 'Product Count';

  @override
  String get totalQuantitySummary => 'Total Quantity';

  @override
  String get addNotesForManager => 'Add notes for manager (optional)...';

  @override
  String get sendRequestBtn => 'Send Request';

  @override
  String get validQuantityRequired =>
      'Please enter a valid quantity for all products';

  @override
  String get requestSentToManager => 'Request sent to manager';

  @override
  String get connectionSuccessMsg => 'Connected successfully';

  @override
  String connectionFailedMsgErr(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get deviceSavedMsg => 'Device saved';

  @override
  String saveErrorMsg(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get addPaymentDeviceTitle => 'Add Payment Device';

  @override
  String get setupNewDeviceSubtitle => 'Set up a new device';

  @override
  String get quickAccessKeysSubtitle => 'Quick access keys';

  @override
  String devicesAddedCount(int count) {
    return '$count devices added';
  }

  @override
  String get managePreferencesSubtitle => 'Manage preferences';

  @override
  String get storeNameAddressLogo => 'Name, address and logo';

  @override
  String get receiptHeaderFooterLogo => 'Receipt header, footer and logo';

  @override
  String get posPaymentNavSubtitle => 'POS, payment and navigation';

  @override
  String get usersAndPermissions => 'Users & Permissions';

  @override
  String get rolesAndAccess => 'Roles and access';

  @override
  String get backupAutoRestore => 'Automatic backup and restore';

  @override
  String get privacyAndDataRights => 'Privacy and data rights';

  @override
  String get arabicEnglish => 'Arabic/English';

  @override
  String get darkLightMode => 'Dark/Light mode';

  @override
  String get clearCacheTitle => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Fix loading and data issues';

  @override
  String get clearCacheDialogBody =>
      'All temporary data will be cleared and reloaded from the server.\n\nYou will be logged out and the app will restart.\n\nDo you want to continue?';

  @override
  String get clearAndRestart => 'Clear & Restart';

  @override
  String get clearingCacheProgress => 'Clearing cache...';

  @override
  String get printerInitFailed => 'Failed to initialize print service';

  @override
  String get noPrintersFound => 'No printers found';

  @override
  String searchErrorMsg(String error) {
    return 'Search error: $error';
  }

  @override
  String connectedToPrinterName(String name) {
    return 'Connected to $name';
  }

  @override
  String connectionFailedToPrinter(String name) {
    return 'Connection failed to $name';
  }

  @override
  String get enterPrinterIpAddress => 'Enter the printer IP address';

  @override
  String get printerNotConnectedMsg => 'Printer not connected';

  @override
  String get testPageSentSuccess => 'Test page sent successfully';

  @override
  String testFailedMsg(String error) {
    return 'Test failed: $error';
  }

  @override
  String errorMsgGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get cashDrawerOpened => 'Cash drawer opened';

  @override
  String cashDrawerFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get disconnectedMsg => 'Disconnected';

  @override
  String connectedPrinterStatus(String name) {
    return 'Connected: $name';
  }

  @override
  String get notConnectedStatus => 'Not connected';

  @override
  String get connectedToPrinterMsg => 'Connected to printer';

  @override
  String get noPrinterConnectedMsg => 'No printer connected';

  @override
  String get openDrawerBtn => 'Open Drawer';

  @override
  String get disconnectBtn => 'Disconnect';

  @override
  String get connectPrinterTitle => 'Connect Printer';

  @override
  String get connectionTypeLabel => 'Connection Type';

  @override
  String get bluetoothLabel => 'Bluetooth';

  @override
  String get networkLabel => 'Network';

  @override
  String get printerIpAddressLabel => 'Printer IP Address';

  @override
  String get connectBtn => 'Connect';

  @override
  String get searchingPrintersLabel => 'Searching...';

  @override
  String get searchPrintersBtn => 'Search for printers';

  @override
  String discoveredPrintersTitle(int count) {
    return 'Discovered Printers ($count)';
  }

  @override
  String get connectedBadge => 'Connected';

  @override
  String get printSettingsTitle => 'Print Settings';

  @override
  String get autoPrintTitle => 'Auto Print';

  @override
  String get autoPrintSubtitle => 'Automatically print receipt after each sale';

  @override
  String get paperSizeSubtitle => 'Thermal printer paper width';

  @override
  String get customizeReceiptSubtitle => 'Customize receipt';

  @override
  String get viewStoreDetailsSubtitle => 'View store details';

  @override
  String get usersAndPermissionsTitle => 'Users & Permissions';

  @override
  String usersCountLabel(int count) {
    return '$count user';
  }

  @override
  String get noPrinterSetup => 'No printer set up';

  @override
  String get printerNotConnectedErr => 'Printer not connected';

  @override
  String get transactionRecordedSuccess => 'Transaction recorded successfully';

  @override
  String productSearchFailed(String error) {
    return 'Product search failed: $error';
  }

  @override
  String customerSearchFailed(String error) {
    return 'Customer search failed: $error';
  }

  @override
  String get inventoryUpdatedMsg => 'Inventory updated';

  @override
  String get scanOrEnterBarcode => 'Scan or enter barcode';

  @override
  String get priceUpdatedMsg => 'Price updated';

  @override
  String get exchangeSuccessMsg => 'Exchange completed successfully';

  @override
  String get refundProcessedSuccess => 'Refund processed successfully';

  @override
  String get backupCompletedTitle => 'Backup Completed';

  @override
  String backupCompletedBody(int rows, String size) {
    return 'Backup completed - $rows rows, $size MB';
  }

  @override
  String backupFailedMsg(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get copyBackupInstructions =>
      'Copy backup data to clipboard to save or share it.';

  @override
  String get closeBtn => 'Close';

  @override
  String get backupCopiedToClipboard => 'Backup copied to clipboard';

  @override
  String get copyToClipboardBtn => 'Copy to Clipboard';

  @override
  String get countDenominationsBtn => 'Count by denominations';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Privacy and data rights';

  @override
  String get privacyIntroTitle => 'Introduction';

  @override
  String get privacyIntroBody =>
      'At Alhai, we are committed to protecting your privacy and personal data. This policy explains how we collect, use, and protect your data when using the Point of Sale application.';

  @override
  String get privacyLastUpdated => 'Last updated: March 2026';

  @override
  String get privacyDataCollectedTitle => 'Data We Collect';

  @override
  String get privacyStoreData =>
      'Store data: store name, address, tax number, logo.';

  @override
  String get privacyProductData =>
      'Product data: product names, prices, barcodes, stock.';

  @override
  String get privacySalesData =>
      'Sales data: invoices, payment methods, amounts, date and time.';

  @override
  String get privacyCustomerData =>
      'Customer data: name, phone number, email (optional), purchase history.';

  @override
  String get privacyEmployeeData =>
      'Employee data: username, role, shift history.';

  @override
  String get privacyDeviceData =>
      'Device data: device type, operating system (for technical support only).';

  @override
  String get privacyHowWeUseTitle => 'How We Use Your Data';

  @override
  String get privacyUsePOS =>
      'Operating the POS system and processing sales and payments.';

  @override
  String get privacyUseReports =>
      'Creating reports and statistics to help you manage your store.';

  @override
  String get privacyUseAccounts =>
      'Managing customer accounts, debts, and loyalty.';

  @override
  String get privacyUseInventory => 'Managing inventory and tracking products.';

  @override
  String get privacyUseBackup => 'Backup and data restoration.';

  @override
  String get privacyUsePerformance =>
      'Improving app performance and fixing bugs.';

  @override
  String get privacyNoSellData =>
      'We do not sell your data to third parties. We do not use your data for advertising purposes.';

  @override
  String get privacyProtectionTitle => 'How We Protect Your Data';

  @override
  String get privacyLocalStorage =>
      'Local storage: All sales and customer data is stored locally on your device.';

  @override
  String get privacyEncryption =>
      'Encryption: Sensitive data is encrypted using modern encryption technologies.';

  @override
  String get privacyBackupProtection =>
      'Backup: You can create encrypted backups of your data.';

  @override
  String get privacyAuthentication =>
      'Authentication: Access is protected by password and user permissions.';

  @override
  String get privacyOffline =>
      'Offline operation: The app works 100% offline; your data is not sent to external servers.';

  @override
  String get privacyRightsTitle => 'Your Rights';

  @override
  String get privacyRightAccess => 'Right of Access';

  @override
  String get privacyRightAccessDesc =>
      'You have the right to view all your data stored in the app at any time.';

  @override
  String get privacyRightCorrection => 'Right of Correction';

  @override
  String get privacyRightCorrectionDesc =>
      'You have the right to modify or correct any inaccurate data.';

  @override
  String get privacyRightDeletion => 'Right of Deletion';

  @override
  String get privacyRightDeletionDesc =>
      'You have the right to request deletion of your personal data. You can delete customer data from the customer management screen.';

  @override
  String get privacyRightExport => 'Right of Export';

  @override
  String get privacyRightExportDesc =>
      'You have the right to export a copy of your data in JSON format.';

  @override
  String get privacyRightWithdrawal => 'Right of Withdrawal';

  @override
  String get privacyRightWithdrawalDesc =>
      'You have the right to withdraw any previous consent to process your data.';

  @override
  String get privacyDataDeletionTitle => 'Data Deletion';

  @override
  String get privacyDataDeletionIntro =>
      'You can delete customer data through the app settings. When deleting customer data:';

  @override
  String get privacyDataDeletionPersonal =>
      'Personal information (name, phone, email) is permanently deleted.';

  @override
  String get privacyDataDeletionAnonymize =>
      'Customer identity in previous sales records is anonymized (shown as \"Deleted Customer\").';

  @override
  String get privacyDataDeletionAccounts =>
      'Associated debt accounts and addresses are deleted.';

  @override
  String get privacyDataDeletionWarning =>
      'Note: Data deletion cannot be undone after execution.';

  @override
  String get privacyContactTitle => 'Contact Us';

  @override
  String get privacyContactIntro =>
      'If you have any questions about the privacy policy or wish to exercise your rights, you can contact us via:';

  @override
  String get privacyContactEmail => 'Email: privacy@alhai.app';

  @override
  String get privacyContactSupport => 'In-app technical support';

  @override
  String get onboardingPrivacyPolicy => 'Privacy Policy | Privacy Policy';

  @override
  String get cashierDefaultName => 'Cashier';

  @override
  String get defaultAddress => 'Riyadh - Kingdom of Saudi Arabia';

  @override
  String get loadMoreBtn => 'Load More';

  @override
  String get countCurrencyBtn => 'Count Currency';

  @override
  String get searchLogsHint => 'Search logs...';

  @override
  String get noSearchResultsForQuery => 'No results for search';

  @override
  String get noLogsToDisplay => 'No logs to display';

  @override
  String get auditActionLogin => 'Login';

  @override
  String get auditActionLogout => 'Logout';

  @override
  String get auditActionSale => 'Sale';

  @override
  String get auditActionCancelSale => 'Cancel Sale';

  @override
  String get auditActionRefund => 'Refund';

  @override
  String get auditActionAddProduct => 'Add Product';

  @override
  String get auditActionEditProduct => 'Edit Product';

  @override
  String get auditActionDeleteProduct => 'Delete Product';

  @override
  String get auditActionPriceChange => 'Price Change';

  @override
  String get auditActionStockAdjust => 'Stock Adjust';

  @override
  String get auditActionStockReceive => 'Stock Receive';

  @override
  String get auditActionOpenShift => 'Open Shift';

  @override
  String get auditActionCloseShift => 'Close Shift';

  @override
  String get auditActionSettingsChange => 'Settings Change';

  @override
  String get auditActionCashDrawer => 'Cash Drawer';

  @override
  String get permCategoryPosLabel => 'Point of Sale';

  @override
  String get permCategoryProductsLabel => 'Products';

  @override
  String get permCategoryInventoryLabel => 'Inventory';

  @override
  String get permCategoryCustomersLabel => 'Customers';

  @override
  String get permCategorySalesLabel => 'Sales';

  @override
  String get permCategoryReportsLabel => 'Reports';

  @override
  String get permCategorySettingsLabel => 'Settings';

  @override
  String get permCategoryStaffLabel => 'Staff';

  @override
  String get permPosAccess => 'POS Access';

  @override
  String get permPosAccessDesc => 'Access the point of sale screen';

  @override
  String get permPosHold => 'Hold Invoices';

  @override
  String get permPosHoldDesc => 'Hold invoices and complete later';

  @override
  String get permPosSplitPayment => 'Split Payment';

  @override
  String get permPosSplitPaymentDesc =>
      'Split payment between different methods';

  @override
  String get permProductsView => 'View Products';

  @override
  String get permProductsViewDesc => 'View product list and details';

  @override
  String get permProductsManage => 'Manage Products';

  @override
  String get permProductsManageDesc => 'Add and edit products';

  @override
  String get permProductsDelete => 'Delete Products';

  @override
  String get permProductsDeleteDesc => 'Delete products from the system';

  @override
  String get permInventoryView => 'View Inventory';

  @override
  String get permInventoryViewDesc => 'View stock quantities';

  @override
  String get permInventoryManage => 'Manage Inventory';

  @override
  String get permInventoryManageDesc => 'Manage stock and transfers';

  @override
  String get permInventoryAdjust => 'Adjust Inventory';

  @override
  String get permInventoryAdjustDesc => 'Manually adjust stock quantities';

  @override
  String get permCustomersView => 'View Customers';

  @override
  String get permCustomersViewDesc => 'View customer data';

  @override
  String get permCustomersManage => 'Manage Customers';

  @override
  String get permCustomersManageDesc => 'Add and edit customers';

  @override
  String get permCustomersDelete => 'Delete Customers';

  @override
  String get permCustomersDeleteDesc => 'Delete customers from the system';

  @override
  String get permDiscountsApply => 'Apply Discounts';

  @override
  String get permDiscountsApplyDesc => 'Apply existing discounts';

  @override
  String get permDiscountsCreate => 'Create Discounts';

  @override
  String get permDiscountsCreateDesc => 'Create new discounts';

  @override
  String get permRefundsRequest => 'Request Refund';

  @override
  String get permRefundsRequestDesc => 'Request product refunds';

  @override
  String get permRefundsApprove => 'Approve Refund';

  @override
  String get permRefundsApproveDesc => 'Approve refund requests';

  @override
  String get permReportsView => 'View Reports';

  @override
  String get permReportsViewDesc => 'View reports and statistics';

  @override
  String get permReportsExport => 'Export Reports';

  @override
  String get permReportsExportDesc => 'Export reports in various formats';

  @override
  String get permSettingsView => 'View Settings';

  @override
  String get permSettingsViewDesc => 'View system settings';

  @override
  String get permSettingsManage => 'Manage Settings';

  @override
  String get permSettingsManageDesc => 'Modify system settings';

  @override
  String get permStaffView => 'View Staff';

  @override
  String get permStaffViewDesc => 'View staff list';

  @override
  String get permStaffManage => 'Manage Staff';

  @override
  String get permStaffManageDesc => 'Add and edit staff';

  @override
  String get roleSystemAdmin => 'System Admin';

  @override
  String get roleSystemAdminDesc => 'Full system permissions';

  @override
  String get roleStoreManager => 'Store Manager';

  @override
  String get roleStoreManagerDesc => 'Manage store and employees';

  @override
  String get roleCashierDesc => 'Sales and payment operations';

  @override
  String get roleWarehouseKeeper => 'Warehouse Keeper';

  @override
  String get roleWarehouseKeeperDesc => 'Manage inventory and products';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleAccountantDesc => 'Financial reports and accounts';

  @override
  String connectionFailedMsg(String error) {
    return 'Connection failed: $error';
  }

  @override
  String settingsSaveErrorMsg(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get cutPaperBtn => 'Cut';

  @override
  String upgradeToPlan(String name) {
    return 'Upgrade to $name';
  }

  @override
  String get manageDeliveryZonesAndPricing =>
      'Manage delivery zones and pricing';

  @override
  String settingsForName(String name) {
    return 'Settings for $name';
  }

  @override
  String settingsSavedForName(String name) {
    return 'Settings for $name saved';
  }

  @override
  String get jobProfile => 'Job Profile';

  @override
  String get submitToZatcaAuthority => 'Submit to ZATCA Authority';

  @override
  String get submitBtn => 'Submit';

  @override
  String get submitToAuthority => 'Submit to Authority';

  @override
  String shareError(String error) {
    return 'Sharing error: $error';
  }

  @override
  String upgradePlanPriceBody(String price) {
    return 'Plan price: $price SAR/month\n\nDo you want to continue?';
  }

  @override
  String get upgradeContactMsg =>
      'We will contact you to complete the upgrade process';

  @override
  String get zatcaSubmitBody =>
      'Electronic invoicing data will be sent to the authority. Make sure your data is correct first.';

  @override
  String get zatcaLinkComingSoon =>
      'ZATCA system integration coming soon - make sure to set up the digital certificate';

  @override
  String get enterApiKey => 'Enter API key';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get platformOverview => 'Platform Overview';

  @override
  String get activeStores => 'Active Stores';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get subscriptionStats => 'Subscription Stats';

  @override
  String get churnRate => 'Churn Rate';

  @override
  String get conversionRate => 'Conversion Rate';

  @override
  String get trialConversion => 'Trial Conversion';

  @override
  String get newSignups => 'New Signups';

  @override
  String get monthlyRecurringRevenue => 'Monthly Recurring Revenue';

  @override
  String get annualRecurringRevenue => 'Annual Recurring Revenue';

  @override
  String get storesList => 'Stores';

  @override
  String get storeDetail => 'Store Detail';

  @override
  String get createStore => 'Create Store';

  @override
  String get storeOwner => 'Store Owner';

  @override
  String get storeStatus => 'Status';

  @override
  String get storeCreatedAt => 'Created At';

  @override
  String get storePlan => 'Plan';

  @override
  String get suspendStore => 'Suspend Store';

  @override
  String get activateStore => 'Activate Store';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get downgradePlan => 'Downgrade Plan';

  @override
  String get storeUsageStats => 'Usage Stats';

  @override
  String get storeTransactions => 'Transactions';

  @override
  String get storeProducts => 'Products Count';

  @override
  String get storeEmployees => 'Employees';

  @override
  String get onboardingForm => 'Onboarding Form';

  @override
  String get ownerName => 'Owner Name';

  @override
  String get ownerPhone => 'Owner Phone';

  @override
  String get ownerEmail => 'Owner Email';

  @override
  String get businessType => 'Business Type';

  @override
  String get branchCountLabel => 'Branch Count';

  @override
  String get subscriptionManagement => 'Subscription Management';

  @override
  String get plansManagement => 'Plans Management';

  @override
  String get subscriptionList => 'Subscriptions';

  @override
  String get billingAndInvoices => 'Billing & Invoices';

  @override
  String get planName => 'Plan Name';

  @override
  String get planPrice => 'Price';

  @override
  String get planFeatures => 'Features';

  @override
  String get basicPlan => 'Basic';

  @override
  String get advancedPlan => 'Advanced';

  @override
  String get professionalPlan => 'Professional';

  @override
  String get monthlyPrice => 'Monthly Price';

  @override
  String get yearlyPrice => 'Yearly Price';

  @override
  String get maxBranches => 'Max Branches';

  @override
  String get maxProducts => 'Max Products';

  @override
  String get maxUsers => 'Max Users';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get alreadyOnHighestPlan => 'Already on the highest plan';

  @override
  String get alreadyOnLowestPlan => 'Already on the lowest plan';

  @override
  String get activeSubscriptions => 'Active Subscriptions';

  @override
  String get expiredSubscriptions => 'Expired Subscriptions';

  @override
  String get trialSubscriptions => 'Trial Subscriptions';

  @override
  String get billingHistory => 'Billing History';

  @override
  String get invoiceDate => 'Date';

  @override
  String get invoiceAmount => 'Amount';

  @override
  String get invoiceStatus => 'Status';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get platformUsers => 'Platform Users';

  @override
  String get userDetail => 'User Detail';

  @override
  String get roleManagement => 'Role Management';

  @override
  String get userRole => 'Role';

  @override
  String get userLastActive => 'Last Active';

  @override
  String get superAdminRole => 'Super Admin';

  @override
  String get supportRole => 'Support';

  @override
  String get viewerRole => 'Viewer';

  @override
  String get assignRole => 'Assign Role';

  @override
  String get analytics => 'Analytics';

  @override
  String get revenueAnalytics => 'Revenue Analytics';

  @override
  String get usageAnalytics => 'Usage Analytics';

  @override
  String get mrrGrowth => 'MRR Growth';

  @override
  String get arrGrowth => 'ARR Growth';

  @override
  String get revenueByPlan => 'Revenue by Plan';

  @override
  String get revenueByMonth => 'Revenue by Month';

  @override
  String get activeUsersPerStore => 'Active Users per Store';

  @override
  String get transactionsPerStore => 'Transactions per Store';

  @override
  String get avgTransactionsPerDay => 'Avg Transactions/Day';

  @override
  String get topStoresByRevenue => 'Top Stores by Revenue';

  @override
  String get topStoresByTransactions => 'Top Stores by Transactions';

  @override
  String get platformSettings => 'Platform Settings';

  @override
  String get zatcaConfig => 'ZATCA Configuration';

  @override
  String get paymentGateways => 'Payment Gateways';

  @override
  String get systemHealth => 'System Health';

  @override
  String get systemMonitoring => 'System Monitoring';

  @override
  String get serverStatus => 'Server Status';

  @override
  String get apiLatency => 'API Latency';

  @override
  String get errorRate => 'Error Rate';

  @override
  String get cpuUsage => 'CPU Usage';

  @override
  String get memoryUsage => 'Memory Usage';

  @override
  String get diskUsage => 'Disk Usage';

  @override
  String get degraded => 'Degraded';

  @override
  String get down => 'Down';

  @override
  String get lastChecked => 'Last Checked';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get filterByPlan => 'Filter by Plan';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get allPlans => 'All Plans';

  @override
  String get suspended => 'Suspended';

  @override
  String get trial => 'Trial';

  @override
  String get searchStores => 'Search stores...';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get noStoresFound => 'No stores found';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get confirmSuspend => 'Are you sure you want to suspend this store?';

  @override
  String get confirmActivate => 'Are you sure you want to activate this store?';

  @override
  String get storeCreatedSuccess => 'Store created successfully';

  @override
  String get storeSuspendedSuccess => 'Store suspended successfully';

  @override
  String get storeActivatedSuccess => 'Store activated successfully';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get last12Months => 'Last 12 Months';

  @override
  String get growth => 'Growth';

  @override
  String get stores => 'Stores';

  @override
  String get distributorPortal => 'Distributor Portal';

  @override
  String get distributorDashboard => 'Dashboard';

  @override
  String get distributorDashboardSubtitle =>
      'Distribution performance overview';

  @override
  String get distributorOrders => 'Incoming Orders';

  @override
  String get distributorProducts => 'Product Catalog';

  @override
  String get distributorPricing => 'Price Management';

  @override
  String get distributorReports => 'Reports';

  @override
  String get distributorSettings => 'Settings';

  @override
  String get distributorTotalOrders => 'Total Orders';

  @override
  String get distributorPendingOrders => 'Pending Orders';

  @override
  String get distributorApprovedOrders => 'Approved';

  @override
  String get distributorRevenue => 'Revenue';

  @override
  String get distributorMonthlySales => 'Monthly Sales';

  @override
  String get distributorRecentOrders => 'Recent Orders';

  @override
  String get distributorOrderNumber => 'Order Number';

  @override
  String get distributorStore => 'Store';

  @override
  String get distributorDate => 'Date';

  @override
  String get distributorAmount => 'Amount';

  @override
  String get distributorStatusPending => 'Pending';

  @override
  String get distributorStatusApproved => 'Approved';

  @override
  String get distributorStatusReceived => 'Received';

  @override
  String get distributorStatusRejected => 'Rejected';

  @override
  String get distributorStatusDraft => 'Draft';

  @override
  String get distributorNoOrders => 'No orders found';

  @override
  String get distributorAllOrders => 'All';

  @override
  String get distributorPendingTab => 'Pending';

  @override
  String get distributorApprovedTab => 'Approved';

  @override
  String get distributorRejectedTab => 'Rejected';

  @override
  String get distributorAddProduct => 'Add Product';

  @override
  String get distributorSearchHint => 'Search by name or barcode...';

  @override
  String get distributorNoProducts => 'No products found';

  @override
  String get distributorChangeSearch => 'Try changing your search criteria';

  @override
  String get distributorBarcode => 'Barcode';

  @override
  String get distributorCategory => 'Category';

  @override
  String get distributorStock => 'Stock';

  @override
  String get distributorStockEmpty => 'Out';

  @override
  String get distributorStockLow => 'Low';

  @override
  String get distributorActions => 'Actions';

  @override
  String distributorEditProduct(String name) {
    return 'Edit $name';
  }

  @override
  String get distributorCurrentPrice => 'Current Price';

  @override
  String get distributorNewPrice => 'New Price';

  @override
  String get distributorLastUpdated => 'Last Updated';

  @override
  String get distributorDifference => 'Diff';

  @override
  String get distributorTotalProducts => 'Total Products';

  @override
  String get distributorPendingChanges => 'Pending Changes';

  @override
  String distributorProductsWillUpdate(int count) {
    return '$count products will be updated';
  }

  @override
  String get distributorSaveChanges => 'Save Changes';

  @override
  String get distributorChangesSaved => 'Changes saved successfully';

  @override
  String distributorChangesCount(int count) {
    return '$count changes';
  }

  @override
  String get distributorExport => 'Export';

  @override
  String get distributorExportReport => 'Export Report';

  @override
  String get distributorDailySales => 'Daily Sales';

  @override
  String get distributorOrderCount => 'Order Count';

  @override
  String get distributorAvgOrderValue => 'Avg Order Value';

  @override
  String get distributorTopProduct => 'Top Product';

  @override
  String get distributorTopProducts => 'Top Products';

  @override
  String get distributorOrdersUnit => 'orders';

  @override
  String get distributorPeriodDay => 'Day';

  @override
  String get distributorPeriodWeek => 'Week';

  @override
  String get distributorPeriodMonth => 'Month';

  @override
  String get distributorPeriodYear => 'Year';

  @override
  String get distributorCompanyInfo => 'Company Info';

  @override
  String get distributorCompanyName => 'Company Name';

  @override
  String get distributorPhone => 'Phone';

  @override
  String get distributorEmail => 'Email';

  @override
  String get distributorAddress => 'Address';

  @override
  String get distributorNotificationSettings => 'Notification Settings';

  @override
  String get distributorNotificationChannels => 'Notification Channels';

  @override
  String get distributorEmailNotifications => 'Email';

  @override
  String get distributorPushNotifications => 'Push Notifications';

  @override
  String get distributorSmsNotifications => 'SMS';

  @override
  String get distributorNotificationTypes => 'Notification Types';

  @override
  String get distributorNewOrderNotification => 'New Orders';

  @override
  String get distributorOrderStatusNotification => 'Order Status Updates';

  @override
  String get distributorPaymentNotification => 'Payment Notifications';

  @override
  String get distributorDeliverySettings => 'Delivery Settings';

  @override
  String get distributorDeliveryZones => 'Delivery Zones';

  @override
  String get distributorDeliveryZonesHint => 'Enter cities separated by commas';

  @override
  String get distributorMinOrder => 'Min Order Amount (SAR)';

  @override
  String get distributorDeliveryFee => 'Delivery Fee (SAR)';

  @override
  String get distributorFreeDelivery => 'Free Delivery';

  @override
  String get distributorFreeDeliveryMin => 'Free Delivery Minimum (SAR)';

  @override
  String get distributorSaveSettings => 'Save Settings';

  @override
  String get distributorSettingsSaved => 'Settings saved successfully';

  @override
  String distributorPurchaseOrder(String number) {
    return 'Purchase Order #$number';
  }

  @override
  String get distributorProposedAmount => 'Proposed Amount:';

  @override
  String get distributorOrderItems => 'Order Items';

  @override
  String distributorProductCount(int count) {
    return '$count products';
  }

  @override
  String get distributorSuggestedPrice => 'Suggested Price';

  @override
  String get distributorYourPrice => 'Your Price';

  @override
  String get distributorYourTotal => 'Your Total';

  @override
  String get distributorNotesForStore => 'Notes for Store';

  @override
  String get distributorNotesHint => 'Add notes about the offer (optional)...';

  @override
  String get distributorRejectOrder => 'Reject Order';

  @override
  String get distributorAcceptSendQuote => 'Accept & Send Quote';

  @override
  String get distributorOrderRejected => 'Order rejected successfully';

  @override
  String distributorOrderAccepted(String amount) {
    return 'Order accepted and quote sent for $amount SAR';
  }

  @override
  String distributorLowerThanProposed(String percent) {
    return '$percent% lower than proposed';
  }

  @override
  String distributorHigherThanProposed(String percent) {
    return '+$percent% higher than proposed';
  }

  @override
  String get distributorComingSoon => 'Coming soon';

  @override
  String get distributorLoadError => 'Error loading data';

  @override
  String get distributorRetry => 'Retry';

  @override
  String get distributorLogin => 'Distributor Login';

  @override
  String get distributorLoginSubtitle => 'Enter your email and password';

  @override
  String get distributorEmailLabel => 'Email';

  @override
  String get distributorPasswordLabel => 'Password';

  @override
  String get distributorLoginButton => 'Sign In';

  @override
  String get distributorLoginError => 'Login failed';

  @override
  String get distributorLogout => 'Sign Out';

  @override
  String get distributorSar => 'SAR';

  @override
  String get distributorRiyal => 'SAR';

  @override
  String get distributorUnsavedChanges => 'Unsaved Changes';

  @override
  String get distributorUnsavedChangesMessage =>
      'You have unsaved changes. Do you want to leave without saving?';

  @override
  String get distributorStay => 'Stay';

  @override
  String get distributorLeave => 'Leave';

  @override
  String get distributorNoDataToExport => 'No data to export';

  @override
  String get distributorReportExported => 'Report exported successfully';

  @override
  String get distributorExportWebOnly => 'Export is only available on web';

  @override
  String get distributorPrintWebOnly => 'Printing is only available on web';

  @override
  String get distributorSaveError => 'An error occurred while saving';

  @override
  String get distributorInvalidEmail => 'Please enter a valid email address';

  @override
  String get distributorInvalidPhone => 'Please enter a valid phone number';

  @override
  String get distributorActionUndone => 'Action undone';

  @override
  String get distributorSessionExpired =>
      'Session expired due to inactivity. Please log in again.';

  @override
  String get distributorWelcomePortal => 'Welcome to the Distributor Portal!';

  @override
  String get distributorGetStarted =>
      'Get started by exploring these key features:';

  @override
  String get distributorManagePrices => 'Manage Prices';

  @override
  String get distributorManagePricesDesc =>
      'Set and update product prices for your distribution';

  @override
  String get distributorViewReports => 'View Reports';

  @override
  String get distributorViewReportsDesc =>
      'Track sales performance and view analytics';

  @override
  String get distributorUpdateSettings => 'Update Settings';

  @override
  String get distributorUpdateSettingsDesc =>
      'Configure company info, delivery zones, and notifications';

  @override
  String get distributorReviewOrdersDesc =>
      'Review and manage incoming purchase orders from stores';

  @override
  String get distributorMonthlySalesSar => 'Monthly Sales (SAR)';

  @override
  String get distributorPrintReport => 'Print Report';

  @override
  String get distributorPrint => 'Print';

  @override
  String get distributorExportCsv => 'Export report as CSV';

  @override
  String get distributorExportCsvShort => 'Export CSV';

  @override
  String get distributorSaveCtrlS => 'Save Changes (Ctrl+S)';

  @override
  String get scanCouponBarcode => 'Scan Coupon Barcode';

  @override
  String get validateCoupon => 'Validate';

  @override
  String get couponValid => 'Coupon Valid';

  @override
  String get recentCoupons => 'Recent Coupons';

  @override
  String get noRecentCoupons => 'No recent coupons';

  @override
  String get noExpiry => 'No Expiry';

  @override
  String get invalidCouponCode => 'Invalid coupon code';

  @override
  String get percentageOff => 'Percentage Off';

  @override
  String get bundleDeals => 'Bundle Deals';

  @override
  String get includedProducts => 'Included Products';

  @override
  String get individualTotal => 'Individual Total';

  @override
  String get bundlePrice => 'Bundle Price';

  @override
  String get youSave => 'You Save';

  @override
  String get noBundleDeals => 'No bundle deals';

  @override
  String get bundleDealsWillAppear => 'Bundle deals will appear here';

  @override
  String validUntilDate(String date) {
    return 'Valid Until: $date';
  }

  @override
  String validFromDate(String date) {
    return 'Valid From: $date';
  }

  @override
  String get autoApplied => 'Auto Applied';

  @override
  String get noActiveOffers => 'No active offers';

  @override
  String get wastage => 'Wastage';

  @override
  String get quantityWasted => 'Quantity Wasted';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoAttached => 'Photo attached';

  @override
  String get tapToTakePhoto => 'Tap to take photo';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get recordWastage => 'Record Wastage';

  @override
  String get spillage => 'Spillage';

  @override
  String get transferInventory => 'Transfer Inventory';

  @override
  String get transferDetails => 'Transfer Details';

  @override
  String get fromStore => 'From Store';

  @override
  String get toStore => 'To Store';

  @override
  String get selectStore => 'Select Store';

  @override
  String get submitTransfer => 'Submit Transfer';

  @override
  String get optionalNote => 'Optional note';

  @override
  String get addInventory => 'Add Inventory';

  @override
  String get scanLabel => 'Scan';

  @override
  String get quantityToAdd => 'Quantity to Add';

  @override
  String get supplierReference => 'Supplier Reference';

  @override
  String get removeInventory => 'Remove Inventory';

  @override
  String get quantityToRemove => 'Quantity to Remove';

  @override
  String get sold => 'Sold';

  @override
  String get transferred => 'Transferred';

  @override
  String get fieldRequired => 'Field required';

  @override
  String get deviceInfo => 'Device Info';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceType => 'Device Type';

  @override
  String get connectionMethod => 'Connection Method';

  @override
  String get networkSettings => 'Network Settings';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get connectionTestPassed => 'Connection test passed';

  @override
  String get saveDevice => 'Save Device';

  @override
  String get addDevice => 'Add Device';

  @override
  String get noPaymentDevices => 'No payment devices';

  @override
  String get addFirstPaymentDevice => 'Add your first payment device';

  @override
  String get totalDevices => 'Total Devices';

  @override
  String get disconnected => 'Disconnected';

  @override
  String testingConnectionName(String name) {
    return 'Testing connection $name...';
  }

  @override
  String connectionSuccessful(String name) {
    return '$name - Connection successful';
  }

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get saleNotFound => 'Sale not found';

  @override
  String get noItems => 'No items';

  @override
  String get customerPaysExtra => 'Customer pays extra';

  @override
  String get submitExchange => 'Submit Exchange';

  @override
  String get reportSettings => 'Report Settings';

  @override
  String get reportType => 'Report Type';

  @override
  String get paymentDistribution => 'Payment Distribution';

  @override
  String get allAccountsSettled => 'All customer accounts are settled';

  @override
  String get selectCustomers => 'Select Customers';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get preview => 'Preview';

  @override
  String get totalDebt => 'Total Debt';

  @override
  String get finalizeInvoice => 'Finalize Invoice';

  @override
  String get saveAsDraft => 'Save as Draft';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get finalize => 'Finalize';

  @override
  String get adjustQuantity => 'Adjust Quantity';

  @override
  String get totalItems => 'Total Items';

  @override
  String get variance => 'Variance';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get share => 'Share';

  @override
  String get full => 'Full';

  @override
  String get processRefund => 'Process Refund';

  @override
  String get refundToCustomer => 'Refund to customer';

  @override
  String get breakdown => 'Breakdown';

  @override
  String nTransactions(int count) {
    return '$count Transactions';
  }

  @override
  String get customReport => 'Custom Report';

  @override
  String get reportBuilder => 'Report Builder';

  @override
  String get groupBy => 'Group By';

  @override
  String get dateRange => 'Date Range';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get periods => 'Periods';

  @override
  String get valueLabel => 'Value';

  @override
  String get tryDifferentFilters => 'Try different filters';

  @override
  String get scan => 'Scan';

  @override
  String get selectProductFirst => 'Select a product first';

  @override
  String get selectProductsForLabels => 'Select products for labels';

  @override
  String printJobSentForLabels(int count) {
    return 'Print job sent for $count labels';
  }

  @override
  String get test => 'Test';

  @override
  String get paperSize58mm => '58mm';

  @override
  String get paperSize80mm => '80mm';

  @override
  String errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get address => 'Address';

  @override
  String get email => 'Email';

  @override
  String get crNumber => 'CR Number';

  @override
  String get city => 'City';

  @override
  String get optional => 'Optional';

  @override
  String get optionalNoteHint => 'Optional note...';

  @override
  String get clearField => 'Clear';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get customerAccounts => 'Customer Accounts';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get keyboardShortcutsHint =>
      'Use these keyboard shortcuts for faster operations';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get searchProducts => 'Search Products';

  @override
  String get splitPayment => 'Split Payment';

  @override
  String get applyDiscount => 'Apply Discount';

  @override
  String get holdInvoice => 'Hold Invoice';

  @override
  String get copyToClipboard => 'Copy';

  @override
  String get invoiceAlreadyRefunded =>
      'This invoice has already been fully refunded';

  @override
  String get invoicePartiallyRefunded =>
      'Some items were previously refunded - showing remaining items only';

  @override
  String get invoiceVoidedCannotRefund =>
      'Faktur ini telah di-void dan tidak dapat dikembalikan';

  @override
  String deviceClockInaccurate(int minutes) {
    return 'Device clock is inaccurate - please adjust the time (offset: $minutes min)';
  }

  @override
  String get saSignInFailed => 'Sign in failed';

  @override
  String get saAccessDenied => 'Access denied. Super Admin role required.';

  @override
  String get saPlatformManagement => 'Alhai POS Platform Management';

  @override
  String get saSuperAdmin => 'Super Admin';

  @override
  String get saEnterCredentials => 'Please enter email and password';

  @override
  String get saSignIn => 'Sign In';

  @override
  String get saSuperAdminOnly =>
      'Only users with Super Admin role can access this panel.';

  @override
  String get saNoSubscriptionsYet => 'No subscriptions yet';

  @override
  String get saNoRevenueData => 'No revenue data';

  @override
  String get saNoLogsFound => 'No logs found';

  @override
  String get saPlatformSummary => 'Platform Summary';

  @override
  String get saSubscriptionStatus => 'Subscription Status';

  @override
  String get saExportData => 'Export Data';

  @override
  String get saExportComingSoon => 'Export coming soon';

  @override
  String get saStoresReport => 'Stores Report';

  @override
  String get saUsersReport => 'Users Report';

  @override
  String get saRevenueReport => 'Revenue Report';

  @override
  String get saActivityLogs => 'Activity Logs';

  @override
  String get saWarnings => 'Warnings';

  @override
  String get saZatcaEInvoicing => 'ZATCA E-invoicing';

  @override
  String get saEnableEInvoicing =>
      'Enable electronic invoicing compliance for all stores';

  @override
  String get saApiEnvironment => 'API Environment';

  @override
  String get saTaxRateVat => 'Tax Rate (VAT)';

  @override
  String get saDefaultLanguage => 'Default Language';

  @override
  String get saDefaultCurrency => 'Default Currency';

  @override
  String get saTrialPeriodDays => 'Trial Period (Days)';

  @override
  String get saResourceUsage => 'Resource Usage';

  @override
  String get saResponseTime => 'Response Time';

  @override
  String get saDbRoundTrip => 'DB Round-trip';

  @override
  String get saExcellent => 'Excellent';

  @override
  String get saGood => 'Good';

  @override
  String get saSlow => 'Slow';

  @override
  String get saRoleUpdated => 'Role updated';

  @override
  String get saNoInvoices => 'No invoices found';

  @override
  String get saErrorLoading => 'Error loading data';

  @override
  String get saUpgradePlan => 'Upgrade Plan';

  @override
  String get saDowngradePlan => 'Downgrade Plan';

  @override
  String get saEditPlan => 'Edit Plan';

  @override
  String get saPaymentGateways => 'Payment Gateways';

  @override
  String get saCreditDebitProcessing => 'Credit/debit card processing';

  @override
  String get saMultiMethodGateway => 'Multi-method payment gateway';

  @override
  String get saBuyNowPayLater => 'Buy now, pay later';

  @override
  String get saInstallmentPayments => 'Installment payments';

  @override
  String get saActiveStores => 'Active Stores';

  @override
  String get saActiveSubscriptions => 'Active Subscriptions';

  @override
  String get saTrialSubscriptions => 'Trial Subscriptions';

  @override
  String get saNewSignups30d => 'New Signups (30d)';

  @override
  String get saSubscribers => 'Subscribers';

  @override
  String get saPercentOfTotal => '% of Total';

  @override
  String get saDeactivateUserConfirm =>
      'Are you sure you want to deactivate this user? Their access will be revoked immediately.';

  @override
  String get saSuspendStoreConfirm =>
      'Are you sure you want to suspend this store? All user access will be revoked immediately.';

  @override
  String get password => 'Password';

  @override
  String get saReportsTitle => 'Reports';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get customerPhoneNumber => 'Customer Phone Number';

  @override
  String get continueAction => 'Continue';

  @override
  String get continueWithCustomer => 'Continue with Customer';

  @override
  String get existingCustomers => 'Existing Customers';

  @override
  String get digitsRemaining => 'digits remaining';

  @override
  String get phoneNumberTooLong => 'Number is too long';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get cancelledByAdmin => 'Cancelled by admin';

  @override
  String get shiftOpenCloseReminders => 'Shift open/close reminders';

  @override
  String get setOrChangeManagerPin => 'Set or change manager PIN';

  @override
  String get dataSynchronizationStatus => 'Data synchronization status';

  @override
  String get reportBalanceSheetTitle => 'الميزانية العمومية';

  @override
  String reportBalanceSheetAsOf(String date) {
    return 'كما في $date';
  }

  @override
  String get reportAssets => 'الأصول';

  @override
  String get reportCurrentAssets => 'الأصول المتداولة';

  @override
  String get reportCashInDrawer => 'النقد في الصندوق';

  @override
  String get reportAccountsReceivable => 'ذمم مدينة (عملاء)';

  @override
  String get reportInventoryValue => 'قيمة المخزون';

  @override
  String get reportTotalCurrentAssets => 'إجمالي الأصول المتداولة';

  @override
  String get reportTotalAssets => 'إجمالي الأصول';

  @override
  String get reportLiabilities => 'الالتزامات';

  @override
  String get reportCurrentLiabilities => 'الالتزامات المتداولة';

  @override
  String get reportAccountsPayable => 'ذمم دائنة (موردون)';

  @override
  String get reportTotalCurrentLiabilities => 'إجمالي الالتزامات المتداولة';

  @override
  String get reportTotalLiabilities => 'إجمالي الالتزامات';

  @override
  String get reportEquity => 'حقوق الملكية';

  @override
  String get reportNetEquity => 'صافي حقوق الملكية';

  @override
  String get reportAccountingEquation => 'معادلة المحاسبة';

  @override
  String get reportAssetsEqualsLiabilitiesPlusEquity =>
      'الأصول = الالتزامات + حقوق الملكية';

  @override
  String get reportCashFlowTitle => 'قائمة التدفق النقدي';

  @override
  String get reportNetCashFlow => 'صافي التدفق النقدي';

  @override
  String get reportOperatingActivities => 'الأنشطة التشغيلية';

  @override
  String get reportSalesReceipts => 'إيرادات المبيعات';

  @override
  String get reportExpensesPaid => 'المصروفات المدفوعة';

  @override
  String get reportTaxesPaidVat => 'الضرائب المدفوعة (ضريبة القيمة المضافة)';

  @override
  String get reportInvestingActivities => 'الأنشطة الاستثمارية';

  @override
  String get reportPurchasePayments => 'مدفوعات المشتريات';

  @override
  String get reportFinancingActivities => 'الأنشطة التمويلية';

  @override
  String get reportCashDeposit => 'إيداع نقدي';

  @override
  String get reportCashWithdrawal => 'سحب نقدي';

  @override
  String get reportThisQuarter => 'هذا الربع';

  @override
  String get reportThisYear => 'هذه السنة';

  @override
  String get reportQuarterly => 'ربع سنوي';

  @override
  String get reportAnnual => 'سنوي';

  @override
  String get reportDebtAgingTitle => 'تقرير أعمار الديون';

  @override
  String get reportDebtBucket0to30 => '0-30 يوم';

  @override
  String get reportDebtBucket31to60 => '31-60 يوم';

  @override
  String get reportDebtBucket61to90 => '61-90 يوم';

  @override
  String get reportDebtBucket90plus => '+90 يوم';

  @override
  String get reportTotalDebts => 'إجمالي الديون';

  @override
  String reportNDays(int count) {
    return '$count يوم';
  }

  @override
  String get reportComparisonTitle => 'تقرير المقارنة';

  @override
  String get reportIndicator => 'المؤشر';

  @override
  String get reportChange => 'التغيير';

  @override
  String get reportLastMonth => 'الشهر الماضي';

  @override
  String get reportLastQuarter => 'الربع الماضي';

  @override
  String get reportLastYear => 'السنة الماضية';

  @override
  String get reportCurrentPeriod => 'الفترة الحالية';

  @override
  String get reportPreviousPeriod => 'الفترة السابقة';

  @override
  String get reportZakatTitle => 'حساب الزكاة';

  @override
  String get reportZakatDue => 'وجبت الزكاة';

  @override
  String get reportZakatBelowNisab => 'لم يبلغ النصاب';

  @override
  String get reportZakatAmountDue => 'مقدار الزكاة الواجبة';

  @override
  String reportZakatRateOf(String rate) {
    return 'بنسبة $rate% من وعاء الزكاة';
  }

  @override
  String reportNisabThreshold(String amount) {
    return 'النصاب الشرعي: $amount ر.س';
  }

  @override
  String reportCurrentZakatBase(String amount) {
    return 'وعاء الزكاة الحالي: $amount ر.س';
  }

  @override
  String reportNisabInfo(String amount) {
    return 'النصاب: $amount ر.س (قيمة 85 جرام من الذهب تقريباً)';
  }

  @override
  String get reportZakatAssets => 'أصول الزكاة (+)';

  @override
  String get reportGoodsAndInventory => 'قيمة البضاعة والمخزون';

  @override
  String get reportAvailableCash => 'النقد المتوفر';

  @override
  String get reportExpectedReceivables => 'الديون المتوقع تحصيلها';

  @override
  String get reportDeductions => 'الخصومات (-)';

  @override
  String get reportDebtsToSuppliers => 'الديون الواجبة للموردين';

  @override
  String get reportOtherLiabilities => 'التزامات أخرى';

  @override
  String get reportNetZakatBase => 'وعاء الزكاة الصافي';

  @override
  String get reportZakatDisclaimer =>
      'تنبيه: هذا الحساب تقريبي. يُنصح بمراجعة مختص شرعي لتحديد الزكاة الواجبة بدقة.';

  @override
  String get reportPurchaseTitle => 'تقرير المشتريات';

  @override
  String get reportPurchasesBySupplier => 'المشتريات حسب المورد';

  @override
  String get reportRecentInvoices => 'آخر الفواتير';

  @override
  String get reportNoPurchasesInPeriod => 'لا توجد مشتريات في هذه الفترة';

  @override
  String reportNInvoices(int count) {
    return '$count فاتورة';
  }

  @override
  String get reportTotalTax => 'إجمالي الضريبة';

  @override
  String get reportExportSuccess => 'تم تصدير التقرير بنجاح';

  @override
  String reportExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get saSaveChanges => 'حفظ التغييرات';

  @override
  String get saSaving => 'جاري الحفظ...';

  @override
  String get saDiscardChanges => 'تجاهل';

  @override
  String get saConfirmSave => 'حفظ';

  @override
  String get saPlatformSettingsConfirm =>
      'هذه التغييرات تؤثر على جميع المؤسسات في المنصة. هل تريد الحفظ؟';

  @override
  String get saPlatformSettingsSaved => 'تم حفظ إعدادات المنصة بنجاح';

  @override
  String get saPlatformSettingsSaveFailed => 'فشل حفظ إعدادات المنصة';

  @override
  String get saErrorLoadingSettings => 'خطأ في تحميل الإعدادات';

  @override
  String get saEnvProduction => 'الإنتاج';

  @override
  String get saEnvSandbox => 'بيئة الاختبار';

  @override
  String get saMoyasarDescription => 'معالجة بطاقات الائتمان والخصم';

  @override
  String get saHyperpayDescription => 'بوابة دفع متعددة الطرق';

  @override
  String get saTabbyDescription => 'اشترِ الآن وادفع لاحقاً';

  @override
  String get saTamaraDescription => 'دفعات بالتقسيط';

  @override
  String get saGeneral => 'عام';

  @override
  String get saLanguageArabic => 'العربية';

  @override
  String get saLanguageEnglish => 'الإنجليزية';

  @override
  String get saAuditLog => 'سجل التدقيق';

  @override
  String get saAuditLogRefresh => 'تحديث';

  @override
  String get saAuditFilterAll => 'الكل';

  @override
  String get saAuditFilterAuth => 'مصادقة';

  @override
  String get saAuditFilterStore => 'متجر';

  @override
  String get saAuditFilterUser => 'مستخدم';

  @override
  String get saAuditFilterSubscription => 'اشتراك';

  @override
  String get saAuditSearchHint => 'ابحث بالبريد أو المعرّف أو الإجراء...';

  @override
  String get saAuditLoadFailed => 'فشل تحميل سجل التدقيق';

  @override
  String get saAuditLoadRetry => 'إعادة المحاولة';

  @override
  String get saAuditNoEntries => 'لا توجد سجلات تدقيق';

  @override
  String saAuditEntryBy(String email) {
    return 'بواسطة $email';
  }

  @override
  String get saReportsExportComingSoon =>
      'التصدير غير متاح حالياً — سيضاف قريباً';

  @override
  String get saSystemHealthMetricsNote =>
      'مقاييس المعالج/الذاكرة/القرص تتطلب نقطة خادم مخصصة — غير متصلة بعد';

  @override
  String get saMfaScanQr => 'امسح رمز QR في تطبيق المصادقة';

  @override
  String get saMfaSecretFallback => 'أو أدخل هذا المفتاح يدوياً:';

  @override
  String get saMfaCopied => 'تم النسخ';

  @override
  String get saErrorGeneric => 'حدث خطأ ما';

  @override
  String get saErrorNetwork => 'خطأ في الشبكة — تحقق من اتصالك';

  @override
  String get saErrorRetry => 'إعادة المحاولة';

  @override
  String get saErrorTechnical => 'تفاصيل تقنية';

  @override
  String get saNext => 'التالي';

  @override
  String get saBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get saPopularBadge => 'الأكثر طلباً';

  @override
  String get saRefresh => 'تحديث';

  @override
  String get saPlanUpdated => 'تم تحديث الباقة';

  @override
  String get saRenewal => 'التجديد';

  @override
  String get saBusinessTypeGrocery => 'بقالة';

  @override
  String get saBusinessTypeRestaurant => 'مطعم';

  @override
  String get saBusinessTypeRetail => 'تجزئة';

  @override
  String get saBusinessTypeServices => 'خدمات';

  @override
  String get saNoPlanRevenueData => 'لا توجد بيانات إيرادات للباقات';

  @override
  String get saNoStoreRevenueData => 'لا توجد بيانات إيرادات للمتاجر';

  @override
  String get saNoActiveUserData => 'لا توجد بيانات للمستخدمين النشطين';

  @override
  String get saNoTransactionData => 'لا توجد بيانات معاملات';

  @override
  String get saMfaSetupTitle => 'إعداد المصادقة الثنائية';

  @override
  String get saMfaVerifyTitle => 'التحقق الثنائي';

  @override
  String get saMfaEnrollmentInstruction =>
      'امسح رمز QR بتطبيق المصادقة (Google Authenticator أو Authy وغيرها) ثم أدخل الرمز المكوّن من 6 أرقام لإكمال الإعداد.';

  @override
  String get saMfaVerifyInstruction =>
      'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة.';

  @override
  String get saMfaCopy => 'نسخ';

  @override
  String get saMfaCompleteSetup => 'إكمال الإعداد';

  @override
  String get saMfaVerifyButton => 'تحقق';

  @override
  String get saMfaEnterValidCode => 'أدخل رمزاً صحيحاً مكوّناً من 6 أرقام';

  @override
  String get saMfaTooManyAttempts =>
      'محاولات فاشلة كثيرة. تم القفل لمدة 30 دقيقة.';

  @override
  String saMfaAccountLocked(int minutes) {
    return 'تم قفل الحساب. حاول مجدداً خلال $minutes دقيقة.';
  }

  @override
  String saMfaInvalidCode(int remaining) {
    return 'رمز غير صحيح. $remaining محاولات متبقية.';
  }

  @override
  String get saMfaEnrollmentFailed =>
      'فشل تسجيل المصادقة الثنائية. تأكد من تفعيل MFA في مشروع Supabase.';

  @override
  String get saMfaEnrollmentNoData => 'لم ترجع عملية تسجيل TOTP أي بيانات.';

  @override
  String get exchangeTitle => 'استبدال';

  @override
  String get itemsToReturn => 'عناصر للإرجاع';

  @override
  String get newItemsToAdd => 'عناصر جديدة للإضافة';

  @override
  String get exchangeRequiresNewItem =>
      'الاستبدال يتطلب إضافة عنصر جديد واحد على الأقل. للاسترداد البحت، استخدم شاشة المرتجعات التي تربط الاسترداد بفاتورة البيع الأصلية.';

  @override
  String get selectOriginalSaleTitle => 'اختر الفاتورة الأصلية';

  @override
  String get originalSaleLabel => 'الفاتورة الأصلية';

  @override
  String get originalSaleRequired =>
      'اختر الفاتورة الأصلية قبل تأكيد الاستبدال';

  @override
  String get changeOriginalSale => 'تغيير';

  @override
  String get searchByReceiptNumber => 'ابحث برقم الإيصال…';

  @override
  String recentSalesLastNDays(int days) {
    return 'مبيعات آخر $days يوم';
  }

  @override
  String noEligibleSalesFound(int days) {
    return 'لا توجد مبيعات مؤهَّلة في آخر $days يوم';
  }

  @override
  String get silentLimitBadgeTitle => 'تم بلوغ الحد الأقصى للعرض';

  @override
  String silentLimitBadgeMessage(int limit) {
    return 'تم عرض $limit صف. قد توجد بيانات إضافية مخفية — ضيِّق الفلاتر للحصول على نتائج كاملة.';
  }

  @override
  String get silentLimitBadgeAction => 'تضييق الفلاتر';

  @override
  String get backupPassphraseTitle => 'كلمة سر النسخة الاحتياطية';

  @override
  String get backupPassphraseHelper =>
      'اختر كلمة سر قوية لتشفير النسخة. لا توجد طريقة لاستعادتها إن نُسيَت.';

  @override
  String get backupPassphraseLabel => 'كلمة السر';

  @override
  String get backupPassphraseConfirmLabel => 'تأكيد كلمة السر';

  @override
  String get backupPassphraseTooShort =>
      'كلمة السر يجب أن تكون 8 أحرف على الأقل';

  @override
  String get backupPassphraseMismatch => 'كلمتا السر غير متطابقتين';

  @override
  String get backupEncryptedNotice =>
      'النسخة مشفّرة بـ AES-256-GCM. لا يمكن قراءتها بدون كلمة السر — احفظها في مكان آمن.';

  @override
  String get saveBackupFile => 'حفظ كملف';

  @override
  String get openBackupFile => 'فتح ملف';

  @override
  String get backupShareSubject => 'نسخة احتياطية مُشفَّرة - الحاي POS';

  @override
  String get backupCopiedToClipboardMasked =>
      'تم النسخ — سيُمسَح من الحافظة بعد 60 ثانية';

  @override
  String get restoreSourcePrompt => 'اختر مصدر النسخة الاحتياطية:';

  @override
  String get restoreOverwriteWarning =>
      'سيتم استبدال البيانات الحالية. لا يمكن التراجع.';

  @override
  String get restorePassphraseTitle => 'أدخل كلمة سر النسخة';

  @override
  String get restoreBadPassphrase => 'كلمة السر خاطئة أو الملف تالف';

  @override
  String get restoreCorruptBackup =>
      'الملف ليس نسخة احتياطية صالحة من تطبيق الحاي';

  @override
  String get restoreSchemaMismatchTitle => 'إصدار قاعدة بيانات غير متوافق';

  @override
  String restoreSchemaMismatchBody(int backupVersion, int appVersion) {
    return 'النسخة من إصدار $backupVersion، التطبيق على إصدار $appVersion. حدِّث التطبيق أو ارجع لإصدار مطابق قبل الاستعادة.';
  }

  @override
  String get unitCostLabel => 'تكلفة الوحدة (اختياري)';

  @override
  String get unitCostHint => 'أدخل تكلفة الشراء لتحديث متوسط التكلفة المرجح';

  @override
  String get autoBackupHelper =>
      'تفعيل النسخ الاحتياطي التلقائي حسب الجدول المُحدَّد';

  @override
  String autoBackupLastFiredAt(String when) {
    return 'آخر تشغيل تلقائي: $when';
  }

  @override
  String get splitReceiptTitle => 'إيصال الدفع المجزأ';

  @override
  String get paymentBreakdown => 'تفاصيل الدفع';

  @override
  String get zatcaQrTitle => 'رمز QR للفوترة الإلكترونية';

  @override
  String get splitRefundTitle => 'استرداد مجزأ';

  @override
  String get refundByPaymentMethod => 'الاسترداد حسب طريقة الدفع';

  @override
  String get exceedsOriginalAmount => 'المبلغ يتجاوز الأصلي';

  @override
  String get refundSummary => 'ملخص الاسترداد';

  @override
  String get originalTotal => 'الإجمالي الأصلي';

  @override
  String refundLineLabel(String method) {
    return 'استرداد $method';
  }

  @override
  String get refundAmountExceedsOriginal =>
      'المبلغ المسترد يتجاوز المبلغ الأصلي';

  @override
  String get filterCompletedOnly => 'المكتملة فقط';

  @override
  String get filterCompletedOnlyDesc => 'المبيعات غير المكتملة مخفية';

  @override
  String get pullToRefresh => 'اسحب للتحديث';
}
