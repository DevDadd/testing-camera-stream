import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streampose/home_page.dart';
import 'package:streampose/pose_cubit.dart';

import 'linechart.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PoseCubit(),
      child: MaterialApp(home: LineChartDemo(),),
    );
  }
}
