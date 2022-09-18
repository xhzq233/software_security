import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';
import 'package:software_security/ffi/ffi_channel.dart';

RxString filePath = RxString('');

void selectFile() async {
  final XTypeGroup typeGroup = XTypeGroup(
    label: 'executables',
    extensions: null,
  );

  final XFile? file =
      await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (null != file) {
    filePath.value = file.path;
    initFFIChannel(file.path);
  }
}
