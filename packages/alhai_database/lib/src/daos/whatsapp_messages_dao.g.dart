// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_messages_dao.dart';

// ignore_for_file: type=lint
mixin _$WhatsAppMessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $WhatsAppMessagesTableTable get whatsAppMessagesTable =>
      attachedDatabase.whatsAppMessagesTable;
  WhatsAppMessagesDaoManager get managers => WhatsAppMessagesDaoManager(this);
}

class WhatsAppMessagesDaoManager {
  final _$WhatsAppMessagesDaoMixin _db;
  WhatsAppMessagesDaoManager(this._db);
  $$WhatsAppMessagesTableTableTableManager get whatsAppMessagesTable =>
      $$WhatsAppMessagesTableTableTableManager(
        _db.attachedDatabase,
        _db.whatsAppMessagesTable,
      );
}
