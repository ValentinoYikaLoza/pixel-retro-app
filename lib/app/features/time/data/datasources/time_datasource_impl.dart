import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/time/data/dtos/get_time_response_dto.dart';
import 'package:pixel_retro_app/app/features/time/data/mappers/get_time_response_mapper.dart';
import 'package:pixel_retro_app/app/features/time/domain/datasources/time_datasource.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';

class TimeDataSourceImpl implements TimeDataSource {
  TimeDataSourceImpl(this._api);

  final Api _api;

  @override
  Future<DateTime> getTime() async {
    try {
      final response = await _api.get(ApiEndpoints.getTime);
      final dto = GetTimeResponseDto.fromJson(response.data);
      return GetTimeResponseMapper.fromDtoToEntity(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener la hora',
      );
    }
  }
}
