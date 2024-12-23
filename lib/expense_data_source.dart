import 'package:flutter/material.dart';

class ExpenseDataSource extends DataTableSource {
  final List<Map<String, dynamic>> expenses = List.generate(8, (index) => {
    'date': '14/11/2024',
    'reason': 'Walter White',
    'tax': '50%',
    'pay': '₹ 500',
    'amount': '₹ 2500',
  });

  @override
  DataRow getRow(int index) {
    final expense = expenses[index];
    return DataRow(
      cells: [
        DataCell(Text(expense['date'])),
        DataCell(Text(expense['reason'])),
        DataCell(Text(expense['tax'])),
        DataCell(Text(expense['pay'])),
        DataCell(Text(expense['amount'])),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => expenses.length;

  @override
  int get selectedRowCount => 0;
}
