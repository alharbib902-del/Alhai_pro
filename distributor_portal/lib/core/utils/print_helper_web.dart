/// Web implementation — calls window.print().
library;

import 'package:web/web.dart' as web;

void printPage() {
  web.window.print();
}
