import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/main.dart';

final api = Api();
final userId = globalUserId;

class MissionDataSourceImpl implements MissionDataSource {
  @override
  Future<void> getMissions() async {
    try {
      Map<String, String> formData = {'user_id': userId.toString()};

      final response = await api.post('/listMissions', data: formData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      String errorMessage = ErrorService.verificarErrorBase(
        'Ocurrió un error',
        e,
      );
      throw ServiceException(errorMessage);
    }
  }

  @override
  Future<void> updateProgress(UpdateProgressRequestModel request) {
    return Future.delayed(Duration(milliseconds: 200), () {
      return;
    });
  }
}
