import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:developer' as developer;

String formatDate(DateTime d) {
    return d.toString().substring(0, 19);
}

void main() {
    runApp(MyApp());
}


class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    late Stream<StepCount> _stepCountStream;
    late Stream<PedestrianStatus> _pedestrianStatusStream;
    String _status = '?', _steps = '?';



    @override
    void initState() {
        super.initState();
        initPlatformState();
    }

    void onStepCount(StepCount event) {
        developer.log("data : " + event.steps.toString());
        setState(() {
            _steps = event.steps.toString();
        });
    }

    void onPedestrianStatusChanged(PedestrianStatus event) {
        developer.log("data : " + event.status);
        setState(() {
            _status = event.status;
        });
    }

    void onPedestrianStatusError(error) {
        developer.log('onPedestrianStatusError: $error');
        setState(() {
            _status = 'Pedestrian Status not available';
        });
        developer.log(_status);
    }

    void onStepCountError(error) {
        developer.log('onStepCountError: $error');
        setState(() {
            _steps = 'Step Count not available';
        });
    }

    void initPlatformState() {
        _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
        _pedestrianStatusStream
            .listen(onPedestrianStatusChanged)
            .onError(onPedestrianStatusError);

        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(onStepCount).onError(onStepCountError);

        if (!mounted) return;
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('Pedometer example app'),
                ),
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Text(
                                'Steps taken:',
                                style: TextStyle(fontSize: 30),
                            ),
                            Text(
                                _steps,
                                style: TextStyle(fontSize: 60),
                            ),
                            Divider(
                                height: 100,
                                thickness: 0,
                                color: Colors.white,
                            ),
                            Text(
                                'Pedestrian status:',
                                style: TextStyle(fontSize: 30),
                            ),
                            Icon(
                                _status == 'walking'
                                    ? Icons.directions_walk
                                    : _status == 'stopped'
                                    ? Icons.accessibility_new
                                    : Icons.error,
                                size: 100,
                            ),
                            Center(
                                child: Text(
                                    _status,
                                    style: _status == 'walking' || _status == 'stopped'
                                        ? TextStyle(fontSize: 30)
                                        : TextStyle(fontSize: 20, color: Colors.red),
                                ),
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}