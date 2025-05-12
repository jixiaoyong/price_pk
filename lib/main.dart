import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:price_pk/price_input_box_logic.dart';

import 'widgets/goods_card.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.activeBlue,
        ),
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
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: logic.tabs.length,
        vsync: this,
        initialIndex: logic.currentTabIndex);
    _tabController.addListener(() {
      logic.currentTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                )),
        actions: [
          TextButton(
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("删除此分类所有数据？"),
                      content: Text(
                        '确定要删除当前页面的所有数据吗？\n此操作无法撤销。',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel
                              .resolveFrom(context),
                        ),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text("取消",
                              style: TextStyle(
                                  color: CupertinoColors.secondaryLabel)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: const Text("删除"),
                          onPressed: () {
                            logic.cleanAll();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.systemRed,
                    size: 24,
                  ),
                  Text(
                    "删除",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              )),
          TextButton(
              onPressed: () {
                logic.sort();
              },
              child: Column(
                children: [
                  const Icon(Icons.sort),
                  Text(
                    "排序",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              )),
          TextButton(
              onPressed: () {
                logic.share();
              },
              child: Column(
                children: [
                  const Icon(Icons.share),
                  Text(
                    "分享",
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
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollController,
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
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              },
                              child: const Text("添加商品")),
                        ],
                      );
                    }
                    var goods = goodsList[index];
                    var isHighlight =
                        goods.prePrice.value == tabValue.minPrePrice.value &&
                            0 != goods.prePrice.value &&
                            double.maxFinite != goods.prePrice.value;
                    return GoodsCard(
                      key: ValueKey(goods.id),
                      data: goods,
                      unitList: units,
                      isHighlight: isHighlight,
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
