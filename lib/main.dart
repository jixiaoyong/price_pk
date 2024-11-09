import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_pk/price_input_box_logic.dart';

import 'goods_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '性价比大PK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '性价比大PK'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final PriceInputBoxLogic logic = Get.put(PriceInputBoxLogic());

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: logic.tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
              onPressed: () {},
              child: Column(
                children: [
                  const Icon(Icons.sort),
                  Text(
                    "排序",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ))
        ],
        bottom: TabBar(
            controller: _tabController,
            tabs: logic.tabs.map((e) => Tab(text: e.name)).toList()),
      ),
      body: Obx(
        () {
          return TabBarView(
              controller: _tabController,
              children: logic.tabs.map((tabValue) {
                var goodsList = tabValue.goods;
                final units = tabValue.units;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index >= goodsList.length) {
                      return Column(
                        children: [
                          TextButton(
                              onPressed: () {
                                goodsList.add(InputBoxState(
                                    unit: tabValue.defaultUnit,
                                    name: "商品${goodsList.length + 1}"));
                                tabValue.goods = goodsList;
                              },
                              child: const Text("添加商品")),
                        ],
                      );
                    }
                    var goods = goodsList[index];
                    return GoodsCard(
                      data: goods,
                      unitList: units,
                      defaultUnitString: "g",
                      onChange: (InputBoxState state) {
                        goodsList[index] = state;
                        tabValue.goods = goodsList;
                      },
                      onDelete: () {
                        goodsList.removeAt(index);
                        tabValue.goods = goodsList;
                      },
                      fromString: tabValue.fromString,
                    );
                  },
                  itemCount: goodsList.length + 1,
                );
              }).toList());
        },
      ),
    );
  }
}
