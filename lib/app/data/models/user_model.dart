class AccountModel {
  final int id;
  final String accountNumber;
  final double balance;
  final String currency;
  final String bankName;
  final DateTime? createdAt;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.balance,
    required this.currency,
    required this.bankName,
    this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      accountNumber: json['accountNumber'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'NGN',
      bankName: json['bankName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'bankName': bankName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class TransactionModel {
  final int id;
  final String receiverName;
  final String bankName;
  final String bankAccount;
  final String accountNumber;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime transactionDate;
  final String status;
  final String transactionType;
  final String reference;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.receiverName,
    required this.bankName,
    required this.bankAccount,
    required this.accountNumber,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.transactionDate,
    required this.status,
    required this.transactionType,
    required this.reference,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      bankName: json['bankName'] ?? '',
      bankAccount: json['bankAccount'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : DateTime.now(),
      status: json['status'] ?? '',
      transactionType: json['transactionType'] ?? '',
      reference: json['reference'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverName': receiverName,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'accountNumber': accountNumber,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'transactionDate': transactionDate.toIso8601String(),
      'status': status,
      'transactionType': transactionType,
      'reference': reference,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isCredit => transactionType.toLowerCase() == 'credit';
}

class UserModel {
  final int id;
  final String customerName;
  final String phoneNumber;
  final String accountNumber;
  final String bankName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalBalance;
  final int totalAccounts;
  final int totalTransactions;
  final int totalBillPayments;
  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final List<dynamic> billPayments;
  final List<dynamic> beneficiaries;

  UserModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.accountNumber,
    required this.bankName,
    this.createdAt,
    this.updatedAt,
    required this.totalBalance,
    required this.totalAccounts,
    required this.totalTransactions,
    required this.totalBillPayments,
    required this.accounts,
    required this.transactions,
    required this.billPayments,
    required this.beneficiaries,
  });

  String get fullName => customerName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      totalAccounts: json['totalAccounts'] ?? 0,
      totalTransactions: json['totalTransactions'] ?? 0,
      totalBillPayments: json['totalBillPayments'] ?? 0,
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      billPayments: json['billPayments'] ?? [],
      beneficiaries: json['beneficiaries'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'totalBalance': totalBalance,
      'totalAccounts': totalAccounts,
      'totalTransactions': totalTransactions,
      'totalBillPayments': totalBillPayments,
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'billPayments': billPayments,
      'beneficiaries': beneficiaries,
    };
  }
}

