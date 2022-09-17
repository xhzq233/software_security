import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'generated_bindings.dart';
import 'dart:isolate';

final _receivePort = ReceivePort();

RxString ffi_channel_str = RxString('');
RxList<String> ffi_channel_str_list = RxList();

xhzq233 _create() {
  var libraryPath = path.join(Directory.current.path, 'ci', 'libci.so');
  if (Platform.isMacOS) {
    libraryPath = path.join(Directory.current.path, 'ci', 'libci.dylib');
  }
  if (Platform.isWindows) {
    libraryPath = path.join(Directory.current.path, 'ci', 'libci.dll');
  }
  final dylib = ffi.DynamicLibrary.open(libraryPath);

  return xhzq233(dylib);
}

final xhzq233 _lib = _create();

void initFFIChannel() {
  Isolate.spawn(_newIsolate, _receivePort.sendPort);
  _receivePort.listen((message) {
    final data = message as _internal_send_data_t;
    if (data.type == 1) {
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
  _lib.init(fn);
}

class _internal_send_data_t {
  const _internal_send_data_t(this.type, this.str);

  final int type;

  final String str;
}

void _callback(ffi_send_data data) {
  final ffi.Pointer<ffi.Uint8> codeUnits = data.ref.str.cast();

  int length(ffi.Pointer<ffi.Uint8> codeUnits) {
    var length = 0;
    while (codeUnits[length] != 0) {
      length++;
    }
    return length;
  }

  final str = utf8.decode(codeUnits.asTypedList(length(codeUnits)));

  _sendPort?.send(_internal_send_data_t(data.ref.type, str));
}
