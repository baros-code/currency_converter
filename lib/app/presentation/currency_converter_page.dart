import 'package:currency_converter/app/app_config.dart';
import 'package:currency_converter/app/utils/app_router.dart';
import 'package:flutter/material.dart';

import 'widgets/swap_widget.dart';

class CurrencyConverterPage extends StatelessWidget {
  const CurrencyConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppConfig.backgroundPrimary,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppConfig.backgroundPrimary,
            title: Text(
              'Currency Converter',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  SwapWidget(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.historicalRatesPage,
                        );
                      },
                      child: Text(
                        'Do you want to see historical rates?',
                        style: TextStyle(color: AppConfig.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
