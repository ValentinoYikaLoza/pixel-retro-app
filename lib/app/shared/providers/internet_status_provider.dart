import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/services/internet_service.dart';

final internetStatusProvider = StreamProvider<bool>(
  (ref) => InternetService.instance.connectionStream,
);
