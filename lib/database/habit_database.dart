import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;

  /*
    SETUP
  */

  //  INITIALISE DATABSE
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await(Isar.open([HabitSchema,AppSettingsSchema], directory: dir.path));
  }

  // Save first date of app startup(for heatmap)
  Future<void> saveFirstLaunchDate() async{
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings == null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup(for heatmap)
  Future<DateTime?> getFirstLaunchDate() async{
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }


  /*
    CRUD OPERATIONS
  */

  // lIST OF HABITS

  // CREATE - a new habit

  // READ - read saved habits from database

  // UPDATE - check habit on or off

  // UPDATE - edit habit name

  // DELETE - delete habit

}