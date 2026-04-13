import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(),
      ciGoldensConfig: CiGoldensConfig(enabled: false),
    ),
    run: () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      return testMain();
    },
  );
}
