abstract class PaymentStrategy{
String pay(double amount);
String getMethodName();
}
class CashPaymentStrategy implements PaymentStrategy {
  @override
  String pay(double amount) {
    return "Paid $amount EGP in Cash.";
  }

  @override
  String getMethodName() => "Cash";
}
class CreditCardPaymentStrategy implements PaymentStrategy {
  @override
  String pay(double amount) {
    return "Payment of $amount EGP processed via Credit Card.";
  }

  @override
  String getMethodName() => "Credit Card";
}