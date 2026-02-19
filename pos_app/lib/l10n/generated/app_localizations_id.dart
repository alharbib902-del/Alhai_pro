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
  String get monthlyCloseTitle => 'Monthly Close';

  @override
  String get monthlyCloseDesc => 'Close month and calculate receivables';

  @override
  String get totalReceivables => 'Total Receivables';

  @override
  String get interestRate => 'Interest Rate';

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
  String get resetAction => 'Reset';

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
  String get orderHistory => 'سجل الطلبات';

  @override
  String get selectDateRange => 'تحديد فترة';

  @override
  String get orderSearchHint => 'بحث برقم الطلب أو معرف العميل...';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusPreparing => 'قيد التحضير';

  @override
  String get orderStatusReady => 'جاهز';

  @override
  String get orderStatusDelivering => 'قيد التوصيل';

  @override
  String get filterOrders => 'فلترة الطلبات';

  @override
  String get channelApp => 'التطبيق';

  @override
  String get channelWhatsapp => 'واتساب';

  @override
  String get channelPos => 'نقطة البيع';

  @override
  String get paymentCashType => 'نقدي';

  @override
  String get paymentMixed => 'مختلط';

  @override
  String get paymentOnline => 'إلكتروني';

  @override
  String get shareAction => 'مشاركة';

  @override
  String get exportOrders => 'تصدير الطلبات';

  @override
  String get selectExportFormat => 'اختر صيغة التصدير';

  @override
  String get exportedAsExcel => 'تم التصدير كـ Excel';

  @override
  String get exportedAsPdf => 'تم التصدير كـ PDF';

  @override
  String get alertSettings => 'إعدادات التنبيهات';

  @override
  String get acknowledgeAll => 'تأكيد الكل';

  @override
  String allWithCount(int count) {
    return 'الكل ($count)';
  }

  @override
  String lowStockWithCount(int count) {
    return 'نفاد مخزون ($count)';
  }

  @override
  String expiryWithCount(int count) {
    return 'انتهاء صلاحية ($count)';
  }

  @override
  String get urgentAlerts => 'تنبيهات عاجلة';

  @override
  String get nearExpiry => 'قريب الانتهاء';

  @override
  String get noAlerts => 'لا توجد تنبيهات';

  @override
  String get alertDismissed => 'تم إخفاء التنبيه';

  @override
  String get undo => 'تراجع';

  @override
  String get criticalPriority => 'حرج';

  @override
  String get highPriority => 'عاجل';

  @override
  String stockAlertMessage(int current, int threshold) {
    return 'الكمية: $current (الحد الأدنى: $threshold)';
  }

  @override
  String get expiryAlertLabel => 'تنبيه صلاحية';

  @override
  String get currentQuantity => 'الكمية الحالية';

  @override
  String get minimumThreshold => 'الحد الأدنى';

  @override
  String get dismissAction => 'تجاهل';

  @override
  String get lowStockNotifications => 'تنبيهات نفاد المخزون';

  @override
  String get expiryNotifications => 'تنبيهات انتهاء الصلاحية';

  @override
  String get minimumStockLevel => 'الحد الأدنى للمخزون';

  @override
  String thresholdUnits(int count) {
    return '$count وحدة';
  }

  @override
  String get acknowledgeAllAlerts => 'تأكيد جميع التنبيهات';

  @override
  String willDismissAlerts(int count) {
    return 'سيتم إخفاء $count تنبيه';
  }

  @override
  String get allAlertsAcknowledged => 'تم تأكيد جميع التنبيهات';

  @override
  String get createPurchaseOrder => 'إنشاء طلب شراء';

  @override
  String productLabelName(String name) {
    return 'المنتج: $name';
  }

  @override
  String get requiredQuantity => 'الكمية المطلوبة';

  @override
  String get createAction => 'إنشاء';

  @override
  String get purchaseOrderCreated => 'تم إنشاء طلب الشراء';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String productCountUnit(int count) {
    return '$count منتج';
  }

  @override
  String get iconLabel => 'الأيقونة:';

  @override
  String get colorLabel => 'اللون:';

  @override
  String deleteCategoryMessage(String name, int count) {
    return 'هل تريد حذف فئة \"$name\"؟\nسيتم نقل $count منتج إلى \"بدون فئة\".';
  }

  @override
  String productNumber(int number) {
    return 'منتج $number';
  }

  @override
  String priceWithCurrency(String price) {
    return '$price ر.س';
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
  String interestRateAndGrace(String rate, String days) {
    return 'Interest rate: $rate% | Grace period: $days days';
  }

  @override
  String get selectedCustomers => 'Selected Customers';

  @override
  String get expectedInterests => 'Expected Interests';

  @override
  String get noDebtsNeedClosing => 'No debts need closing';

  @override
  String get allCustomersWithinGrace =>
      'All customers are within the grace period';

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
  String totalInterestsLabel(String amount) {
    return 'Total interests: $amount SAR';
  }

  @override
  String monthCloseSuccess(int count) {
    return 'Month closed for $count customer(s)';
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
  String get noteLabel => 'Note';

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
  String get supplierLabel => 'Supplier';

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
    return '$count items';
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
  String get gotIt => 'فهمت';

  @override
  String get print => 'طباعة';

  @override
  String get display => 'عرض';

  @override
  String get item => 'عنصر';

  @override
  String get invoice => 'فاتورة';

  @override
  String get accept => 'قبول';

  @override
  String get details => 'تفاصيل';

  @override
  String get newLabel => 'جديد';

  @override
  String get mixed => 'مختلط';

  @override
  String get lowStockLabel => 'Rendah';

  @override
  String get debtor => 'مدين';

  @override
  String get creditor => 'دائن';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String get returnLabel => 'استرجاع';

  @override
  String get skip => 'تخطي';

  @override
  String get send => 'إرسال';

  @override
  String get cloud => 'سحابي';

  @override
  String get defaultLabel => 'افتراضي';

  @override
  String get closed => 'مغلق';

  @override
  String get owes => 'عليه';

  @override
  String get due => 'له';

  @override
  String get balanced => 'متوازن';

  @override
  String get offlineModeTitle => 'الوضع غير المتصل';

  @override
  String get offlineModeDescription => 'يمكنك الاستمرار في استخدام التطبيق:';

  @override
  String get offlineCanSell => 'إجراء عمليات البيع';

  @override
  String get offlineCanAddToCart => 'إضافة منتجات للسلة';

  @override
  String get offlineCanPrint => 'طباعة الإيصالات';

  @override
  String get offlineAutoSync =>
      'سيتم مزامنة البيانات تلقائياً عند عودة الاتصال.';

  @override
  String get offlineSavingLocally => 'غير متصل - يتم حفظ العمليات محلياً';

  @override
  String get seconds => 'ثانية';

  @override
  String get errors => 'أخطاء';

  @override
  String get syncLabel => 'مزامنة';

  @override
  String get slow => 'بطيئة';

  @override
  String get myGrocery => 'بقالتي';

  @override
  String get cashier => 'كاشير';

  @override
  String get goBack => 'رجوع';

  @override
  String get menuLabel => 'القائمة';

  @override
  String get gold => 'ذهبي';

  @override
  String get silver => 'فضي';

  @override
  String get diamond => 'ماسي';

  @override
  String get bronze => 'برونزي';

  @override
  String get saudiArabia => 'السعودية';

  @override
  String get uae => 'الإمارات';

  @override
  String get kuwait => 'الكويت';

  @override
  String get bahrain => 'البحرين';

  @override
  String get qatar => 'قطر';

  @override
  String get oman => 'عُمان';

  @override
  String get control => 'تحكم';

  @override
  String get strong => 'قوي';

  @override
  String get medium => 'متوسط';

  @override
  String get weak => 'ضعيف';

  @override
  String get good => 'جيد';

  @override
  String get danger => 'خطر';

  @override
  String get currentLabel => 'الحالي';

  @override
  String get suggested => 'المقترح';

  @override
  String get actual => 'الفعلي';

  @override
  String get forecast => 'المتوقع';

  @override
  String get critical => 'حرج';

  @override
  String get high => 'عالي';

  @override
  String get low => 'منخفض';

  @override
  String get investigation => 'التحقيق';

  @override
  String get apply => 'تطبيق';

  @override
  String get run => 'تشغيل';

  @override
  String get positive => 'إيجابي';

  @override
  String get neutral => 'محايد';

  @override
  String get negative => 'سلبي';

  @override
  String get elastic => 'مرن';

  @override
  String get demand => 'الطلب';

  @override
  String get quality => 'الجودة';

  @override
  String get luxury => 'فاخر';

  @override
  String get economic => 'اقتصادي';

  @override
  String get ourStore => 'متجرنا';

  @override
  String get upcoming => 'قادم';

  @override
  String get cost => 'التكلفة';

  @override
  String get duration => 'المدة';

  @override
  String get quiet => 'هادئ';

  @override
  String get busy => 'مزدحم';

  @override
  String get outstanding => 'متميز';

  @override
  String get donate => 'تبرع';

  @override
  String get day => 'يوم';

  @override
  String get days => 'أيام';

  @override
  String get projected => 'المتوقع';

  @override
  String get analysis => 'تحليل';

  @override
  String get review => 'مراجعة';

  @override
  String get productCategory => 'التصنيف';

  @override
  String get ourPrice => 'سعرنا';

  @override
  String get position => 'الموقف';

  @override
  String get cheapest => 'الأرخص';

  @override
  String get mostExpensive => 'الأغلى';

  @override
  String get soldOut => 'Habis';

  @override
  String get noDataAvailable => 'لا توجد بيانات';

  @override
  String get noDataFoundMessage => 'لم يتم العثور على أي بيانات';

  @override
  String get noSearchResultsFound => 'لا توجد نتائج';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get noCustomers => 'لا يوجد عملاء';

  @override
  String get addCustomersToStart => 'أضف عملاء جدد للبدء';

  @override
  String get noOrdersYet => 'لم تقم بأي طلبات بعد';

  @override
  String get noConnection => 'لا يوجد اتصال';

  @override
  String get checkInternet => 'تحقق من اتصالك بالإنترنت';

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String get browseProducts => 'تصفح المنتجات';

  @override
  String noResultsFor(String query) {
    return 'لم يتم العثور على نتائج لـ \"$query\"';
  }

  @override
  String get paidLabel => 'المدفوع';

  @override
  String get remainingLabel => 'المتبقي';

  @override
  String get completeLabel => 'مكتمل ✓';

  @override
  String get addPayment => 'إضافة';

  @override
  String get payments => 'الدفعات';

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
}
