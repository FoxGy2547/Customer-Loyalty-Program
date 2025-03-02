import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

// หน้า ProductScreen (Shop)
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.productItems.length,
      itemBuilder: (context, index) {
        return ProductItem(
          item: provider.productItems[index],
        );
      },
    );
  }
}

// Widget สำหรับแสดงรายการสินค้า (ซื้อ)
class ProductItem extends StatelessWidget {
  final TransactionItem item;

  const ProductItem({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              item.imagePath ?? 'assets/images/default.png',
              width: 50,
              height: 50,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(fontSize: 16)),
                  Text(
                      'ราคา: ${item.amount} บาท | ได้รับ ${(item.amount / 10).toStringAsFixed(1)} คะแนน',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                double points = item.amount / 10; // คำนวณคะแนนอัตโนมัติ
                provider.addTransaction(
                  TransactionItem(
                    keyID: DateTime.now().millisecondsSinceEpoch,
                    title: 'ซื้อ ${item.title}',
                    amount: item.amount,
                    date: DateTime.now(),
                    points: points, // ใช้ points ที่คำนวณอัตโนมัติ
                    imagePath: item.imagePath,
                  ),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'ซื้อ ${item.title} สำเร็จ! ได้รับ ${points.toStringAsFixed(1)} คะแนน'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 70, left: 16, right: 16),
                    duration: Duration(seconds: 3),
                  ),
                );
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  DefaultTabController.of(context).animateTo(1);
                });
              },
              child: Text('ซื้อ'),
            ),
          ],
        ),
      ),
    );
  }
}

// หน้า RedeemScreen (แลกแต้ม)
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.deepPurple,
            title: Text('แลกคะแนน', style: TextStyle(color: Colors.white)),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'คะแนนที่มีตอนนี้: ${provider.totalPoints.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: provider.redeemItems.length,
                  itemBuilder: (context, index) {
                    return RedeemItem(
                      item: provider.redeemItems[index],
                      parentContext: context,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget สำหรับแสดงรายการแลกแต้ม
class RedeemItem extends StatelessWidget {
  final TransactionItem item;
  final BuildContext parentContext;

  const RedeemItem({
    required this.item,
    required this.parentContext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    double pointsRequired = item.amount; // ใช้คะแนนเท่ากับราคา

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              item.imagePath ?? 'assets/images/default.png',
              width: 50,
              height: 50,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(fontSize: 16)),
                  Text('ใช้คะแนน: ${pointsRequired.toStringAsFixed(1)} คะแนน',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                print(
                    'กดปุ่มแลก: ${item.title}, คะแนนที่มี: ${provider.totalPoints}, ต้องการ: $pointsRequired');
                if (provider.totalPoints >= pointsRequired) {
                  provider.redeemTransaction(
                    TransactionItem(
                      keyID: DateTime.now().millisecondsSinceEpoch,
                      title: 'แลก ${item.title}',
                      amount: 0,
                      date: DateTime.now(),
                      points: -pointsRequired, // ลดคะแนนเท่ากับราคา (เป็นลบ)
                      imagePath: item.imagePath,
                    ),
                  );

                  final tabController =
                      DefaultTabController.maybeOf(parentContext);
                  if (tabController != null) {
                    Navigator.popUntil(parentContext, (route) => route.isFirst);
                    // ไปหน้า History (Tab 2)
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      tabController.animateTo(1);
                    });
                  }
                } else {
                  final tabController =
                      DefaultTabController.maybeOf(parentContext);
                  if (tabController != null) {
                    Navigator.popUntil(parentContext, (route) => route.isFirst);
                    // ไปหน้า Shop (Tab 0)
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      tabController.animateTo(0);
                    });
                  }
                }
              },
              child: Text('แลก'),
            ),
          ],
        ),
      ),
    );
  }
}

