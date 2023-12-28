import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';
import 'package:logger/logger.dart';
import 'package:contacts_buddy/home_page.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // If _database is null, instantiate it
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'contacts_database.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE contacts('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'first_name TEXT, '
              'middle_name TEXT, '
              'last_name TEXT, '
              'country TEXT, '
              'age INTEGER, '
              'address TEXT, '
              'contact TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }

  Future<int> insertContact(Contact contact) async {
    Database db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<void> updateContact(Contact contact, int? id) async {
    Database db = await instance.database;
    try {
      await db.update(
        'contacts',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Log the SQL statement and error
      AppLogger.logError('Error updating contact: $e\nSQL: ${await db.query('contacts')}');
      rethrow;
    }
  }





  Future<List<Contact>> searchContacts(String contactName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM contacts WHERE first_name LIKE ?",
      ['%$contactName%'],
    );

    return List.generate(maps.length, (i) {
      return Contact(
        id: maps[i]['id'],
        firstName: maps[i]['first_name'],
        middleName: maps[i]['middle_name'],
        lastName: maps[i]['last_name'],
        country: maps[i]['country'],
        age: maps[i]['age'],
        address: maps[i]['address'],
        contact: maps[i]['contact'],
      );
    });
  }

  Future<List<Contact>> getContacts() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<void> deleteContact(int id) async {
    Database db = await instance.database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateContactPartial(Contact updatedContact, int? id) async {
    Database db = await instance.database;
    try {
      Map<String, dynamic> contactMap = updatedContact.toMap();
      contactMap.removeWhere((key, value) => value == null); // Remove null values

      await db.update(
        'contacts',
        contactMap,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Log the SQL statement and error
      AppLogger.logError('Error updating contact: $e\nSQL: ${await db.query('contacts')}');
      rethrow;
    }
  }
// Add other CRUD operations here
}
