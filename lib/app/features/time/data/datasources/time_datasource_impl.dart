import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/time/data/dtos/get_time_response_dto.dart';
import 'package:pixel_retro_app/app/features/time/data/mappers/get_time_response_mapper.dart';
import 'package:pixel_retro_app/app/features/time/domain/datasources/time_datasource.dart';
import 'package:pixel_retro_app/app/features/time/domain/models/get_time_response_model.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';

final api = Api();

class TimeDataSourceImpl implements TimeDataSource {
  @override
  Future<GetTimeResponseModel> getTime() async {
    try {
      final response = await api.get('/getTime');
      if (response.statusCode == 200) {
        final dto = GetTimeResponseDto.fromJson(response.data);
        return GetTimeResponseMapper.fromDtoToModel(dto);
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
}
