import '../request/tcp_command.dart';

class TCPRequest {
  final TCPCommand command;
  final Object? body;
  final String? fileName;

  const TCPRequest({
    required this.body,
    required this.command,
    required this.fileName,
  });

  factory TCPRequest.command(String command) => TCPRequest(
        body: command,
        command: TCPCommand.sendMessage,
        fileName: null,
      );

  factory TCPRequest.file(List<int> bytes, String? fileName) => TCPRequest(
        body: bytes,
        command: TCPCommand.sendFile,
        fileName: fileName,
      );

  @override
  String toString() {
    switch (command) {
      case TCPCommand.sendMessage:
        return body.toString();
      case TCPCommand.sendFile:
      case TCPCommand.unknown:
        return command.stringValue;
    }
  }
}
