import 'package:sqflite/sqflite.dart';
import 'package:qr_scanner/db/qr_db.dart';
import 'qr_item.dart';

class QrDao {
  static const table = 'qr_item';

  Future<int> insert(QrItem item) async {
    final db = await QrDb.instance.db;
    return db.insert(table, item.toMap());
  }

  Future<void> insertFromContent(String content, {String? label}) async {
    final db = await QrDb.instance.db;
    final item = QrItem.fromContent(content, label: label);
    await db.insert(table, item.toMap());
  }

  Future<bool> exists(String content) async {
    final db = await QrDb.instance.db;
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM $table WHERE content = ?',
      [content.trim()],
    );
    final n = Sqflite.firstIntValue(r) ?? 0;
    return n > 0;
  }

  Future<bool> insertIfNew(String content, {String? label}) async {
    if (await exists(content)) return false;
    await insertFromContent(content, label: label);
    return true;
  }

  Future<void> upsertLabel(String content, String? label) async {
    final db = await QrDb.instance.db;
    final c = content.trim();
    final rows = await db.query(
      table,
      where: 'content = ?',
      whereArgs: [c],
      limit: 1,
    );
    if (rows.isEmpty) {
      await insertFromContent(c, label: label);
      return;
    }
    await db.update(
      table,
      {'label': label},
      where: 'content = ?',
      whereArgs: [c],
    );
  }

  Future<List<QrItem>> all({int limit = 100, int offset = 0}) async {
    final db = await QrDb.instance.db;
    final rows = await db.query(
      table,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(QrItem.fromMap).toList();
  }

  Future<QrItem?> byId(int id) async {
    final db = await QrDb.instance.db;
    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return QrItem.fromMap(rows.first);
  }

  Future<int> delete(int id) async {
    final db = await QrDb.instance.db;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
