import 'dart:async';
import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
// import 'package:ride/controllers/globals/storage_controller.dart';
// import 'package:ride/models/obd/obd_speed_model.dart';
// import 'package:ride/services/api_request.dart';
// import 'package:ride/services/api_url.dart';
// import 'package:ride/services/obd2_plugin.dart';
// import 'package:ride/styles/ride_obd.dart';
// import 'package:ride/utils/get_location.dart';
import 'package:ridefromobd/models/obd/obd_speed_model.dart';
import 'package:ridefromobd/services/obd2_plugin.dart';
import 'package:ridefromobd/styles/ride_obd.dart';

class ObdConnection {
  // 2022.06.17 Lunaric : using Begaz's solution, Obd2Plugin Model creation
  Obd2Plugin obd2 = Obd2Plugin();
  final flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  late Function(BluetoothConnection connection) onConnected;

  bool isListeningToOBDII = false;
  double speed = 0.0;
  Timer obd2Timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {
    // 2022.06.07 Lunaric : when debugging, the following can be put here : print('waiting...');
  });
  RxList<ObdSpeedModel> speedModels = <ObdSpeedModel>[].obs;
  List<int> rapidMovements = <int>[0, 0, 0, 0];
  // int _countInterval = 0;
  // String allocatedObd2AddressForCar = '66:1E:11:0E:1A:91';
  // EasyLoading _loading = EasyLoading.instance
  //   ..indicatorType = EasyLoadingIndicatorType.chasingDots
  //   ..loadingStyle = EasyLoadingStyle.custom
  //   ..indicatorSize = 45.0
  //   ..radius = 10.0
  //   ..progressColor = Colors.yellow[900]
  //   ..backgroundColor = Colors.white
  //   ..indicatorColor = Colors.yellow
  //   ..textColor = Colors.black
  //   ..maskColor = Colors.blue.withOpacity(0.5)
  //   ..userInteractions = true
  //   ..dismissOnTap = false;

  Future<bool> get isEnabled async {
    return flutterBluetoothSerial.isEnabled.then((e) {
      if (e == null) {
        return false;
      }
      return e;
    });
  }

  Future<void> openSetting() async {
    return flutterBluetoothSerial.openSettings();
  }

  Future<bool> get isDiscovering async {
    return flutterBluetoothSerial.isDiscovering.then((e) {
      if (e == null) {
        return false;
      }
      return e;
    }).catchError((err) {
      return false;
    });
  }

  Future<String> get address async {
    return flutterBluetoothSerial.address.then((e) {
      if (e == null) {
        return 'null';
      }
      return e;
    }).catchError((err) {
      return err;
    });
  }

  Future<String> get name async {
    return flutterBluetoothSerial.name.then((e) {
      if (e == null) {
        return 'null';
      }
      return e;
    }).catchError((err) {
      return err;
    });
  }

  Future<bool> get isDiscoverable async {
    return flutterBluetoothSerial.isDiscoverable.then((e) {
      if (e == null) {
        return false;
      }
      return e;
    }).catchError((err) {
      return false;
    });
  }

  Future<BluetoothDevice?> getObd(String carObd) async {
    try {
      List<BluetoothDevice> pairedDevices = await flutterBluetoothSerial.getBondedDevices();
      return pairedDevices.firstWhere((el) {
        return el.address == carObd;
      }, orElse: () => BluetoothDevice(address: 'null'));
    } catch (err) {
      return null;
    }
  }

  // void dispose() {
  //   obd2.disconnect();
  //   obd2Timer.cancel();
  // }

  void getVelocity() async {
    obd2Timer.cancel();
    obd2Timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      obd2.getParamsFromJSON(RideObd().speedParamToSendViaBle);
    });
  }

  // void getVelocity() async {
  //   obd2Timer.cancel();
  //   obd2Timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
  //     obd2.getDTCFromJSON(RideObd().speedParamToSendViaBle);
  //   });
  // }

  Future<bool?> connect(BluetoothDevice obd2Device, int connectionSeq) async {
    // 2022.07.15 Lunaric : connection activate
    // print("connect --> ");

    await obd2.getConnection(obd2Device, (connection) async {
      print("connected to bluetooth device.");
    }, (message) {
      print("error in connecting: $message");
    });

    // try {
    // 2022.06.24 Lunaric : subscribe obd
    await obd2.setOnDataReceived((command, response, requestCode) {
      // print("$command => $response");

      // 2022.06.24 Lunaric : exception handling with dataChunk received from obd
      dynamic dataChunk = jsonDecode(response);
      if (dataChunk.length > 1) {
        return true;
      }

      if (dataChunk[0]['response'].length < 1) {
        return true;
      }
      // print(temp[0]['response']);

      // 2022.06.17 Lunaric : construct speedModel from speedVal [km/h]
      double speedVal = double.parse(dataChunk[0]['response']);
      if (speedVal == 255) {
        // print('speed : 255, so skip it');
        return true;
      }
      ObdSpeedModel speedModel = ObdSpeedModel(speed: speedVal, time: DateTime.now());
      // print("speed : ${speedModel.speed.toString()} , time : ${speedModel.time.toString()}");

      // 2022.07.15 Lunaric : construct speedModels ==> List<ObdSpeedModel>
      speedModels.assignAll(speedsUpdated(speedModel, speedModels));

      // 2022.06.24 Lunaric : extract rapidmovement []
      //                 ||   deceleration  |  acceleration
      //    non-stop     ||   [1,0,0,0](0)  |  [0,0,1,0](2)
      //      stop       ||   [0,1,0,0](1)  |  [0,0,0,1](3)
      List<int> rapidMovementsToAdd = makeRapidMoventsToAdd(speedModels);

      // 2022.07.15 Lunaric : exception handling - return if no rapid movements detected
      if (rapidMovementsToAdd[0] == 0 || rapidMovementsToAdd[1] == 0 || rapidMovementsToAdd[2] == 0 || rapidMovementsToAdd[3] == 0) {
        return true;
      }

      postV1SafeRaceScore(rapidMovementsToAdd[3], rapidMovementsToAdd[1], rapidMovementsToAdd[2], rapidMovementsToAdd[0], connectionSeq);
      // setState(() {
      if (rapidMovementsToAdd[0] != 0 || rapidMovementsToAdd[1] != 0 || rapidMovementsToAdd[2] != 0 || rapidMovementsToAdd[3] != 0) {
        // print('그래 지금이야!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        List<int> rapidMovementsNew = [];
        for (int i = 0; i < 4; i++) {
          rapidMovementsNew.add(rapidMovements[i] + rapidMovementsToAdd[i]);
        }
        rapidMovements = rapidMovementsNew;
      }
      // });
    }).catchError((err) {
      print(err);
    });

    return obd2.isListenToDataInitialed;
    // setState(() {
    // isListeningToOBDII = isListeningToOBDIITemp;
    // });
    // } catch (err) {
    //   return null;
    // }
    //*/
  }

  postV1SafeRaceScore(int rapidStart, int rapidStop, int rapidAcceleration, int rapidDeceleration, int connectionSeq) async {
    print('postV1SafeRaceScore --> ');
    // 2022.07.15 Lunaric : need lat, lng as parameters
    // var location = await GetLocation.getLocation();

    // // 2022.07.15 Lunaric :
    // var queryParameters = {
    //   "memberSeq": StorageController.to.storageReadMemberSeq(),
    //   // "safeRaceScoreSeq": 1,
    //   "connectionSeq": connectionSeq,
    //   "rapidStart": rapidStart,
    //   "rapidStop": rapidStop,
    //   "rapidAcceleration": rapidAcceleration,
    //   "rapidDeceleration": rapidDeceleration,
    //   "rapidLat": location['latitude'],
    //   "rapidLng": location['longitude']
    // };

    // var value = await ApiRequest.httpPostRequest(ApiUrl.V1_SAFE_RACE_RECORD, queryParameters);
    // if ((value is bool) && value) {
    //   return postV1SafeRaceScore(rapidStart, rapidStop, rapidAcceleration, rapidDeceleration, connectionSeq);
    // }

    // final v1ResultSeqModel = V1ResultSeqModel.fromJson(json.decode(value));

    // if (v1ResultSeqModel.data.isNotEmpty) {
    //   if (v1ResultSeqModel.data[0].resultSeq > 0) {
    //     raceStart();
    //   }
    // }
  }

  List<ObdSpeedModel> speedsUpdated(ObdSpeedModel _speedModel, RxList<ObdSpeedModel> _speedModels) {
    // print('_speedsUpdated executed, _speedModels.length : ${_speedModels.length}');

    // 2022.06.24 Lunaric : exception handling : keep 3 seconds
    if (_speedModels.isEmpty) {
      // print('얘 완전 비었어');
      return [_speedModel];
    }

    // 2022.06.24 Lunaric : increase length of speedModels
    // print('speeds.length : ${_speedModels.length}');
    if (_speedModel.time.difference(_speedModels.last.time).inMilliseconds < 3000) {
      // print('길이 늘어나랏 ! ㅋㅋㅋ');
      return [_speedModel, ..._speedModels];
    }

    // 2022.06.24 Lunaric : get proper length to cut speedModels
    int length = _getLengthToCutSpeedModels(_speedModel, _speedModels);
    // print('길이 $length로 짤라랏 ! ㅋㅋㅋ');

    // 2022.06.24 Lunaric : if length of speedModels does not exceeds what's needed, add new value (_speedModel) to the list
    if (length == -1) {
      // print('길이 늘어나랏 ! ㅋㅋㅋ');
      return [_speedModel, ..._speedModels];
    }

    // 2022.06.24 Lunaric : if length of speedModels exceeds what's needed, throw whatever's needed
    List<ObdSpeedModel> speedsRefined = [];
    for (int i = 0; i < length; i++) {
      speedsRefined.add(_speedModels[i]);
    }
    return [_speedModel, ...speedsRefined];
  }

  int _getLengthToCutSpeedModels(ObdSpeedModel _speedModel, RxList<ObdSpeedModel> _speedModels) {
    int i = 0;
    return _speedModels.indexWhere((el) {
      // print('i : $i , difference : ${speed.time.difference(el.time).inMilliseconds} , el.time : ${el.time}');
      i = i + 1;
      return _speedModel.time.difference(el.time).inMilliseconds >= 4000;
    });
  }

  List<int> makeRapidMoventsToAdd(List<ObdSpeedModel> speedObjs) {
    // 2022.06.23 Lunaric : zero when not collected 3 seconds of speed
    if (speedObjs.first.time.difference(speedObjs.last.time).inMilliseconds < 3000) {
      return [0, 0, 0, 0];
    }

    // 2022.06.23 Lunaric : if size exceeds what's needed, throw whatever's needed

    final ObdSpeedModel _prevSpeedObj = speedObjs[1];

    final double acceleration = _accelerationUsingTwoSpeedModels(speedObjs.first, _prevSpeedObj);

    const double thresholdSpeedToBeRapidMovement = 15.0; // km/h // 5 for debugging, 15 for real
    const double thresholdSpeedToBeRapidStop = 0.0;
    const double thresholdSpeedToBeRapidStart = 5.0; // 3 for debugging, 5 for real

    if (acceleration.abs() < thresholdSpeedToBeRapidMovement) {
      // print('완행중...');
      return [0, 0, 0, 0];
    }

    // 2022.06.24 Lunaric
    //                 ||   deceleration  |  acceleration
    //    non-stop     ||   [1,0,0,0](0)  |  [0,0,1,0](2)
    //      stop       ||   [0,1,0,0](1)  |  [0,0,0,1](3)
    //
    // (0) 급감속 (1) 급제동 (2) 급가속 (3) 급출발

    // 2022.06.28 Lunaric
    // when accelerating...
    //     _hasAcc | v_{i-1} <= threshold | cont. || rapidStart | non-stop | count X
    //        T    |         N/A          |  N/A  ||            |          |   T
    //        F    |          T           |   T   ||     +1     |          |
    //        F    |          T           |   F   ||     +1     |          |
    //        F    |          F           |   T   ||     +1     |          |
    //        F    |          F           |   F   ||            |     +1   |

    List<ObdSpeedModel> _prevSpeedObjs = [...speedObjs];
    _prevSpeedObjs.removeAt(0);

    if (acceleration > thresholdSpeedToBeRapidMovement) {
      if (_hasAcceleratedWithin3Seconds(_prevSpeedObjs, true, thresholdSpeedToBeRapidMovement)) {
        return [0, 0, 0, 0];
      }
      if (_prevSpeedObj.speed <= thresholdSpeedToBeRapidStart || _hasContinuousIncreaseInAccelerationFromStopped([...speedObjs])) {
        return [0, 0, 0, 1];
      }
      return [0, 0, 1, 0];
    }

    // 2022.06.28 Lunaric
    // when deccelerating...
    //     _hasDec | v_i <= threshold | cont. || rapidSttop | non-stop | count X
    //        T    |         T        |   T   ||     +1     |    -1    |
    //        T    |         T        |   F   ||     +1     |          |
    //        T    |         F        |   T   ||            |          |    T
    //        T    |         F        |   F   ||            |          |    T
    //        F    |         T        |  N/A  ||     +1     |          |
    //        F    |         F        |  N/A  ||            |     +1   |

    bool _hasRapidDeceleration = _hasAcceleratedWithin3Seconds(_prevSpeedObjs, false, thresholdSpeedToBeRapidMovement);
    bool _consideredStopped = speedObjs.first.speed <= thresholdSpeedToBeRapidStop;
    // print('_hasRapidDeceleration : $_hasRapidDeceleration , _consideredStopped : $_consideredStopped');
    if (_hasRapidDeceleration && !_consideredStopped) {
      return [0, 0, 0, 0];
    }

    if (!_hasRapidDeceleration && !_consideredStopped) {
      speedObjs.first.decelerationTime = speedObjs.first.time;
      return [1, 0, 0, 0];
    }

    if (!_hasRapidDeceleration && _consideredStopped) {
      return [0, 1, 0, 0];
    }

    if (_hasContinuousDeceleration([...speedObjs])) {
      // print('그래 급감속 빼고 급정지 해야지');
      return [-1, 1, 0, 0];
    }
    // print('급제동 하나 추가요 ~');
    return [0, 1, 0, 0];
  }

  double _accelerationUsingTwoSpeedModels(ObdSpeedModel _currSpeedModel, ObdSpeedModel _prevSpeedModel) {
    // 2022.06.23 Lunaric : a = (v_f - v_i) / Δt, assuming direction change never happens or never matters
    return (_currSpeedModel.speed - _prevSpeedModel.speed) / (_currSpeedModel.time.difference(_prevSpeedModel.time).inMilliseconds) * 1000;
  }

  bool _hasAcceleratedWithin3Seconds(List<ObdSpeedModel> _speeds, bool _isAcceleration, double thresholdSpeedToBeRapidMovement) {
    for (int i = 1; i < _speeds.length; i++) {
      double acceleration = _accelerationUsingTwoSpeedModels(_speeds[i - 1], _speeds[i]);
      bool _tellsAcceleration = _isAcceleration ? acceleration > thresholdSpeedToBeRapidMovement : acceleration < -thresholdSpeedToBeRapidMovement;
      if (_tellsAcceleration) {
        return true;
      }
    }
    return false;
  }

  bool _hasContinuousDeceleration(
    List<ObdSpeedModel> _speedObjs,
  ) {
    if (_speedObjs.isEmpty || _speedObjs.length < 2) {
      return false;
    }
    int length = _speedObjs.indexWhere((el) => el.decelerationTime != null);
    // print('length : $length');
    double acceleration = 0.0;

    for (int i = 1; i < length; i++) {
      acceleration = (_speedObjs[i - 1].speed - _speedObjs[i].speed) / (_speedObjs[i - 1].time.difference(_speedObjs[i].time).inMilliseconds) * 1000;
      // print('i = $i , acceleration : $acceleration');
      if (acceleration > 0) {
        // print('가속도가 [$length] 전까지, 0보다 큰 적이 있으니까 넌 급감속도 한거고, 급제동도 한거야!!!!!!!!!');
        return false;
      }
    }
    // print('쭉 감속하다가 정지했으니, 너는 기존의 급감속 하나 줄이고 급제동으로 줄거야 ㅋㅋㅋ');
    return true;
  }

  bool _hasContinuousIncreaseInAccelerationFromStopped(List<ObdSpeedModel> _speedObjs) {
    if (_speedObjs.isEmpty || _speedObjs.length < 3) {
      return false;
    }

    double currAcceleration = 0.0;
    double prevAcceleration = 0.0;

    for (int i = 2; i < _speedObjs.length; i++) {
      currAcceleration =
          (_speedObjs[i - 2].speed - _speedObjs[i - 1].speed) / (_speedObjs[i - 2].time.difference(_speedObjs[i - 1].time).inMilliseconds) * 1000;
      prevAcceleration = (_speedObjs[i - 1].speed - _speedObjs[i].speed) / (_speedObjs[i - 1].time.difference(_speedObjs[i].time).inMilliseconds) * 1000;
      if (currAcceleration < prevAcceleration) {
        return false;
      }
    }
    return true;
  }
}
