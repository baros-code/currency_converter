import 'package:currency_converter/app/utils/date_time_ext.dart';
import 'package:currency_converter/app/utils/locator.dart';
import 'package:currency_converter/core/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_config.dart';
import 'cubit/currency_cubit.dart';
import 'widgets/currency_card.dart';

class HistoricalRatesPage extends StatefulWidget {
  const HistoricalRatesPage({super.key});

  @override
  State<HistoricalRatesPage> createState() => _HistoricalRatesPageState();
}

class _HistoricalRatesPageState extends State<HistoricalRatesPage> {
  late CurrencyCubit _currencyCubit;

  @override
  void initState() {
    super.initState();
    _currencyCubit = context.read<CurrencyCubit>();
    _currencyCubit.onAmountChanged('1');
    _currencyCubit.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppConfig.backgroundPrimary,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppConfig.backgroundPrimary,
          foregroundColor: Colors.white,
          title: Text(
            'Historic rates',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CurrencyCard(
                            value: state.baseCurrency,
                            onCurrencySelected:
                                _currencyCubit.onBaseCurrencyChanged,
                          ),
                          _SwitchButton(
                            onTap: _currencyCubit.onSwitchCurrency,
                          ),
                          CurrencyCard(
                            value: state.targetCurrency,
                            onCurrencySelected:
                                _currencyCubit.onTargetCurrencyChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _SelectDateButton(
                        date: state.selectedPeriod,
                        onPressed: () => _showDatePicker(context),
                      ),
                      const SizedBox(height: 32),
                      _GetRatesButton(
                        onTap: () => _currencyCubit.fetchCurrencies(
                            isHistoricFetch: true),
                      ),
                      const SizedBox(height: 32),
                      _ResultText(_currencyCubit.state),
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selection =
        await locator<PopupManager>().showDatePickerPopup(context);
    if (selection != null) {
      _currencyCubit.onDateSelected(selection);
    }
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText(this.state);

  final CurrencyState state;

  @override
  Widget build(BuildContext context) {
    return state.targetCurrency == null || state.selectedPeriod == null
        ? const SizedBox.shrink()
        : state.isLoading
            ? Text(
                'Loading...',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )
            : state.isHistoricFetch
                ? Text(
                    state.errorMessage ??
                        '1 ${state.baseCurrency} = ${state.convertedAmount} ${state.targetCurrency} on ${state.selectedPeriod?.formatDefault()}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                : const SizedBox.shrink();
  }
}

class _GetRatesButton extends StatelessWidget {
  const _GetRatesButton({
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
          ),
          child: Text(
            'Get rates',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SelectDateButton extends StatelessWidget {
  const _SelectDateButton({this.date, this.onPressed});

  final DateTime? date;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              date?.formatDefault() ?? 'Select date',
              style: TextStyle(color: Colors.black),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 0,
              child: Icon(Icons.arrow_right),
            ),
            Positioned(
              left: 0,
              child: Icon(Icons.arrow_left),
            ),
          ],
        ),
      ),
    );
  }
}
