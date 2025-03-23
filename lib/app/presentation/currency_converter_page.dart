import 'package:currency_converter/app/app_config.dart';
import 'package:flutter/material.dart';

import 'widgets/swap_widget.dart';

class CurrencyConverterPage extends StatelessWidget {
  const CurrencyConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppConfig.backgroundPrimary,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppConfig.backgroundPrimary,
          title: Text(
            'Currency Converter',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwapWidget(),
          ),
        ),
      ),
    );
  }
}
