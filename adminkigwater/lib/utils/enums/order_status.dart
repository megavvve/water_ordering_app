enum OrderStatus {
  pending,
  awaitingConfirmation,
  accepted,
  inProgress,
  completed,
  canceled,
}
String translateOrderStatus(String status) {
  switch (status) {
    case 'pending':
      return 'Ожидает';
    case "awaitingConfirmation":
      return 'Ожидает подтверждения';
    case "accepted":
      return 'Принят';
    case "inProgress":
      return 'В процессе';
    case "completed":
      return 'Завершён';
    case "canceled":
      return 'Отменён';
    default:
      return 'Неизвестный статус';
  }
}