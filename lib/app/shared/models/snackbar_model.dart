import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';

class SnackbarModel {
  final String id;
  final String message;
  final SnackbarType type;

  SnackbarModel({required this.id, required this.message, required this.type});
}
