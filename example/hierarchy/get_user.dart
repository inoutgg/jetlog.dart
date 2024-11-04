import 'package:strlog/strlog.dart'
    show Logger, Loggable, Str, Obj, Field, DefaultLog;

// A child logger of logger with namespace `strlog.example.hierarchy`.
final logger = Logger.getLogger('strlog.example.hierarchy.get_user');

class User implements Loggable {
  const User(this.name, this.email);

  final String name;
  final String email;

  @override
  Iterable<Field> toFields() => ({Str('email', email), Str('name', name)});
}

User getUser() {
  logger.info('Fetching user...');
  final user = User('Roman', 'me@romanvanesyan.com');
  logger.info('Fetched user', {Obj('user', user)});

  return user;
}
