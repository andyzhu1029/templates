import 'package:flutter/foundation.dart';
import 'package:qr_scanner/models/qr_dao.dart';
import 'package:qr_scanner/models/qr_item.dart';

class QrHistoryProvider extends ChangeNotifier {
  final QrDao _dao = QrDao();
  final List<QrItem> _items = [];
  bool _loading = false;
  bool _end = false;
  int _offset = 0;
  final int pageSize = 30;

  List<QrItem> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get endReached => _end;

  Future<void> initLoad() async {
    _items.clear();
    _offset = 0;
    _end = false;
    await _loadNext();
  }

  Future<void> loadMore() => _loadNext();

  Future<void> refresh() async {
    await initLoad();
  }

  Future<void> deleteById(int id) async {
    await _dao.delete(id);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> _loadNext() async {
    if (_loading || _end) return;
    _loading = true;
    notifyListeners();
    final batch = await _dao.all(limit: pageSize, offset: _offset);
    if (batch.isEmpty || batch.length < pageSize) _end = true;
    _items.addAll(batch);
    _offset += batch.length;
    _loading = false;
    notifyListeners();
  }
}
