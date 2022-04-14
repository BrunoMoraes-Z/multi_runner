import 'package:queue/queue.dart';
import 'package:rpa/controller/action_controller.dart';
import 'package:rpa/models/config.dart';

late Config config;
bool stop = false;

void main(List<String> args) async {
  if (!await Config.exists()) {
    print('Nenhum Arquivo de Configuração encontrado.');
    return;
  }
  config = await Config.fromFile();
  if (config.actions.isNotEmpty) {
    final queue = Queue();
    queue.parallel = 1;

    config.actions.forEach((action) async {
      queue.add(() => ActionController().execute(action));
      queue.add(() => Future.delayed(Duration(seconds: 5)));
    });

    await queue.onComplete;
  }
}
