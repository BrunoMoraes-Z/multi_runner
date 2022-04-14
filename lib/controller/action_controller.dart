import 'dart:convert';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:rpa/models/action.dart';
import 'package:rpa/multi_runner.dart';
import 'package:rpa/shared/alias.dart';
import 'package:rpa/shared/process.dart';
import 'package:http/http.dart' as http;

class ActionController {
  Future<String> _buildCommand(Action action, {String value = ''}) async {
    if (value.isEmpty) value = action.command;

    if (action.inputs.isNotEmpty) {
      action.inputs.forEach((input) {
        value =
            value.replaceAll('[${input.name}]', input.getValue().toString());
      });
    }

    return value;
  }

  Future<void> execute(Action action) async {
    if (stop) return;
    var cmd = await _buildCommand(action);
    var exe = cmd.split(' ')[0];
    var args = cmd.replaceFirst('$exe ', '');

    // Commando Type
    if (action.type.toLowerCase() == 'run_command') {
      await _runCommand(action: action, exe: exe, args: args.split(' '));
      // System Type
    } else if (action.type.toLowerCase() == 'system') {
      await _system(action: action);
      // Zip Type
    } else if (action.type.toLowerCase() == 'zip') {
      await _zip(action: action, exe: exe, args: args);
      // Download File Type
    } else if (action.type.toLowerCase() == 'download_file') {
      await _downloadFile(action: action);
    }
  }

  Future<void> _runCommand({
    required Action action,
    required String exe,
    required List<String> args,
  }) async {
    var process = await runProcess(
      parseExecutableAlias(exe),
      args,
      action.workDir,
    );
    var log = logProcessResult(process);

    log.forEach((element) => print(element));
  }

  Future<void> _system({required Action action}) async {
    var dir = Directory(action.workDir);
    if (action.command.toLowerCase() == 'delete_folder') {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  }

  Future<void> _zip({
    required Action action,
    required String exe,
    required String args,
  }) async {
    var dir = Directory(action.workDir);

    if (exe.toLowerCase() == 'unzip') {
      await FTPConnect.unZipFile(File('${dir.path}/${args}'), action.workDir);
    } else if (exe.toLowerCase() == 'zip') {
      await FTPConnect.zipFiles(
        await dir
            .list(recursive: true)
            .map(
              (event) => event.path,
            )
            .toList(),
        action.workDir,
      );
    }
  }

  Future<void> _downloadFile({required Action action}) async {
    // Monta o Header da Request
    Map<String, String> headers = {};
    if (action.inputs.length >= 1) {
      var hasHeader =
          action.inputs.where((element) => element.name == 'b64_token');
      if (hasHeader.isNotEmpty) {
        var b64 = base64.encode(utf8.encode('${hasHeader.first.origin}:'));
        headers = {'Authorization': 'Basic $b64'};
      }
    }

    // Se o WorkDir existir será limpo e então criado novamente.
    if (await Directory(action.workDir).exists()) {
      await Directory(action.workDir).delete(recursive: true);
    }
    await Directory(action.workDir).create(recursive: true);

    // Verifica se foi informado um nome custom do arquivo.
    var hasFileName =
        action.inputs.where((element) => element.name == 'file_name');
    String fileName = '';
    if (hasFileName.isNotEmpty) {
      fileName = hasFileName.first.origin;
    }

    // Notifica que o Arquivo esta sendo baixado
    print(
      'Realizando Download ${fileName.isEmpty ? "de um arquivo" : "do arquivo $fileName"}...',
    );

    // Realiza o Download do arquivo
    var response = await http.get(
      Uri.parse(await _buildCommand(action)),
      headers: headers,
    );

    // Verifica se o Download deu erro
    if ([404, 400, 401, 500].contains(response.statusCode)) {
      // Se a Action é para parar caso ocora um erro então flag Stop sera marcada.
      if (action.failAction.toLowerCase() == 'stop') {
        stop = true;
      }

      // Notifica que ouve um erro ao efetuar Download
      if (action.failMessage.isNotEmpty) {
        print(await _buildCommand(action, value: action.failMessage));
      } else {
        print('Não foi possivel realizar download deste arquivo.');
      }
    } else {
      // Salva o arquivo baixado dentro da WorkDir
      var file = await File('${action.workDir}/download.zip')
          .writeAsBytes(response.bodyBytes);

      // Calcula o Tamanho do arquivo baixado
      int size = (await file.length() / 1024).round();

      // Notifica o arquivo baixado e seu tamanho.
      print(
        'Arquivo${fileName.isEmpty ? "" : " $fileName"} baixado com tamanho de ($size KB | ${(size / 1000).round()} MB).',
      );
    }
  }
}
