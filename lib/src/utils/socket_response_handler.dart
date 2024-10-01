import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../request/tcp_command.dart';
import '../request/tcp_request.dart';
import 'constants.dart';

final class SocketResponseHandler {
  final void Function(TCPRequest) onReceived;
  SocketResponseHandler(this.onReceived);

  Socket? _socket;
  final _bytes = List<int>.empty(growable: true);
  final _messages = List<int>.empty(growable: true);
  static const _dividerString = '||';
  int _fileLength = 0;
  String? _fileName;
  bool _isFile = false;

  StreamSubscription<Uint8List> listenToSocket() => _socket!.listen(_mapper);

  void _mapper(Uint8List bytes) {
    if (_handleBytes(bytes)) return;
    final commands = _compileIncommingMessage(bytes);
    if (commands == null) return;
    for (var command in commands) {
      if (_handleSendFileCommand(command)) continue;
      if (_handleStringCommand(command)) continue;
    }
  }

  bool _handleBytes(List<int> bytes) {
    if (!_isFile) return false;
    _bytes.addAll(bytes);
    if (_bytes.length >= _fileLength) {
      final request = TCPRequest.file(_bytes.toList(), _fileName);
      _bytes.clear();
      _fileLength = 0;
      _isFile = false;
      _fileName = null;
      onReceived(request);
    }
    return true;
  }

  List<String>? _compileIncommingMessage(List<int> bytes) {
    try {
      _messages.addAll(bytes);
      var data = utf8.decode(_messages.toList());
      if (!data.endsWith(Constants.kEndOfMessage)) return null;
      data = data.replaceRange(data.length - Constants.kEndOfMessage.length, data.length, '');
      _messages.clear();
      if (!data.contains(_dividerString)) return null;
      final commands = data.split(_dividerString);
      final result = List<String>.empty(growable: true);
      for (var command in commands) {
        if (command.isEmpty) continue;
        result.add(command);
      }
      return result;
    } catch (error) {
      return null;
    }
  }

  bool _handleSendFileCommand(String message) {
    if (!message.startsWith(TCPCommand.sendFile.stringValue)) return false;
    final temp = message.split(':');
    // Send File command config is not right. Invalid Messagin protocol
    if (temp.length < 2) return false;
    final length = int.tryParse(temp[1]);
    // Send File command config is not right. Invalid file length
    if (length == null) return false;
    _fileLength = length;
    _isFile = true;
    if (temp.length >= 3) _fileName = temp[2];
    return true;
  }

  bool _handleStringCommand(String message) {
    final request = TCPRequest.command(message);
    onReceived(request);
    return true;
  }
}
