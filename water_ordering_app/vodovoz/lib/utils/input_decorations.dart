import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/order.dart';

ButtonStyle btnStl = ButtonStyle(
    backgroundColor:
        const MaterialStatePropertyAll<Color>(Colors.deepOrangeAccent),
    shape:
        MaterialStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.sp),
    )),
    textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 24.sp)));
ButtonStyle btnStlGreen = ButtonStyle(
    backgroundColor: const MaterialStatePropertyAll<Color>(Colors.green),
    shape:
        MaterialStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.sp),
    )),
    textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 18.sp)));
ButtonStyle btnStlGrey = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey),
    shape:
        MaterialStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.sp),
    )),
    textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 18.sp)));
InputDecorationTheme inpDecStl = InputDecorationTheme(
  border: UnderlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
  fillColor: Colors.white,
  filled: true,
  labelStyle: TextStyle(fontSize: 24.sp, color: Colors.grey),
);

InputDecoration inptDec(String lbl, bool enb) {
  return InputDecoration(
    filled: true,
    fillColor: getEnabledOrDisabledColor(Colors.deepOrangeAccent,
        Color.lerp(Colors.white, Colors.deepOrangeAccent, 0.5), enb),
    border: UnderlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
    labelText: lbl,
    labelStyle: const TextStyle(color: Colors.white),
    enabled: enb,
  );
}

InputDecoration inptDec1(String lbl, bool enb) {
  return InputDecoration(
    filled: true,
    fillColor: getEnabledOrDisabledColor(
        Colors.white, Color.lerp(Colors.grey, Colors.white, 0.5), enb),
    border: UnderlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
    labelText: lbl,
    labelStyle: const TextStyle(color: Colors.grey),
    enabled: enb,
  );
}

InputDecoration inptDec1NoLabel(bool enb) {
  return InputDecoration(
    floatingLabelBehavior: FloatingLabelBehavior.never,
    filled: true,
    fillColor: getEnabledOrDisabledColor(
        Colors.white, Color.lerp(Colors.black, Colors.white, 0.5), enb),
    border: UnderlineInputBorder(borderRadius: BorderRadius.circular(20.sp)),
    labelStyle: const TextStyle(color: Colors.black),
    enabled: enb,
  );
}

Color? getEnabledOrDisabledColor(
    Color enabledColor, Color? DisabledColor, bool enable) {
  if (enable)
    return enabledColor;
  else
    return DisabledColor;
}

String getOrderStatusMessage(Order order) {
  switch (order.status) {
    case 'accepted':
      return 'Ваш заказ в режиме ожидания начала поездки доставщиком';
    case 'inProgress':
      return 'Ваш заказ в процессе доставки.';
    case 'completed':
      return 'Ваш заказ доставлен!';
    case 'canceled':
      return 'Ваш заказ отменен.';
    default:
      return 'Статус заказа неизвестен.';
  }
}
