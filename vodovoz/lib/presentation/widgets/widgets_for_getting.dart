import 'package:vodovoz/utils/constants.dart';

String getWaterTypeLabel(int value) {
  return waterTypes.firstWhere((entry) => entry.value == value).label;
}

String getPayTypeLabel(int value) {
  return payType.firstWhere((entry) => entry.value == value).label;
}

 String translateOrderStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидается';
      case 'accepted':
        return 'Принят';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершён';
      case 'canceled':
        return 'Отменён';
      default:
        return 'Неизвестно';
    }
  }