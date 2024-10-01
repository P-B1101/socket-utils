enum BodyType {
  file,
  string,
  unknown;

  String get stringValue => switch (this) {
        file => 'FILE',
        string => 'STRING',
        unknown => 'UNKNOWN',
      };

  static BodyType fromString(String value) => switch (value) {
        'FILE' => file,
        'STRING' => string,
        _ => unknown,
      };
}
