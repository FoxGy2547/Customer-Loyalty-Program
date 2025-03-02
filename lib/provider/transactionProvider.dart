import 'package:flutter/material.dart';
import 'package:account/model/transactionItem.dart';
import 'package:account/database/transactionDB.dart'; // ใช้พาธที่ถูกต้อง

class TransactionProvider with ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<TransactionItem> _productItems = [
    TransactionItem(
      keyID: 1,
      title: 'กาแฟเย็น',
      amount: 50,
      date: DateTime.now(),
      points: 50, // คะแนนเท่ากับราคา (บวกสำหรับซื้อ)
      imagePath: 'assets/images/coffee.jpg',
    ),
    TransactionItem(
      keyID: 2,
      title: 'ชาเขียว',
      amount: 45,
      date: DateTime.now(),
      points: 45, // คะแนนเท่ากับราคา (บวกสำหรับซื้อ)
      imagePath: 'assets/images/green_tea.jpg',
    ),
    TransactionItem(
      keyID: 3,
      title: 'เค้กช็อกโกแลต',
      amount: 80,
      date: DateTime.now(),
      points: 80, // คะแนนเท่ากับราคา (บวกสำหรับซื้อ)
      imagePath: 'assets/images/chocolate_cake.jpg',
    ),
  ];
  List<TransactionItem> _redeemItems = [
    TransactionItem(
      keyID: 1,
      title: 'กาแฟเย็น',
      amount: 50,
      date: DateTime.now(),
      points: -50, // คะแนนเท่ากับราคา (ลบสำหรับการแลก)
      imagePath: 'assets/images/coffee.jpg',
    ),
    TransactionItem(
      keyID: 2,
      title: 'ชาเขียว',
      amount: 45,
      date: DateTime.now(),
      points: -45, // คะแนนเท่ากับราคา (ลบสำหรับการแลก)
      imagePath: 'assets/images/green_tea.jpg',
    ),
    TransactionItem(
      keyID: 3,
      title: 'เค้กช็อกโกแลต',
      amount: 80,
      date: DateTime.now(),
      points: -80, // คะแนนเท่ากับราคา (ลบสำหรับการแลก)
      imagePath: 'assets/images/chocolate_cake.jpg',
    ),
  ];
  final TransactionDB _db = TransactionDB(dbName: 'transactions.db');

  List<TransactionItem> get transactions => _transactions;
  List<TransactionItem> get productItems => _productItems;
  List<TransactionItem> get redeemItems => _redeemItems;

  double get totalPoints => _transactions.fold(0, (sum, item) => sum + (item.points ?? 0));

  void addTransaction(TransactionItem item) {
    _transactions.add(item);
    _syncWithDatabase(item);
    notifyListeners();
  }

  void redeemTransaction(TransactionItem item) {
    _transactions.add(item);
    _syncWithDatabase(item);
    notifyListeners();
  }

  void deleteTransaction(TransactionItem item) {
    _transactions.remove(item);
    _syncWithDatabase(); // อัปเดตฐานข้อมูล
    notifyListeners();
  }

  void addProductItem(TransactionItem item) {
    _productItems.add(item);
    _syncWithDatabase(item);
    notifyListeners();
  }

  void addRedeemItem(TransactionItem item) {
    _redeemItems.add(item);
    _syncWithDatabase(item);
    notifyListeners();
  }

  void deleteRedeemItem(TransactionItem item) {
    _redeemItems.removeWhere((element) => element.keyID == item.keyID);
    _syncWithDatabase(); // อัปเดตฐานข้อมูล
    notifyListeners();
  }

  void deleteProductItem(TransactionItem item) {
    _productItems.removeWhere((element) => element.keyID == item.keyID);
    _syncWithDatabase(); // อัปเดตฐานข้อมูล
    notifyListeners();
  }

  Future<void> _syncWithDatabase([TransactionItem? item]) async {
    try {
      if (item != null) {
        await _db.insertDatabase(item);
      } else {
        await _db.clearDatabase(); // ลบข้อมูลเก่าทั้งหมด
        for (var transaction in _transactions) {
          await _db.insertDatabase(transaction);
        }
        for (var product in _productItems) {
          await _db.insertDatabase(product);
        }
        for (var redeem in _redeemItems) {
          await _db.insertDatabase(redeem);
        }
      }
    } catch (e) {
      print('Error syncing with database: $e');
    }
  }

  void syncWithDatabase() {
    _syncWithDatabase();
  }
}