import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:get/get.dart';
import 'package:software_security/ffi/u8_ptr_to_str.dart';
import 'generated_bindings.dart'; //flutter pub run ffigen
import 'dart:isolate';

final ffilib _lib = _create();
final RxString ffi_channel_str = RxString('');

final List<String> ffi_channel_str_list = [];
final StreamController<bool> _streamController = StreamController();
final Stream<bool> ffi_channel_str_list_notification = _streamController.stream;

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

void initLib(String path) async {
  _receivePort = ReceivePort();
  _iso = await Isolate.spawn(_newIsolate, _receivePort!.sendPort);
  _receivePort!.listen((message) {
    if (message is SendPort) {
      _rSendPort = message; //ready
      _rSendPort!.send(_internal_send_data_t(LIB_START_SIG, path));
    } else {
      final data = message as _internal_send_data_t;
      if (data.type == 1) {
        _streamController.sink.add(LIST_INCREASE);
        ffi_channel_str_list.add(data.str);
      } else {
        ffi_channel_str.value = data.str;
      }
    }
  });
}

void stopLib() {
  _receivePort?.close();
  _iso?.kill();
  // _rSendPort?.send(const _internal_send_data_t(LIB_STOP_SIG, ''));
}

void _newIsolate(SendPort sendPort) {
  _sendPort = sendPort;
  _rRcvPort = ReceivePort();
  sendPort.send(_rRcvPort!.sendPort);
  _rRcvPort!.listen(iso_listen);
}

void iso_listen(message) async {
  final msg = message as _internal_send_data_t;
  if (msg.type == LIB_START_SIG) {
    ffi.Pointer<send_fn_t> fn = ffi.Pointer.fromFunction(_callback);
    final data = calloc.allocate<struct_attach_>(ffi.sizeOf<struct_attach_>());
    data.ref.executable_path = msg.str.toNativeUtf8().cast();
    data.ref.time = DateTime.now().millisecondsSinceEpoch;
    data.ref.send_fn = fn;
    _lib.ci_init(data);
    calloc.free(data);
  }
}

class _internal_send_data_t {
  const _internal_send_data_t(this.type, this.str);

  final int type;

  final String str;
}

void _callback(send_data_t data) {
  final ffi.Pointer<ffi.Uint8> codeUnits = data.ref.str.cast();

  _sendPort?.send(_internal_send_data_t(data.ref.type, codeUnits.string));
}
