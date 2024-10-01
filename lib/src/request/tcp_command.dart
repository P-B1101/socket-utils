enum TCPCommand {
  sendMessage,
  sendFile,
  unknown;

  String get stringValue => switch (this) {
        sendMessage => 'SEND_MESSAGE',
        sendFile => 'SEND_FILE',
        unknown => 'UNKNOWN',
      };

  static TCPCommand fromString(String value) => switch (value) {
        'SEND_MESSAGE' => sendMessage,
        'SEND_FILE' => sendFile,
        _ => unknown,
      };
}
