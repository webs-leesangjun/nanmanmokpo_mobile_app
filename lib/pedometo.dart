import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'dart:developer' as developer;

String formatDate(DateTime d) {
    return d.toString().substring(0, 19);
}

class PedometerWrapper {
    late Stream<StepCount> _stepCountStream;
    late Stream<PedestrianStatus> _pedestrianStatusStream;

    StreamSubscription<PedestrianStatus>? pedestrianStatusSubscription;
    StreamSubscription<StepCount>? stepCountStreamSubscription;

    String _status = '?', _steps = '?';

    void startListeningToPedestrianStatus() {
        pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
                (PedestrianStatus status) {
                // 보행자 상태 변화에 대한 처리
                print('보행자 상태: ${status.status}');
            },
        );
    }

    void stopListeningToPedestrianStatus() {
        pedestrianStatusSubscription?.cancel();
    }

    void startListeningToPedestrianStep() {

        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(onStepCount).onError(onStepCountError);

        stepCountStreamSubscription = Pedometer.stepCountStream.listen(
            (StepCount event) {
                // 보행자 상태 변화에 대한 처리
                print('보행자 상태: ${event.steps}');
            },
            onError: onStepCountError,
            onDone: onStepCountDone,
        );
    }

    void stopListeningToPedestrianStep() {
        stepCountStreamSubscription?.cancel();
    }



    void onStepCount(StepCount event) {
        developer.log("data : " + event.steps.toString());
        _steps = event.steps.toString();
    }

    void onPedestrianStatusChanged(PedestrianStatus event) {
        developer.log("data : " + event.status);
        _status = event.status;
    }

    void onPedestrianStatusError(error) {
        developer.log('onPedestrianStatusError: $error');
        _status = 'Pedestrian Status not available';
        developer.log(_status);
    }

    void onStepCountDone() {
        print("### onStepCountDone");
    }

    void onStepCountError(error) {
        developer.log('onStepCountError: $error');
        _steps = 'Step Count not available';
    }

    void initPlatformState() {
        _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
        _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(onStepCount).onError(onStepCountError);
    }
}