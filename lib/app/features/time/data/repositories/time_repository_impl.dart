import 'package:pixel_retro_app/app/features/time/domain/datasources/time_datasource.dart';
import 'package:pixel_retro_app/app/features/time/domain/repositories/time_repository.dart';

class TimeRepositoryImpl implements TimeRepository {
  final TimeDataSource dataSource;

  TimeRepositoryImpl(this.dataSource);

  @override
  Future<DateTime> getTime() {
    return dataSource.getTime();
  }
}
