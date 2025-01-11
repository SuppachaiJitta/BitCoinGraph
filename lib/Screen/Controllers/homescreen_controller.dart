import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Model/btc_model.dart';

class HomeScreenController extends GetxController with StateMixin {
  BitcoinModel bitcoinModel = BitcoinModel();
  Timer? timer;
  RxBool isLoading = false.obs;
  RxDouble thbExchange = 35.0.obs;
  RxList<ChartModel> usdHistory = <ChartModel>[].obs;
  RxDouble calculateToThb = 0.0.obs;
  RxString selectedTimeSpoted = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCallApi();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      getBitcoinData();
      updateUsdHistory();
    });
  }

  getCallApi() async {
    isLoading.value = true;
    await getBitcoinData();
    await getTHBExchange();
    isLoading.value = false;
  }

  double get minPrice => usdHistory.isEmpty
      ? 0
      : usdHistory.map((e) => e.rate).reduce((a, b) => a < b ? a : b);

  double get maxPrice => usdHistory.isEmpty
      ? 0
      : usdHistory.map((e) => e.rate).reduce((a, b) => a > b ? a : b);

  getBitcoinData() async {
    var url = Uri.https('api.coindesk.com', '/v1/bpi/currentprice.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bitcoinModel = BitcoinModel.fromJson(data);
        updateUsdHistory();
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      change(null, status: RxStatus.error('Failed to fetch data: $e'));
    }
  }

  //  ค่าเงินบาทเเบบ realtime
  getTHBExchange() async {
    var url = Uri.https('api.freecurrencyapi.com', '/v1/latest',
        {'apikey': 'fca_live_fIaAogWRExFAjsUmHKtWcQNZF8nQAXekWf9tp4pI'});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        thbExchange.value = double.parse(data['data']['THB'].toString());
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      change(null, status: RxStatus.error('Failed to fetch data: $e'));
    }
  }

  String calculateExchangeToThb() {
    String rateString = bitcoinModel.bpi!.usd.rate.replaceAll(",", "");
    double usdRate = double.parse(rateString);
    calculateToThb.value = usdRate * thbExchange.value;

    final formatter = NumberFormat('#,###.00');

    return formatter.format(calculateToThb.value);
  }

  void updateUsdHistory() {
    if (bitcoinModel.bpi != null && bitcoinModel.time != null) {
      String rateString = bitcoinModel.bpi!.usd.rate.replaceAll(",", "");
      double usdRate = double.parse(rateString);

      DateTime dateTime = DateTime.parse(bitcoinModel.time!.updatedISO);
      String formattedTime = DateFormat("HH:mm:ss").format(dateTime);
      bool timeExists = usdHistory.any((chart) => chart.time == formattedTime);

      if (!timeExists) {
        usdHistory.add(
          ChartModel(
            rate: usdRate,
            time: formattedTime,
          ),
        );
      }
    }
  }

  void updateSelectedTime(String time) {
    selectedTimeSpoted.value = time;
  }

  void resetTime() {
    selectedTimeSpoted.value = '';
  }

  void handleTouchEvent(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlTapDownEvent ||
        event is FlPanStartEvent ||
        event is FlPanUpdateEvent ||
        event is FlLongPressStart ||
        event is FlLongPressMoveUpdate) {
      if (response != null && response.lineBarSpots != null) {
        final touchedSpot = response.lineBarSpots?.firstOrNull;
        if (touchedSpot != null) {
          int index = touchedSpot.x.toInt();
          String time = usdHistory[index].time;
          updateSelectedTime(time);
        }
      }
    } else if (event is FlTapUpEvent ||
        event is FlPanEndEvent ||
        event is FlLongPressEnd ||
        event is FlPointerExitEvent) {
      resetTime();
    }
  }
}
