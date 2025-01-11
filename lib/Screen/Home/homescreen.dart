import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controllers/homescreen_controller.dart';
import 'components/Chart.dart';
import 'components/custom_textrow.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeScreenController controller = Get.put(HomeScreenController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin Price'),
        backgroundColor: Colors.green,
      ),
      body: Obx(
        () => Container(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 12.0,
                                ),
                                child: GraphChart(
                                  data: controller.usdHistory,
                                  minY: controller.minPrice,
                                  maxY: controller.maxPrice,
                                  touchCallback: (event, response) {
                                    controller.handleTouchEvent(
                                        event, response);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06,
                              child: Column(
                                children: [
                                  const Text('Time Spoted'),
                                  SizedBox(
                                    child: controller
                                            .selectedTimeSpoted.value.isNotEmpty
                                        ? Text(
                                            controller.selectedTimeSpoted.value,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                            CustomRow(
                              title: 'USD',
                              price: '${controller.bitcoinModel.bpi?.usd.rate}',
                            ),
                            CustomRow(
                              title: 'GBP',
                              price: '${controller.bitcoinModel.bpi?.gbp.rate}',
                            ),
                            CustomRow(
                              title: 'EUR',
                              price:
                                  ' ${controller.bitcoinModel.bpi?.eur.rate}',
                            ),
                            Text(
                              'ExChange Rate to THB : ${controller.calculateExchangeToThb()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Text(
                          'Price Updated at: ${controller.bitcoinModel.time?.updated}'),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
