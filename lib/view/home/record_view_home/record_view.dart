import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/record_di.dart';

import 'presentation/pages/record_page.dart';

class RecordView extends StatelessWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordDI.getRecordCubit(),
      child: const RecordPage(),
    );
  }
}
