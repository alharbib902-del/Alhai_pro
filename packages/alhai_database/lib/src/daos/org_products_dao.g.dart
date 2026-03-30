// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_products_dao.dart';

// ignore_for_file: type=lint
mixin _$OrgProductsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrganizationsTableTable get organizationsTable =>
      attachedDatabase.organizationsTable;
  $StoresTableTable get storesTable => attachedDatabase.storesTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $OrgProductsTableTable get orgProductsTable =>
      attachedDatabase.orgProductsTable;
  OrgProductsDaoManager get managers => OrgProductsDaoManager(this);
}

class OrgProductsDaoManager {
  final _$OrgProductsDaoMixin _db;
  OrgProductsDaoManager(this._db);
  $$OrganizationsTableTableTableManager get organizationsTable =>
      $$OrganizationsTableTableTableManager(
          _db.attachedDatabase, _db.organizationsTable);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db.attachedDatabase, _db.storesTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
          _db.attachedDatabase, _db.categoriesTable);
  $$OrgProductsTableTableTableManager get orgProductsTable =>
      $$OrgProductsTableTableTableManager(
          _db.attachedDatabase, _db.orgProductsTable);
}
