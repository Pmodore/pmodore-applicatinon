import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodore/core/utils/database_helper.dart';
import 'package:pomodore/features/task_management/data/repositories/category_repository_impl.dart';
import 'package:pomodore/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:pomodore/features/task_management/domain/usecases/add_category_usecase.dart';
import 'package:pomodore/features/task_management/domain/usecases/add_task_usecase.dart';
import 'package:pomodore/features/task_management/presentation/blocs/tasks_bloc/tasks_bloc.dart';
import 'package:pomodore/features/task_management/presentation/blocs/timer_bloc/timer_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'core/utils/ticker.dart';
import 'features/task_management/data/data_sources/local_data_source.dart';

final getIt = GetIt.instance;

Future inject() async {
  await Hive.initFlutter();
  Box appBox = await Hive.openBox('app_box');

  getIt.registerLazySingleton<Box>(
    () => appBox,
    dispose: (param) => param.close(),
  );

  Database db = await DatabaseHelper.database;
  getIt.registerSingleton<Database>(db);
  print(await DatabaseHelper.showTaskTable());
  print(await DatabaseHelper.showCategoryTable());

  // inject blocs
  getIt.registerSingleton<TimerBloc>(TimerBloc(ticker: const Ticker()));
  // todo : check and fix dependencies
  getIt.registerSingleton<TasksBloc>(TasksBloc(
    addTaskUsecase: AddTaskUsecase(TaskRepositoryImpl(LocalDataSource(db))),
    addCategoryUsecase:
        AddCategoryUsecase(CategoryRepositoryImpl(LocalDataSource(db))),
  ));
}
