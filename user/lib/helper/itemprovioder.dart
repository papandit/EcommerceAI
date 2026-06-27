import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<dynamic> _items = [];

  List<dynamic> get items => List.unmodifiable(_items);

  void addItem(dynamic item) {
    _items.add(item);
    notifyListeners(); // Notify listeners of change
  }

  void removeItem(dynamic item) {
    _items.remove(item);
    notifyListeners(); // Notify listeners of change
  }

  void addallItem(dynamic item) {
    _items.addAll(item);
    notifyListeners(); // Notify listeners of change
  }

  void clearallItem() {
    _items.clear();
    notifyListeners(); // Notify listeners of change
  }

  int get itemCount => _items.length;
}
