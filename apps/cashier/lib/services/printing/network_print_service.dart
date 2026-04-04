/// Network TCP print service for ESC/POS thermal printers
///
/// Connects to network printers via raw TCP socket on port 9100
/// (the standard ESC/POS printer port). Supports printer discovery
/// via broadcast ping, connection keepalive, and automatic reconnection.
///
/// On web, all operations return "not supported" because dart:io
/// sockets are not available in the browser environment.
///
/// Uses platform channels on web to avoid dart:io dependency.
/// On mobile/desktop, delegates to the native implementation via
/// [NetworkPrintServiceImpl].
library;

export 'network_print_service_impl.dart'
    if (dart.library.html) 'network_print_service_web.dart'
    show NetworkPrintService;
