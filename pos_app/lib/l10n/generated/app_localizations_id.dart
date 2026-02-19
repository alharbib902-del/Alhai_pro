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
  String get revenue => 'Pendapatan';

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
  String get scanBarcode => 'Pindai Barcode';

  @override
  String get activeProduct => 'Produk Aktif';

  @override
  String get currency => 'SAR';

  @override
  String hoursAgo(int count) {
    return '$count jam yang lalu';
  }

  @override
  String daysAgo(int count) {
    return '$count hari yang lalu';
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
    return '$count kategori';
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
    return '$count faktur menunggu pembayaran';
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
    return '$count dipilih';
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
  String get invoiceNumberLabel => 'Nomor:';

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
  String customerCount(String count) {
    return '$count pelanggan';
  }

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
  String get customerAddedSuccess => 'Pelanggan berhasil ditambahkan';

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
  String get expenseAmount => 'المبلغ';

  @override
  String get expenseDate => 'التاريخ';

  @override
  String get expenseCategory => 'التصنيف';

  @override
  String get expenseNotes => 'ملاحظات';

  @override
  String get noExpenses => 'Tidak ada pengeluaran tercatat';

  @override
  String get drawerStatus => 'حالة الدرج';

  @override
  String get drawerOpen => 'مفتوح';

  @override
  String get drawerClosed => 'مغلق';

  @override
  String get cashIn => 'إيداع نقدي';

  @override
  String get cashOut => 'سحب نقدي';

  @override
  String get expectedAmount => 'المبلغ المتوقع';

  @override
  String get countedAmount => 'المبلغ المحسوب';

  @override
  String get difference => 'الفرق';

  @override
  String get openDrawerAction => 'فتح الدرج';

  @override
  String get closeDrawerAction => 'إغلاق الدرج';

  @override
  String get monthlyCloseTitle => 'الإغلاق الشهري';

  @override
  String get monthlyCloseDesc => 'إغلاق الشهر وحساب المستحقات';

  @override
  String get totalReceivables => 'إجمالي المستحقات';

  @override
  String get interestRate => 'نسبة الفائدة';

  @override
  String get closeMonth => 'إغلاق الشهر';

  @override
  String get shiftsTitle => 'Shift';

  @override
  String get currentShift => 'الوردية الحالية';

  @override
  String get shiftHistory => 'سجل الورديات';

  @override
  String get openShiftAction => 'فتح وردية';

  @override
  String get closeShiftAction => 'إغلاق وردية';

  @override
  String get shiftStartTime => 'وقت البدء';

  @override
  String get shiftEndTime => 'وقت الانتهاء';

  @override
  String get shiftTotalSales => 'إجمالي المبيعات';

  @override
  String get shiftTotalOrders => 'إجمالي الطلبات';

  @override
  String get startingCash => 'النقد الابتدائي';

  @override
  String get cashierName => 'الكاشير';

  @override
  String get shiftDuration => 'المدة';

  @override
  String get noShifts => 'لا توجد ورديات مسجلة';

  @override
  String get purchasesTitle => 'Pembelian';

  @override
  String get newPurchase => 'مشترى جديد';

  @override
  String get smartReorder => 'إعادة طلب ذكي';

  @override
  String get aiInvoiceImport => 'استيراد فاتورة بالذكاء الاصطناعي';

  @override
  String get aiInvoiceReview => 'مراجعة فاتورة AI';

  @override
  String get purchaseOrder => 'أمر شراء';

  @override
  String get purchaseTotal => 'إجمالي المشتريات';

  @override
  String get purchaseDate => 'تاريخ الشراء';

  @override
  String get suppliersTitle => 'Pemasok';

  @override
  String get addSupplier => 'إضافة مورد';

  @override
  String get supplierName => 'اسم المورد';

  @override
  String get supplierPhone => 'الهاتف';

  @override
  String get supplierEmail => 'البريد الإلكتروني';

  @override
  String get supplierAddress => 'العنوان';

  @override
  String get totalSuppliers => 'إجمالي الموردين';

  @override
  String get supplierDetails => 'تفاصيل المورد';

  @override
  String get noSuppliers => 'لا يوجد موردين';

  @override
  String get discountsTitle => 'Diskon';

  @override
  String get addDiscount => 'إضافة خصم';

  @override
  String get discountName => 'اسم الخصم';

  @override
  String get discountType => 'نوع الخصم';

  @override
  String get discountValue => 'القيمة';

  @override
  String get percentageDiscount => 'نسبة مئوية';

  @override
  String get fixedDiscount => 'مبلغ ثابت';

  @override
  String get activeDiscounts => 'الخصومات النشطة';

  @override
  String get couponsTitle => 'Kupon';

  @override
  String get addCoupon => 'إضافة كوبون';

  @override
  String get couponCode => 'رمز الكوبون';

  @override
  String get couponUsage => 'الاستخدام';

  @override
  String get couponExpiry => 'الصلاحية';

  @override
  String get totalCoupons => 'إجمالي الكوبونات';

  @override
  String get activeCoupons => 'نشطة';

  @override
  String get expiredCoupons => 'منتهية';

  @override
  String get specialOffersTitle => 'Penawaran Khusus';

  @override
  String get addOffer => 'إضافة عرض';

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerStartDate => 'تاريخ البدء';

  @override
  String get offerEndDate => 'تاريخ الانتهاء';

  @override
  String get smartPromotionsTitle => 'Promosi Cerdas';

  @override
  String get activePromotions => 'العروض النشطة';

  @override
  String get suggestedPromotions => 'اقتراحات AI';

  @override
  String get loyaltyTitle => 'Program Loyalitas';

  @override
  String get loyaltyMembers => 'الأعضاء';

  @override
  String get loyaltyRewards => 'المكافآت';

  @override
  String get loyaltyTiers => 'المستويات';

  @override
  String get totalMembers => 'إجمالي الأعضاء';

  @override
  String get pointsIssued => 'النقاط الممنوحة';

  @override
  String get pointsRedeemed => 'النقاط المستبدلة';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get printQueueTitle => 'Antrean Cetak';

  @override
  String get printAll => 'طباعة الكل';

  @override
  String get cancelAll => 'إلغاء الكل';

  @override
  String get noPrintJobs => 'لا توجد مهام طباعة';

  @override
  String get syncStatusTitle => 'Status Sinkronisasi';

  @override
  String get lastSyncTime => 'آخر مزامنة';

  @override
  String get pendingItems => 'عناصر معلقة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get pendingTransactionsTitle => 'العمليات المعلقة';

  @override
  String get conflictResolutionTitle => 'حل التعارضات';

  @override
  String get localValue => 'محلي';

  @override
  String get serverValue => 'الخادم';

  @override
  String get keepLocal => 'الاحتفاظ بالمحلي';

  @override
  String get keepServer => 'الاحتفاظ بالخادم';

  @override
  String get driversTitle => 'Pengemudi';

  @override
  String get addDriver => 'إضافة سائق';

  @override
  String get driverName => 'اسم السائق';

  @override
  String get driverStatus => 'الحالة';

  @override
  String get delivering => 'في التوصيل';

  @override
  String get totalDeliveries => 'إجمالي التوصيلات';

  @override
  String get driverRating => 'التقييم';

  @override
  String get branchesTitle => 'Cabang';

  @override
  String get addBranchAction => 'إضافة فرع';

  @override
  String get branchName => 'اسم الفرع';

  @override
  String get branchEmployees => 'الموظفين';

  @override
  String get branchSales => 'مبيعات اليوم';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get role => 'الدور';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get storeSettings => 'Pengaturan Toko';

  @override
  String get posSettings => 'Pengaturan POS';

  @override
  String get printerSettings => 'Pengaturan Printer';

  @override
  String get paymentDevicesSettings => 'أجهزة الدفع';

  @override
  String get barcodeSettings => 'إعدادات الباركود';

  @override
  String get receiptTemplate => 'قالب الإيصال';

  @override
  String get taxSettings => 'إعدادات الضريبة';

  @override
  String get discountSettings => 'إعدادات الخصومات';

  @override
  String get interestSettings => 'إعدادات الفوائد';

  @override
  String get languageSettings => 'اللغة';

  @override
  String get themeSettings => 'المظهر';

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
  String get notificationSettings => 'الإشعارات';

  @override
  String get zatcaCompliance => 'Kepatuhan ZATCA';

  @override
  String get helpSupport => 'Bantuan & Dukungan';

  @override
  String get general => 'عام';

  @override
  String get appearance => 'المظهر';

  @override
  String get securitySection => 'الأمان';

  @override
  String get advanced => 'متقدم';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get configure => 'تهيئة';

  @override
  String get connected => 'متصل';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get testConnection => 'اختبار الاتصال';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get autoBackup => 'نسخ احتياطي تلقائي';

  @override
  String get manualBackup => 'نسخ احتياطي الآن';

  @override
  String get restoreBackup => 'استعادة';

  @override
  String get biometricAuth => 'المصادقة البيومترية';

  @override
  String get sessionTimeout => 'مهلة الجلسة';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get twoFactorAuth => 'المصادقة الثنائية';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get userEmail => 'البريد الإلكتروني';

  @override
  String get userPhone => 'الهاتف';

  @override
  String get addRole => 'إضافة دور';

  @override
  String get roleName => 'اسم الدور';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get documentation => 'التوثيق';

  @override
  String get reportBug => 'الإبلاغ عن خطأ';

  @override
  String get zatcaRegistration => 'تسجيل هيئة الزكاة';

  @override
  String get eInvoicing => 'الفوترة الإلكترونية';

  @override
  String get qrCode => 'رمز QR';

  @override
  String get vatNumber => 'الرقم الضريبي';

  @override
  String get taxNumber => 'رقم الضريبة';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get emailNotifications => 'إشعارات البريد';

  @override
  String get smsNotifications => 'إشعارات SMS';

  @override
  String get orderNotifications => 'إشعارات الطلبات';

  @override
  String get stockNotifications => 'تنبيهات المخزون';

  @override
  String get paymentNotifications => 'إشعارات الدفع';

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
}
