import 'dart:convert';

class RideObd {
  static const _speedParamToSendViaBle = [
    {
      "PID": "01 0D",
      "length": 1,
      "title": "سرعت خودرو",
      "unit": "Kh",
      "description": "<int>, [0]",
      "status": true,
      "command": "01 0D",
    }
  ];

  get speedParamToSendViaBle {
    return jsonEncode(_speedParamToSendViaBle);
  }
}
