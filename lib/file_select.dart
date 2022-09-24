import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';
import 'package:software_security/ffi/ffi_channel.dart';
import 'package:software_security/ffi/generated_bindings.dart';

const HCClose = 0;
const HCOpen = 1;
const HCRestrict = 2;

class Ref<T> {
  Ref(this.val);

  T val;
}

class HookConfig {
  final Ref<int> msgBox = Ref(HCClose);
  final Ref<int> heap = Ref(HCClose);
  final Ref<int> file = Ref(HCClose);
  final Ref<int> reg = Ref(HCClose);
  final Ref<int> net = Ref(HCClose);
  final Ref<int> memcpy = Ref(HCClose);
}

final HookConfig hookConfig = HookConfig();

RxString filePath = RxString('');

void selectFile() async {
  final XTypeGroup typeGroup = XTypeGroup(
    label: 'executables',
    extensions: ['exe', 'png'],
  );

  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (null != file) {
    filePath.value = file.path;
    stopLib();
    int config = 0;
    if (hookConfig.msgBox.val == HCOpen) {
      config |= msg_box_t;
    }
    if (hookConfig.heap.val == HCOpen) {
      config |= heap_basic_t;
    } else if (hookConfig.heap.val == HCRestrict) {
      config |= heap_restrict_t;
    }
    if (hookConfig.file.val == HCOpen) {
      config |= file_basic_t;
    } else if (hookConfig.file.val == HCRestrict) {
      config |= file_restrict_t;
    }
    if (hookConfig.reg.val == HCOpen) {
      config |= reg_basic_t;
    } else if (hookConfig.reg.val == HCRestrict) {
      config |= reg_restrict_t;
    }
    if (hookConfig.net.val == HCOpen) {
      config |= net_basic_t;
    } else if (hookConfig.net.val == HCRestrict) {
      config |= net_restrict_t;
    }
    if (hookConfig.memcpy.val == HCOpen) {
      config |= memcpy_basic_t;
    } else if (hookConfig.memcpy.val == HCRestrict) {
      config |= memcpy_restrict_t;
    }
    initLib(file.path, config);
  }
}
