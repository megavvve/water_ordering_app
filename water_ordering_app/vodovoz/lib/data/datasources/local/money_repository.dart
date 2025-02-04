// repositories/money_repository.dart
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/constants.dart';

class MoneyRepository {
  final delivererRepository = getIt<DelivererRepository>();
  final orderRepository = getIt<OrderRepository>();

  /// Пополнить баланс водовоза
  void deposit(Deliverer deliverer, int amount) {
    if (amount <= 0) {
      throw ArgumentError('Сумма пополнения должна быть положительной.');
    }
    deliverer.balance += amount;
    delivererRepository.updateDeliverer(deliverer);
    print(
        'Баланс водовоза ${deliverer.userId} пополнен на $amount₽. Текущий баланс: ${deliverer.balance}₽');
  }

  /// Списать средства с баланса водовоза
  void withdraw(Deliverer deliverer, int amount) {
    if (amount <= 0) {
      throw ArgumentError('Сумма для списания должна быть положительной.');
    }
    if (amount > deliverer.balance) {
      throw StateError('Недостаточно средств для списания.');
    }
    deliverer.balance -= amount;
    delivererRepository.updateDeliverer(deliverer);
    print(
        'С баланса водовоза ${deliverer.userId} списано $amount₽. Текущий баланс: ${deliverer.balance}₽');
  }

  /// Рассчитать и списать комиссию
  void deductCommission(Deliverer deliverer, int orderAmount) {
    int commission = (orderAmount * commissionPercentage) ~/ 100;
    if (commission == 0) {
      commission = 1;
    }
    withdraw(deliverer, commission);
    print('Комиссия $commission₽ списана с баланса ${deliverer.userId}.');
  }

  /// Получить баланс водовоза
  int getBalance(Deliverer deliverer) {
    return deliverer.balance;
  }

  /// Изменить цену за единицу доставки
  void updatePricePerUnit(
      Deliverer deliverer, int newPriceList, int newPricePiece) {
    if (newPriceList <= 0 && newPricePiece <= 0) {
      throw ArgumentError(
          'Цена за единицу доставки должна быть положительной.');
    }
    deliverer.pricePerLiter = newPriceList;
    deliverer.pricePerPiece = newPricePiece;
    delivererRepository.updateDeliverer(deliverer);
    print(
        'Цена за единицу доставки для водовоза ${deliverer.userId} обновлена .');
  }

  /// Получить текущую цену за единицу доставки водовоза
  int getPricePerUnit(Deliverer deliverer, bool isPricePiece) {
    return isPricePiece ? deliverer.pricePerPiece : deliverer.pricePerLiter;
  }

  /// Списать комиссию с заказа
  void deductCommissionFromOrder(Order order, Deliverer deliverer) {
    // Рассчитать сумму заказа
    int orderAmount = getOrderPriceWithPotentialDeliverer(order, deliverer);

    // Рассчитать и списать комиссию
    deductCommission(deliverer, orderAmount);

    print('Комиссия за заказ с ID ${order.id} списана.');
  }

  /// Обновить цену заказа
  void updateOrderPrice(Order order, Deliverer deliverer) {
    int newPrice = getOrderPriceWithPotentialDeliverer(
      order,
      deliverer,
    );
    order.price = newPrice;
    orderRepository.updateOrder(order);
    print('Цена заказа с ID ${order.id} обновлена: $newPrice₽.');
  }

  /// Получить текущую цену заказа
  int getOrderPrice(Order order) {
    return order.price;
  }

  int getOrderPriceWithPotentialDeliverer(Order order, Deliverer deliverer) {
    return !order.isLitre!
        ? order.quantity * deliverer.pricePerPiece
        : order.quantity * deliverer.pricePerLiter;
  }
}
