import 'dart:io';

Future<ProcessResult> runProcess(
  String exe,
  List<String> args,
  String workDir,
) async {
  // var a = await Process.start(exe, args, workingDirectory: workDir.isNotEmpty ? workDir : null);

  // a.stdout.transform(utf8.decoder).listen((data) {
  //   data.split('\r\n').forEach((element) { 
  //     if (element.trim().isNotEmpty) {
  //       print(element);
  //     }
  //   });
  // });

  return Process.run(
    exe,
    args,
    workingDirectory: workDir.isNotEmpty ? workDir : null,
  );
}

List<String> logProcessResult(ProcessResult result) {
  List<String> out = [];
  result.stdout.toString().split('\r\n').forEach(
    (element) {
      if (element.trim().isNotEmpty) {
        out.add(element);
      }
    },
  );
  return out;
}
