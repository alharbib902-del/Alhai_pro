/// Web implementation: opens a URL in a new browser tab.
library;

import 'package:web/web.dart' as web;

void openUrlInNewTab(String url) {
  web.window.open(url, '_blank');
}
