import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_config.dart';
import '../cubit/currency_cubit.dart';
import 'currency_card.dart';

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
                error: state.errorMessage,
                onChanged: _currencyCubit.onAmountChanged,
              ),
              const SizedBox(height: 8),
              SwitchButton(
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
    this.error,
    required this.onChanged,
  });

  final String baseCurrency;
  final String? error;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('From'),
            if (error != null) ...[
              Text(
                error!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CurrencyCard(
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
            CurrencyCard(
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

class SwitchButton extends StatelessWidget {
  const SwitchButton({super.key, required this.onTap});

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
