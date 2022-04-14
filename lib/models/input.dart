import 'dart:io';

class Input {
  final String name, origin, type;

  Input({
    required this.name,
    required this.origin,
    required this.type,
  });

  factory Input.fromJson(Map<String, dynamic> json) {
    return Input(
      name: json['name'],
      origin: json['origin'],
      type: json['type'],
    );
  }

  dynamic getValue() {
    if (origin.toLowerCase() == 'environment') {
      switch (type.toLowerCase()) {
        case 'int':
          return int.parse(Platform.environment[name] ?? '-1');
        case 'boolean':
          return Platform.environment[name] == 'true' ? true : false;
        default:
          return Platform.environment[name];
      }
    } else {
      switch (type.toLowerCase()) {
        case 'int':
          return int.parse(origin);
        case 'double':
          return double.parse(origin);
        case 'boolean':
          return origin.toLowerCase() == 'true' ? true : false;
        default:
          return origin.toString();
      }
    }
  }
}
