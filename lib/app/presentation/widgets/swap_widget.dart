import 'package:currency_converter/app/app_config.dart';
import 'package:currency_converter/app/presentation/cubit/currency_cubit.dart';
import 'package:currency_converter/app/utils/locator.dart';
import 'package:currency_converter/core/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapWidget extends StatefulWidget {
  const SwapWidget({
    super.key,
  });

  @override
  State<SwapWidget> createState() => _SwapWidgetState();
}

class _SwapWidgetState extends State<SwapWidget> {
  late CurrencyCubit _currencyCubit;

  @override
  void initState() {
    super.initState();
    _currencyCubit = context.read<CurrencyCubit>();
    _currencyCubit.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BaseField(
                baseCurrency: state.baseCurrency,
                onChanged: _currencyCubit.onSwapInputChanged,
              ),
              const SizedBox(height: 8),
              _SwitchButton(
                onTap: _currencyCubit.onSwitchCurrency,
              ),
              const SizedBox(height: 8),
              _TargetField(
                targetCurrency: state.targetCurrency,
                result: state.convertedAmount,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BaseField extends StatelessWidget {
  const _BaseField({
    required this.baseCurrency,
    required this.onChanged,
  });

  final String baseCurrency;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('From'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CurrencyCard(
              value: baseCurrency,
              onCurrencySelected: (currency) {
                context.read<CurrencyCubit>().onBaseCurrencyChanged(currency);
              },
            ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontSize: 20),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TargetField extends StatelessWidget {
  const _TargetField({
    required this.targetCurrency,
    required this.result,
  });

  final String? targetCurrency;
  final double? result;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CurrencyCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('To'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CurrencyCard(
              value: targetCurrency,
              onCurrencySelected: (currency) {
                cubit.onTargetCurrencyChanged(currency);
              },
            ),
            cubit.state.isLoading
                ? CircularProgressIndicator(
                    color: AppConfig.primaryColor,
                  )
                : Text(
                    result == null || result == 0
                        ? '0'
                        : result?.toStringAsFixed(5) ?? '0',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
          ],
        ),
      ],
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
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

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(thickness: 1),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(Icons.arrow_downward),
          ),
        )
      ],
    );
  }
}
