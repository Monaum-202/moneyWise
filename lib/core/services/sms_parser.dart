import '../../shared/enums/transaction_type.dart';

class ParsedSmsTransaction {
  ParsedSmsTransaction({
    required this.amount,
    required this.type,
    required this.bankName,
    required this.rawSms,
    required this.receivedAt,
    this.balance,
    this.reference,
    this.counterParty,
  });

  final double amount;
  final TransactionType type;
  final String bankName;
  final String? balance;
  final String? reference;
  final String? counterParty;
  final String rawSms;
  final DateTime receivedAt;
}

class SmsParser {
  static ParsedSmsTransaction? parse(String sms, String sender, {DateTime? date}) {
    final now = date ?? DateTime.now();
    final lowerSms = sms.toLowerCase();
    final lowerSender = sender.toLowerCase();

    // 1. bKash (sender contains bKash or 16247)
    if (lowerSender.contains('bkash') || lowerSender.contains('16247')) {
      return _parseBKash(sms, lowerSms, 'bKash', now);
    }

    // 2. Nagad (sender contains Nagad or 16167)
    if (lowerSender.contains('nagad') || lowerSender.contains('16167')) {
      return _parseNagad(sms, lowerSms, 'Nagad', now);
    }

    // 3. Dutch-Bangla Bank (sender contains DBBL or Dutch)
    if (lowerSender.contains('dbbl') || lowerSender.contains('dutch')) {
      return _parseDBBL(sms, lowerSms, 'DBBL', now);
    }

    // 4. Rocket (sender contains Rocket)
    if (lowerSender.contains('rocket')) {
      return _parseBKash(sms, lowerSms, 'Rocket', now); // Rocket uses same patterns as bKash
    }

    // 5. Islami Bank (sender contains IBBL or Islami)
    if (lowerSender.contains('ibbl') || lowerSender.contains('islami')) {
      return _parseIBBL(sms, lowerSms, 'Islami Bank', now);
    }

    // 6. Upay (sender contains Upay)
    if (lowerSender.contains('upay')) {
      return _parseUpay(sms, lowerSms, 'Upay', now);
    }

    return null;
  }

  static ParsedSmsTransaction? _parseBKash(String sms, String lowerSms, String bankName, DateTime now) {
    final amountMatch = RegExp(r'Tk\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
    
    var type = TransactionType.expense;
    if (lowerSms.contains('received') || lowerSms.contains('cash in')) {
      type = TransactionType.income;
    } else if (lowerSms.contains('sent') || lowerSms.contains('payment') || lowerSms.contains('cash out') || lowerSms.contains('paid')) {
      type = TransactionType.expense;
    }

    final balanceMatch = RegExp(r'Balance\s+Tk\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    final trxIdMatch = RegExp(r'TrxID\s+([A-Z0-9]+)', caseSensitive: false).firstMatch(sms);

    return ParsedSmsTransaction(
      amount: amount,
      type: type,
      bankName: bankName,
      balance: balanceMatch?.group(1)?.replaceAll(',', ''),
      reference: trxIdMatch?.group(1),
      rawSms: sms,
      receivedAt: now,
    );
  }

  static ParsedSmsTransaction? _parseNagad(String sms, String lowerSms, String bankName, DateTime now) {
    final amountMatch = RegExp(r'(?:BDT|Tk|৳)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));

    var type = TransactionType.expense;
    if (lowerSms.contains('credit') || lowerSms.contains('received') || lowerSms.contains('পেয়েছেন')) {
      type = TransactionType.income;
    } else if (lowerSms.contains('debit') || lowerSms.contains('sent') || lowerSms.contains('পাঠানো')) {
      type = TransactionType.expense;
    }

    final balanceMatch = RegExp(r'Balance:\s+(?:BDT|Tk|৳)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    final txnIdMatch = RegExp(r'TxnID:\s*([A-Z0-9]+)', caseSensitive: false).firstMatch(sms);

    return ParsedSmsTransaction(
      amount: amount,
      type: type,
      bankName: bankName,
      balance: balanceMatch?.group(1)?.replaceAll(',', ''),
      reference: txnIdMatch?.group(1),
      rawSms: sms,
      receivedAt: now,
    );
  }

  static ParsedSmsTransaction? _parseDBBL(String sms, String lowerSms, String bankName, DateTime now) {
    final amountMatch = RegExp(r'(?:debited|credited)\s+BDT\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
    final type = lowerSms.contains('credited') ? TransactionType.income : TransactionType.expense;

    final balanceMatch = RegExp(r'Avail Bal\s+BDT\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);

    return ParsedSmsTransaction(
      amount: amount,
      type: type,
      bankName: bankName,
      balance: balanceMatch?.group(1)?.replaceAll(',', ''),
      rawSms: sms,
      receivedAt: now,
    );
  }

  static ParsedSmsTransaction? _parseIBBL(String sms, String lowerSms, String bankName, DateTime now) {
    final amountMatch = RegExp(r'BDT\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
    final type = lowerSms.contains('credited') ? TransactionType.income : TransactionType.expense;

    final balanceMatch = RegExp(r'Avail Bal\s+BDT\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);

    return ParsedSmsTransaction(
      amount: amount,
      type: type,
      bankName: bankName,
      balance: balanceMatch?.group(1)?.replaceAll(',', ''),
      rawSms: sms,
      receivedAt: now,
    );
  }

  static ParsedSmsTransaction? _parseUpay(String sms, String lowerSms, String bankName, DateTime now) {
    final amountMatch = RegExp(r'(?:BDT|Tk)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);
    if (amountMatch == null) return null;

    final amount = double.parse(amountMatch.group(1)!.replaceAll(',', ''));
    var type = TransactionType.expense;
    if (lowerSms.contains('received') || lowerSms.contains('cash in')) {
      type = TransactionType.income;
    }

    final balanceMatch = RegExp(r'Balance\s*(?:BDT|Tk)\s*([\d,]+(?:\.\d{2})?)', caseSensitive: false).firstMatch(sms);

    return ParsedSmsTransaction(
      amount: amount,
      type: type,
      bankName: bankName,
      balance: balanceMatch?.group(1)?.replaceAll(',', ''),
      rawSms: sms,
      receivedAt: now,
    );
  }
}
