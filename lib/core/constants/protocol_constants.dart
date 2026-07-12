class ProtocolConstants {
  static const String modbusTcp = 'MODBUS_TCP';
  static const String modbusRtu = 'MODBUS_RTU';
  static const String bacnet = 'BACNET';
  static const String dnp3 = 'DNP3';
  static const String iec101 = 'IEC_101';
  static const String iec104 = 'IEC_104';
  static const String iec61850 = 'IEC_61850';
  static const String mqtt = 'MQTT';
  static const String opcUa = 'OPC_UA';
  static const String mBus = 'MBUS';
  static const String tcp = 'TCP';
  static const String udp = 'UDP';
  static const String serial = 'SERIAL';
  static const String ble = 'BLE';
  static const String wifi = 'WIFI';
  static const String cellular = 'CELLULAR';
}

class ControllerModels {
  static const String acc2 = 'ACC2';
  static const String icc2 = 'ICC2';
}

class ValveConnectionTypes {
  static const String conventional = 'CONVENTIONAL';
  static const String twoWire = 'TWO_WIRE';
  static const String wireless = 'WIRELESS';
}

class AlarmSeverity {
  static const String info = 'INFO';
  static const String warning = 'WARNING';
  static const String error = 'ERROR';
  static const String critical = 'CRITICAL';
}

class ValveStatus {
  static const String open = 'OPEN';
  static const String closed = 'CLOSED';
  static const String error = 'ERROR';
}

class ControllerStatus {
  static const String online = 'ONLINE';
  static const String offline = 'OFFLINE';
  static const String error = 'ERROR';
  static const String maintenance = 'MAINTENANCE';
}
