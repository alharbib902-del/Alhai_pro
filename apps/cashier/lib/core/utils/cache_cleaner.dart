/// Platform-safe cache cleaner with conditional import
library;

export 'cache_cleaner_stub.dart'
    if (dart.library.html) 'cache_cleaner_web.dart';
