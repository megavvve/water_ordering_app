enum UserType {
  user,
  deliverer,
}
String translateUserType(String type) {
  switch (type) {
    case 'user':
      return 'Пользователь';
    case "deliverer":
      return 'Доставщик';
    
    default:
      return 'Неизвестный статус';
  }
}