import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hello_world_mvp/new_chat/injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();