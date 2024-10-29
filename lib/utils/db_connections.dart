import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DbConnections {
  static late Db db;
  static late DbCollection usersCollection;

  static Future<void> connect() async {
    db = await Db.create("mongodb+srv://fino:fino@cluster0.ko0stef.mongodb.net/pwrcs?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    usersCollection = db.collection('users');
  }

  static String hashPassword(String password){
    var byte = utf8.encode(password);
    var digest = sha256.convert(byte);
    return digest.toString();
  }

  static Future<bool> login(String email,String password) async {
    String hashedpassword = hashPassword(password);
    var user = await usersCollection.findOne({
      'email': email,
      'password':hashedpassword,
    });
    return user != null;
  }

  static Future<bool> sigin(String fullname, String email, String password) async {
    String hashedPassword = hashPassword(password);
    try {
      await usersCollection.insert({
        'fullname': fullname,
        'email': email,
        'password': hashedPassword,
        'credits': '0',
        'history': '[]',
      });
      return true; // Sign-in successful
    } catch (e) {
      return false; // Sign-in failed due to some error
    }
  }
}