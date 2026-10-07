import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:winsguard/core/constants/local_database_keys.dart';


class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  /// Sets the theme to light mode.
  void setLight() => emit(ThemeMode.light);

  /// Sets the theme to dark mode.
  void setDark() => emit(ThemeMode.dark);

  /// Toggles the theme between light and dark mode.
  void changeTheme(){
    if(state == ThemeMode.dark){
      setLight();
    }else{
      setDark();
    }
    saveThemeMode();
  }

  /// Saves the theme mode to the local database.
  void saveThemeMode(){
    final box = Hive.box(LocalDatabaseKeys.database);
    box.put(LocalDatabaseKeys.themeMode, state.name);
  }

  /// Gets the theme mode from the local database.
  void getThemeMode(){
    final box = Hive.box(LocalDatabaseKeys.database);
    final themeMode = box.get(LocalDatabaseKeys.themeMode);
    if(themeMode != null) emit(ThemeMode.values.byName(themeMode));
  }

}
