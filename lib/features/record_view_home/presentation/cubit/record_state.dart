import 'package:equatable/equatable.dart';
import '../../domain/entities/food_record_entity.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class RecordSuccess extends RecordState {
  final String message;

  const RecordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RecordError extends RecordState {
  final String message;

  const RecordError(this.message);

  @override
  List<Object> get props => [message];
}

class RecordListLoaded extends RecordState {
  final List<FoodRecordEntity> records;
  final List<FoodRecordEntity> filteredRecords;

  const RecordListLoaded(this.records, {List<FoodRecordEntity>? filteredRecords})
      : filteredRecords = filteredRecords ?? records;

  @override
  List<Object> get props => [records, filteredRecords];
}
