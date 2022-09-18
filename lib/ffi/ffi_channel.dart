import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:get/get.dart';
import 'package:software_security/ffi/u8_ptr_to_str.dart';
import 'generated_bindings.dart';
import 'dart:isolate';

final _receivePort = ReceivePort();

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

final ffilib _lib = _create();

void initFFIChannel() {
  Isolate.spawn(_newIsolate, _receivePort.sendPort);
  _receivePort.listen((message) {
    final data = message as _internal_send_data_t;
    if (data.type == 1) {
      _streamController.sink.add(LIST_INCREASE);
      ffi_channel_str_list.add(data.str);
    } else {
      ffi_channel_str.value = data.str;
    }
  });
}

SendPort? _sendPort;

void _newIsolate(SendPort sendPort) {
  _sendPort = sendPort;
  ffi.Pointer<send_fn_t> fn = ffi.Pointer.fromFunction(_callback);
  _lib.ci_init(fn);
}

class _internal_send_data_t {
  const _internal_send_data_t(this.type, this.str);

  final int type;

  final String str;
}

void _callback(ffi_send_data data) {
  final ffi.Pointer<ffi.Uint8> codeUnits = data.ref.str.cast();

  _sendPort?.send(_internal_send_data_t(data.ref.type, codeUnits.string));
}
