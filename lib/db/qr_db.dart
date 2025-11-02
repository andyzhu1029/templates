import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QrDb {
  QrDb._();
  static final QrDb instance = QrDb._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    final path = join(base, 'qr.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE qr_item(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            is_url INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            label TEXT
          )
        ''');
      },
      onUpgrade: (d, oldV, newV) async {
        if (oldV < 2) {
          await d.execute('ALTER TABLE qr_item ADD COLUMN label TEXT');
        }
      },
    );
    return _db!;
  }
}
