import 'package:currency_converter/app/app_config.dart';
import 'package:currency_converter/app/presentation/cubit/currency_cubit.dart';
import 'package:currency_converter/app/utils/locator.dart';
import 'package:currency_converter/core/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    super.key,
    required this.value,
    this.onCurrencySelected,
  });

  final String? value;
  final void Function(String)? onCurrencySelected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CurrencyCubit>();
    return GestureDetector(
      onTap: () {
        locator<PopupManager>().showSlidingBottomPopup(
          context,
          heightSnaps: [MediaQuery.of(context).size.height * 0.9],
          Column(
            children: cubit.currencies
                .map(
                  (currency) => _buildCurrencyItem(
                    currency,
                    onCurrencySelected,
                    context,
                  ),
                )
                .toList(),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(value ?? 'Select currency'),
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(
    String currency,
    void Function(String)? onCurrencySelected,
    BuildContext context,
  ) {
    final isSelected = value == currency;
    return ListTile(
      title: Text(
        currency,
        style: TextStyle(
          color: isSelected ? AppConfig.primaryColor : Colors.white,
        ),
      ),
      selected: value == currency,
      onTap: () {
        onCurrencySelected?.call(currency);
        Navigator.of(context).pop();
      },
    );
  }
}
