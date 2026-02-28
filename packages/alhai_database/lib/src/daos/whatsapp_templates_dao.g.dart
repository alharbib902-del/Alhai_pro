// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_templates_dao.dart';

// ignore_for_file: type=lint
mixin _$WhatsAppTemplatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $WhatsAppTemplatesTableTable get whatsAppTemplatesTable =>
      attachedDatabase.whatsAppTemplatesTable;
  WhatsAppTemplatesDaoManager get managers => WhatsAppTemplatesDaoManager(this);
}

class WhatsAppTemplatesDaoManager {
  final _$WhatsAppTemplatesDaoMixin _db;
  WhatsAppTemplatesDaoManager(this._db);
  $$WhatsAppTemplatesTableTableTableManager get whatsAppTemplatesTable =>
      $$WhatsAppTemplatesTableTableTableManager(
          _db.attachedDatabase, _db.whatsAppTemplatesTable);
}
