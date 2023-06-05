import "package:bloc/bloc.dart";
import "package:dartz/dartz.dart";
import "package:equatable/equatable.dart";
import "package:pomodore/core/utils/debug_print.dart";
import "package:pomodore/features/habit_tracking/domain/entities/habit_entity.dart";
import "package:pomodore/features/habit_tracking/domain/usecases/add_new_habit_usecase.dart";
import "package:pomodore/features/habit_tracking/domain/usecases/delete_habit_usecase.dart";
import "package:pomodore/features/habit_tracking/domain/usecases/done_today_habit_usecase.dart";
import "package:pomodore/features/habit_tracking/domain/usecases/edit_habit_usecase.dart";
import "package:pomodore/features/habit_tracking/domain/usecases/get_all_habits_usecase.dart";
import "package:pomodore/features/task_management/domain/usecases/get_all_categories_usecase.dart";

import "../../../../../core/resources/params/habit_params.dart";
import "../../../../../core/utils/utils.dart";

part "habit_tracker_event.dart";
part "habit_tracker_state.dart";

class HabitTrackerBloc extends Bloc<HabitTrackerEvent, HabitTrackerState> {
  final AddNewHabitUseCase addNewHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final DoneTodayHabitUseCase doneTodayHabitUseCase;
  final EditHabitUseCase editHabitUseCase;
  final GetAllHabitUseCase getAllHabitUseCase;

  HabitTrackerBloc({
    required this.addNewHabitUseCase,
    required this.deleteHabitUseCase,
    required this.doneTodayHabitUseCase,
    required this.editHabitUseCase,
    required this.getAllHabitUseCase,
  }) : super(HabitTrackerInitial()) {
    on<HabitTrackerEvent>((event, emit) {});
    on<AllHabitsFetched>(_allHabitFetched);
    on<HabitAdded>(_habitAdded);
    on<HabitDeleted>(_habitDeleted);
    on<HabitUpdated>((event, emit) {});
    on<HabitDone>(_habitDone);
  }

  _habitDone(HabitDone event, emit) async {
    emit(const DoneHabit(true, false, []));

    Either<String, HabitEntity> result =
        await doneTodayHabitUseCase.call(params: event.params);

    result.fold(
      (l) => emit(const DoneHabit(false, true, [])),
      (r) {
        List<HabitEntity> newList = [];
        newList = event.habits;
        int index =
            newList.indexWhere((element) => element.id == event.params.id);
        newList.removeAt(index);
        newList.insert(index, r);
        return emit(DoneHabit(false, false, newList));
      },
    );
  }

  _allHabitFetched(event, emit) async {
    emit(const FetchHabits(habits: [], loading: true, error: false));

    Either result = await getAllHabitUseCase.call();

    result.fold(
      (l) => emit(
        const FetchHabits(
          habits: [],
          loading: false,
          error: true,
        ),
      ),
      (r) => emit(
        FetchHabits(
          habits: r,
          loading: false,
          error: false,
        ),
      ),
    );
  }

  _habitAdded(event, emit) async {
    emit(const AddHabit(loading: true, error: false));

    Either result = await addNewHabitUseCase.call(params: event.params);

    result.fold(
        (l) => emit(
              const AddHabit(
                loading: false,
                error: true,
              ),
            ),
        (r) => emit(
              const AddHabit(
                loading: false,
                error: false,
              ),
            ));
  }

  _habitDeleted(event, emit) async {
    emit(const DeleteHabit(habits: [], loading: true, error: false));

    Either<String, int> result =
        await deleteHabitUseCase.call(params: event.id);

    result.fold(
        (l) => emit(const DeleteHabit(habits: [], loading: false, error: true)),
        (r) {
      List<HabitEntity> newList = event.habits;
      newList.removeWhere((element) => element.id == r);
      emit(
        DeleteHabit(
          habits: newList,
          loading: false,
          error: false,
        ),
      );
    });
  }
}
