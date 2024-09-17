import 'package:vodovoz/utils/constants.dart';

String getWaterTypeLabel(int value) {
  return waterTypes.firstWhere((entry) => entry.value == value).label;
}

String getPayTypeLabel(int value) {
  return payType.firstWhere((entry) => entry.value == value).label;
}
