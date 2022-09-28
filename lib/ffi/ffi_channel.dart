import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:get/get.dart';
import 'package:software_security/ffi/u8_ptr_to_str.dart';
import 'generated_bindings.dart'; //flutter pub run ffigen
import 'dart:isolate';

final ffilib _lib = _create();
final RxString ffi_channel_str = RxString('');

final List<LocalizedSentData> ffi_channel_list = [];
final StreamController<bool> channelStreamController = StreamController();
final Stream<bool> ffi_channel_str_list_notification = channelStreamController.stream;

const LIST_INCREASE = true;
const LIST_DECREASE = false;

ffilib _create() {
  final String libraryPath;
  if (GetPlatform.isMacOS) {
    libraryPath = 'libci.dylib';
  } else if (GetPlatform.isWindows) {
    libraryPath = 'ci.dll';
  } else {
    libraryPath = 'libci.so';
  }
  return ffilib(ffi.DynamicLibrary.open(libraryPath));
}

Isolate? _iso;
ReceivePort? _receivePort;
SendPort? _rSendPort;
SendPort? _sendPort;
ReceivePort? _rRcvPort;

void initLib(String path, int config) async {
  _receivePort = ReceivePort();
  _iso = await Isolate.spawn(_newIsolate, _receivePort!.sendPort);
  _receivePort!.listen((message) {
    if (message is SendPort) {
      _rSendPort = message; //ready
      _rSendPort!.send(LocalizedSentData(config, LIB_START_SIG, path));
    } else {
      final data = message as LocalizedSentData;
      if (data.type == send_data_to_header) {
        ffi_channel_str.value = data.str;
      } else {
        ffi_channel_list.add(data);
        channelStreamController.sink.add(LIST_INCREASE);
      }
    }
  });
}

void stopLib() {
  _receivePort?.close();
  _receivePort = null;
  _iso?.kill(priority: Isolate.immediate);
  _iso = null;
  // _rSendPort?.send(const _internal_send_data_t(LIB_STOP_SIG, ''));
}

void _newIsolate(SendPort sendPort) {
  _sendPort = sendPort;
  _rRcvPort = ReceivePort();
  sendPort.send(_rRcvPort!.sendPort);
  _rRcvPort!.listen(iso_listen);
}

void iso_listen(message) async {
  final msg = message as LocalizedSentData;
  if (msg.time == LIB_START_SIG) {
    ffi.Pointer<send_fn_t> fn = ffi.Pointer.fromFunction(_callback);
    final data = calloc.allocate<struct_attach_>(ffi.sizeOf<struct_attach_>());
    data.ref.executable_path = msg.str.toNativeUtf8().cast();
    data.ref.time = DateTime.now().millisecondsSinceEpoch;
    data.ref.type = msg.type;
    data.ref.send_fn = fn;
    _lib.ci_init(data);
    calloc.free(data);
  }
}

enum MsgType {
  heap,
  file,
  reg,
  net,
  memcpy,
  msgBox;

  String get label {
    switch (this) {
      case MsgType.heap:
        return 'heap: ';
      case MsgType.file:
        return 'file: ';
      case MsgType.reg:
        return 'reg: ';
      case MsgType.net:
        return 'net: ';
      case MsgType.memcpy:
        return 'memcpy: ';
      case MsgType.msgBox:
        return 'msgBox: ';
    }
  }
}

class LocalizedSentData {
  const LocalizedSentData(this.type, this.time, this.str);

  final int type;

  final int time;

  final String str;

  MsgType get msgType {
    if ((type & heap_basic_t) == heap_basic_t) {
      return MsgType.heap;
    } else if ((type & file_basic_t) == file_basic_t) {
      return MsgType.file;
    } else if ((type & reg_basic_t) == reg_basic_t) {
      return MsgType.reg;
    } else if ((type & net_basic_t) == net_basic_t) {
      return MsgType.net;
    } else if ((type & memcpy_basic_t) == memcpy_basic_t) {
      return MsgType.memcpy;
    } else if ((type & msg_box_t) == msg_box_t) {
      return MsgType.msgBox;
    }
    return MsgType.heap;
  }

  bool get restrict => (type & restrict_t) == restrict_t;
}

extension LocalizedData on send_data_t {
  LocalizedSentData get localizedData =>
      LocalizedSentData(ref.type, DateTime.now().millisecondsSinceEpoch, ref.str.str);
}

void _callback(send_data_t data) {
  _sendPort?.send(data.localizedData);
}
