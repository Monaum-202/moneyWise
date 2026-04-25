import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_summary.freezed.dart';
part 'loan_summary.g.dart';

@freezed
class LoanSummary with _$LoanSummary {
  const factory LoanSummary({
    required double totalGave,
    required double totalTook,
    required double totalOverdue,
    required int overdueCount,
  }) = _LoanSummary;

  factory LoanSummary.fromJson(Map<String, dynamic> json) => _$LoanSummaryFromJson(json);
}
