import 'package:jetlog/jetlog.dart';

void main() {
  final logger = Logger.getLogger('example.lazy');
  final context = logger.lazy.bind(() => {Str('hell', 'yeah')});

  context.lazy.info(() => 'Lazy');
}
