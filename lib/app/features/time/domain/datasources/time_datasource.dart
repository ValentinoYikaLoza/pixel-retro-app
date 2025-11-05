import 'package:pixel_retro_app/app/features/time/domain/models/get_time_response_model.dart';

abstract class TimeDataSource {
  Future<GetTimeResponseModel> getTime();
}
