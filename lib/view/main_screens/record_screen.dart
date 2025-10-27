import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/record_view_home/di/record_di.dart';
import '../../features/record_view_home/presentation/cubit/record_cubit.dart';
import '../../features/record_view_home/presentation/pages/record_page.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecordCubit>(
      create: (context) => RecordDI.getRecordCubit()..loadFoodRecords(),
      child: const RecordPage(),
    );
  }
}
