import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import './generated_crc32.dart';

class Crc32Wrapper {
  static final Crc32Wrapper _crc32Wrapper = Crc32Wrapper._internal();
  static late Crc32 _crc32;

  factory Crc32Wrapper() => _crc32Wrapper;

  Crc32Wrapper._internal() {
    late DynamicLibrary dl;
    if (Platform.isAndroid) {
      dl = DynamicLibrary.open('libcrc32.so');
    } else if (Platform.isIOS) {
      dl = DynamicLibrary.process();
    }
    _crc32 = Crc32(dl);
  }

  int crc32(List<int> buffer) {
    Pointer<UnsignedChar> data = calloc.allocate(buffer.length);
    Pointer<Uint32> crc = calloc.allocate(4);
    for (var i = 0; i < buffer.length; i++) {
      data[i] = buffer[i];
    }
    _crc32.crc32(data.cast<Void>(), buffer.length, crc);
    int result = crc.value;
    calloc.free(data);
    calloc.free(crc);
    return result;
  }
}
