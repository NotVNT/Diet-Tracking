import 'package:mockito/annotations.dart';

import 'package:diet_tracking_project/features/home_page/domain/repositories/home_repository.dart';
import 'package:diet_tracking_project/features/home_page/domain/usecases/get_home_info_usecase.dart';
import 'package:diet_tracking_project/services/permission_service.dart';
import 'package:diet_tracking_project/services/notification_service.dart';

@GenerateMocks([
  HomeRepository,
  GetHomeInfoUseCase,
  PermissionService,
  LocalNotificationService,
])
void main() {}
