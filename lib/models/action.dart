import 'package:rpa/models/input.dart';

class Action {
  final String type;
  final String command;
  final String workDir;
  final List<Input> inputs;
  final String failAction;
  final String failMessage;

  Action({
    required this.type,
    required this.command,
    required this.workDir,
    required this.inputs,
    required this.failAction,
    required this.failMessage,
  });

  factory Action.fromJson(Map<String, dynamic> json) {
    var its = (json['inputs'] as List).map((k) => Input.fromJson(k)).toList();
    var failAction =
        json.containsKey('on_fail') ? json['on_fail']['action'] : '';
    var failMessage =
        json.containsKey('on_fail') ? json['on_fail']['message'] : '';
    return Action(
      type: json['type'],
      command: json['command'],
      workDir: json['workdir'],
      inputs: its,
      failAction: failAction,
      failMessage: failMessage,
    );
  }
}