// หน้า ProfileScreen (แก้ไขให้มีเมนู)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'โปรไฟล์',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'ชื่อ: Thanatip Meechaiyo\nรหัสนิสิต: 65311361\nอีเมล: thanatipm65@nu.ac.th',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if (result == 'edit') {
                TransactionItem? selectedItem = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('เลือกเพื่อแก้ไข'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.redeemItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(provider.redeemItems[index].title),
                            subtitle: Text(
                                'ราคา: ${provider.redeemItems[index].amount} บาท'), // แสดงแค่ราคา
                            onTap: () {
                              Navigator.pop(
                                  context, provider.redeemItems[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (selectedItem != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScreen(item: selectedItem),
                    ),
                  );
                }
              } else if (result == 'add') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddScreen(),
                  ),
                );
              } else if (result == 'delete') {
                TransactionItem? selectedItem = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('เลือกเพื่อลบ'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.redeemItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(provider.redeemItems[index].title),
                            subtitle: Text(
                                'ราคา: ${provider.redeemItems[index].amount} บาท'), // แสดงแค่ราคา
                            onTap: () {
                              Navigator.pop(
                                  context, provider.redeemItems[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (selectedItem != null) {
                  provider.deleteRedeemItem(selectedItem);
                  provider.deleteProductItem(selectedItem);
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add',
                child: Text('เพิ่ม'),
              ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('แก้ไข'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ลบ'),
              ),
            ],
            child: ElevatedButton(
              onPressed: null,
              child: Text('เพิ่ม/แก้ไข/ลบ เมนูเครื่องดื่ม'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// หน้า AddScreen (สำหรับเพิ่มรายการใหม่)
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มรายการ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: const Text('ชื่อรายการ')),
                controller: titleController,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาป้อนชื่อรายการ';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(label: const Text('ราคา')),
                keyboardType: TextInputType.number,
                controller: priceController,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณาป้อนราคา';
                  try {
                    double price = double.parse(value);
                    if (price < 0) return 'ราคาต้องไม่ติดลบ';
                  } catch (e) {
                    return 'กรุณาป้อนตัวเลข';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider = Provider.of<TransactionProvider>(context,
                        listen: false);
                    double points =
                        double.parse(priceController.text); // คะแนนเท่ากับราคา
                    TransactionItem newItem = TransactionItem(
                      keyID: DateTime.now().millisecondsSinceEpoch,
                      title: titleController.text,
                      amount: double.parse(priceController.text),
                      date: DateTime.now(),
                      points: points, // ใช้ points เท่ากับราคา (บวกสำหรับซื้อ)
                      imagePath: 'assets/images/default.png',
                    );
                    provider.addProductItem(newItem);
                    provider.addRedeemItem(newItem.copyWith(
                        points: -points)); // ใช้คะแนนลบสำหรับการแลก
                    Navigator.pop(context);
                  }
                },
                child: const Text('เพิ่มรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

// หน้า EditScreen (สำหรับแก้ไขรายการ)
class EditScreen extends StatefulWidget {
  final TransactionItem item;

  const EditScreen({required this.item, super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    priceController.text = widget.item.amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('แก้ไขรายการ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: const Text('ชื่อรายการ')),
                autofocus: true,
                controller: titleController,
                validator: (String? value) {
                  if (value!.isEmpty) return "กรุณาป้อนชื่อรายการ";
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(label: const Text('ราคา')),
                keyboardType: TextInputType.number,
                controller: priceController,
                validator: (String? value) {
                  if (value!.isEmpty) return "กรุณาป้อนราคา";
                  try {
                    double price = double.parse(value);
                    if (price < 0) return "ราคาต้องไม่ติดลบ";
                  } catch (e) {
                    return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider = Provider.of<TransactionProvider>(context,
                        listen: false);
                    double points =
                        double.parse(priceController.text); // คะแนนเท่ากับราคา
                    TransactionItem updatedItem = TransactionItem(
                      keyID: widget.item.keyID,
                      title: titleController.text,
                      amount: double.parse(priceController.text),
                      date: widget.item.date,
                      points: points, // ใช้ points เท่ากับราคา (บวกสำหรับซื้อ)
                      imagePath: widget.item.imagePath,
                    );
                    provider.deleteRedeemItem(widget.item); // ลบข้อมูลเก่า
                    provider.deleteProductItem(widget.item); // ลบข้อมูลเก่า
                    provider.addRedeemItem(updatedItem.copyWith(
                        points: -points)); // ใช้คะแนนลบสำหรับการแลก
                    provider.addProductItem(updatedItem); // เพิ่มข้อมูลใหม่
                    Navigator.pop(context);
                  }
                },
                child: const Text('แก้ไขข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

// หน้า CollapsingAppbarWithTabsPage
class CollapsingAppbarWithTabsPage extends StatefulWidget {
  const CollapsingAppbarWithTabsPage({super.key});

  @override
  State<CollapsingAppbarWithTabsPage> createState() =>
      _CollapsingAppbarWithTabsPageState();
}

class _CollapsingAppbarWithTabsPageState
    extends State<CollapsingAppbarWithTabsPage> {
  String? _snackBarMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null && _snackBarMessage == null) {
      setState(() {
        _snackBarMessage = args;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_snackBarMessage != null) {
          // แจ้งเตือนแบบไม่ทับแถบด้านล่าง
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_snackBarMessage!),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(top: 10, left: 16, right: 16),
            ),
          );
          setState(() {
            _snackBarMessage = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: const Text(
                    "Customer Loyalty Program",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/bg.jpg',
                        fit: BoxFit.cover,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/nonorder.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.purple,
                    unselectedLabelColor: Colors.grey,
                    tabs: _tabs,
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    ProductScreen(),
                    MyHomePage(title: 'ประวัติการสั่งซื้อ'),
                    ProfileScreen(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.purple[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<TransactionProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          'คะแนนสะสมที่มี: ${provider.totalPoints.toStringAsFixed(1)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RedeemScreen()),
                        );
                      },
                      child: Text('แลก', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _tabs = [
  Tab(icon: Icon(Icons.shopping_bag_rounded), text: "Shop"),
  Tab(icon: Icon(Icons.history), text: "History"),
  Tab(icon: Icon(Icons.person), text: "Profile"),
];

// ตัวช่วยสำหรับ SliverAppBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Main App
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Customer Loyalty Program',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const CollapsingAppbarWithTabsPage(),
      ),
    );
  }
}

// หน้า MyHomePage (History)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        double totalPoints = provider.totalPoints;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              if (provider.transactions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, int index) {
                      TransactionItem data = provider.transactions[index];
                      return Dismissible(
                        key: Key(data.keyID.toString()),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          provider.deleteTransaction(data);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  data.imagePath ?? 'assets/images/default.png',
                                  width: 50,
                                  height: 50,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data.title,
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                        'วันที่: ${data.date?.toIso8601String().substring(0, 10)} | คะแนน: ${data.points ?? 0}',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
