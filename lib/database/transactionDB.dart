import 'dart:io';
import 'package:account/model/transactionItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TransactionDB {
  String dbName;

  TransactionDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  // ฟังก์ชันสำหรับล้างข้อมูลทั้งหมดในฐานข้อมูล
  Future<void> clearDatabase() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    await store.drop(db); // ลบข้อมูลทั้งหมดใน store
    await db.close();
  }

  // ฟังก์ชันสำหรับเพิ่มข้อมูลลงฐานข้อมูล
  Future<int> insertDatabase(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    Future<int> keyID = store.add(db, {
      'title': item.title,
      'amount': item.amount,
      'date': item.date?.toIso8601String(),
      'points': item.points, // ใช้ points เดิม
      'imagePath': item.imagePath,
    });
    db.close();
    return keyID;
  }

  // ฟังก์ชันสำหรับโหลดข้อมูลทั้งหมดจากฐานข้อมูล
  Future<List<TransactionItem>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('date', false)]),
    );

    List<TransactionItem> transactions = [];

    for (var record in snapshot) {
      TransactionItem item = TransactionItem(
        keyID: record.key,
        title: record['title'].toString(),
        amount: double.parse(record['amount'].toString()),
        date: DateTime.parse(record['date'].toString()),
        points: record['points'] != null
            ? double.parse(record['points'].toString())
            : null, // รักษาค่า points เป็น nullable
        imagePath: record['imagePath']?.toString(),
      );
      transactions.add(item);
    }
    db.close();
    return transactions;
  }

  // ฟังก์ชันสำหรับลบข้อมูลจากฐานข้อมูล
  Future<void> deleteData(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');
    await store.delete(
      db,
      finder: Finder(filter: Filter.equals(Field.key, item.keyID)),
    );
    db.close();
  }

  // ฟังก์ชันสำหรับอัปเดตข้อมูลในฐานข้อมูล
  Future<void> updateData(TransactionItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('expense');

    await store.update(
      db,
      {
        'title': item.title,
        'amount': item.amount,
        'date': item.date?.toIso8601String(),
        'points': item.points, // ใช้ points เดิม
        'imagePath': item.imagePath,
      },
      finder: Finder(filter: Filter.equals(Field.key, item.keyID)),
    );

    db.close();
  }
}
