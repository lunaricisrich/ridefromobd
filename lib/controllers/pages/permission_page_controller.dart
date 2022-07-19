import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:ridefromobd/dialogs/title_content_one_button_dialog.dart';
import 'package:ridefromobd/dialogs/title_content_two_button_dialog.dart';
import 'package:ridefromobd/models/obd/obd_speed_model.dart';
import 'package:ridefromobd/services/obd2_plugin.dart';
import 'package:ridefromobd/services/obd_connection.dart';
import 'package:ridefromobd/styles/ride_obd.dart';
import 'package:ridefromobd/styles/ride_string.dart';

class PermissionPageController extends GetxController {

  Obd2Plugin obd2 = Obd2Plugin();
  Timer obd2Timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {
    // 2022.06.07 Lunaric : when debugging, the following can be put here : print('waiting...');
  });

  click(BuildContext context) async {
    _connectToObd(1, context);
  }

  _connectToObd(int index, BuildContext context) async {
    var obdTool = ObdConnection();

    // 2022.07.15 Lunaric : exception handling - if bluetooth not enabled in user's phone, go enable it
    var result = await obdTool.isEnabled;
    if (!result) {
      result = await titleContentTwoButtonDialog(RideString.BLUETOOTH_ENABLE, RideString.BLUETOOTH_ENABLE_MESSAGE);
      if (!result) {
        return;
      }
      return obdTool.openSetting();
    }

    // 2022.07.15 Lunaric : exception handling - if ride app not granted permission or no OBD paired
    BluetoothDevice? obd2Device = await obdTool.getObd('66:1E:11:0E:1A:91');
    if (obd2Device == null) {
      // 2022.07.15 Lunaric : explanation about manually granting permission, android vs iOS different !
      bool isAndroid = true;
      return titleContentOneButtonDialog(RideString.BLUETOOTH_ENABLE, RideString.BLUETOOTH_PERMISSION_MESSAGE);
    }
    if (obd2Device.address == 'null') {
      return titleContentOneButtonDialog(RideString.BLUETOOTH_ENABLE, RideString.BLUETOOTH_PAIRED_OBD_NOT_FOUND_MESSAGE);
    }

    /* dynamic temp = await streamObd(obd2Device); */
    var results = await Future.wait([
      // Future.value(true),
      // titleContentNoButtonDialog(RideString.BLUETOOTH_ENABLE, RideString.BLUETOOTH_PAIRING, context, delayTimeInMilliSecond: 6000),
      // ObdConnection().connect(obd2Device, scheduleModelsToday[index].connectionSeq),
      streamObd(obd2Device)
    ]).catchError((err) {
      if (err == 'no obd') {
        return titleContentOneButtonDialog(RideString.BLUETOOTH_ENABLE, RideString.BLUETOOTH_OBD_NOT_FOUND_MESSAGE);
      }
      print(err);
      return _connectToObd(index, context);
    });

    print(results);

    if (results.isEmpty || results.length != 1 || results[0] == null || !results[0]!) {
      return;
    }

    getVelocity();
    // Obd2Plugin obd2 = Obd2Plugin();
    // var obd2Timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
    //   obd2.getParamsFromJSON(RideObd().speedParamToSendViaBle);
    // });
    print(result);
    // result = await Future.wait([
    //   postRequestV1RaceStart(index),
    // ]);
    // print(result);
  }

  void getVelocity() async {
    obd2Timer.cancel();
    obd2Timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      obd2.getParamsFromJSON(RideObd().speedParamToSendViaBle);
    });
  }

  Future streamObd(BluetoothDevice obd2Device) async {
    Obd2Plugin obd2 = Obd2Plugin();
    var obdTool = ObdConnection();
    await obd2.getConnection(obd2Device, (connection) async {
      print("connected to bluetooth device.");
    }, (message) {
      print("error in connecting: $message");
    });
    RxList<ObdSpeedModel> speedModels = <ObdSpeedModel>[].obs;
    List<int> rapidMovements = <int>[0, 0, 0, 0];
    var result = false;
    try{
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
      speedModels.assignAll(obdTool.speedsUpdated(speedModel, speedModels));

      // 2022.06.24 Lunaric : extract rapidmovement []
      //                 ||   deceleration  |  acceleration
      //    non-stop     ||   [1,0,0,0](0)  |  [0,0,1,0](2)
      //      stop       ||   [0,1,0,0](1)  |  [0,0,0,1](3)
      List<int> rapidMovementsToAdd = obdTool.makeRapidMoventsToAdd(speedModels);

      // 2022.07.15 Lunaric :
      if (rapidMovementsToAdd[0] == 0 || rapidMovementsToAdd[1] == 0 || rapidMovementsToAdd[2] == 0 || rapidMovementsToAdd[3] == 0) {
        return true;
      }
      // setState(() {
      // if (rapidMovementsToAdd[0] != 0 || rapidMovementsToAdd[1] != 0 || rapidMovementsToAdd[2] != 0 || rapidMovementsToAdd[3] != 0) {
      //   // print('그래 지금이야!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      //   List<int> rapidMovementsNew = [];
      //   for (int i = 0; i < 4; i++) {
      //     rapidMovementsNew.add(rapidMovements[i] + rapidMovementsToAdd[i]);
      //   }
      //   rapidMovements = rapidMovementsNew;
      // }
      // });
    });
    print('streamObd constructed. Now, need speed data incoming...');
  } catch (err) {
    print('streamObd has error' + err.toString());
  }
    return obd2.isListenToDataInitialed;
  }
}