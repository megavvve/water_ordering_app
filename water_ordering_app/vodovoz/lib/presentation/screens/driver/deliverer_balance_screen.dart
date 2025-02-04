import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/local/money_repository.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/utils/constants.dart';

class DelivererBalanceScreen extends StatefulWidget {
  const DelivererBalanceScreen({super.key});

  @override
  DelivererBalanceScreenState createState() => DelivererBalanceScreenState();
}

class DelivererBalanceScreenState extends State<DelivererBalanceScreen> {
  Deliverer? _deliverer;
  bool _isLoading = true;
  final moneyRepository = getIt<MoneyRepository>();

  @override
  void initState() {
    super.initState();
    _loadDeliverer();
  }

  Future<void> _loadDeliverer() async {
    final deliverer = await getIt<DelivererRepository>()
        .getDeliverer(getIt<LocalSavedData>().getUserId());

    if (deliverer != null && defaultBalance != 0 && deliverer.balance == 0) {
      deliverer.balance = defaultBalance;
      getIt<DelivererRepository>().updateDeliverer(deliverer);
    }
    setState(() {
      _deliverer = deliverer;
      _isLoading = false;
    });
  }

  void _processOrder(int quantity) {
    if (_deliverer == null) return;

    int orderAmount = _deliverer!.pricePerPiece * quantity;
    moneyRepository.deductCommission(_deliverer!, orderAmount);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Комиссия списана. Текущий баланс: ${_deliverer!.balance} ₽",
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        endDrawer: drawer(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Баланс Водовоза',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildBalanceCard(),
                      SizedBox(height: 40.h),
                      _buildOrderButton(),
                      SizedBox(height: 30.h),
                      ElevatedButton.icon(
                        onPressed: () => _processOrder(1),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text(
                            'Взять заказ на 1 штуку (для проверки)'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.h, horizontal: 32.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          textStyle: TextStyle(fontSize: 18.sp),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return  (_deliverer!= null)?Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Текущий баланс',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
           Text(
              '${_deliverer!.balance}₽',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Цена за литр воды: ${_deliverer!.pricePerLiter}₽',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  'Цена за штуку воды: ${_deliverer!.pricePerPiece}₽',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ):SizedBox.shrink();
  }

  Widget _buildOrderButton() {
    return ElevatedButton(
      //onPressed: () => _processOrder(1),
      onPressed: () { ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey,
        content: Text(
          "Функция в разработке",
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.sp),
        ),
        textStyle: TextStyle(fontSize: 18.sp),
      ),
      //icon: const Icon(Icons.),
      child: const Text('Пополнить баланс'),
    );
  }
}
