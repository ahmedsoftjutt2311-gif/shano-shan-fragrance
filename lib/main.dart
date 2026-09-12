import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'services/cart_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CartService.instance.initialize();

  runApp(
    const ShanoShanApp(),
  );
}