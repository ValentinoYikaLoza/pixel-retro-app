import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';

final api = Api();

class MissionDataSourceImpl implements MissionDataSource {
  @override
  Future<void> getMissions() async {
    try {
      Map<String, String> formData = {'user_id': '1'};

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
