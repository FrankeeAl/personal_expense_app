import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../widgets/chart.dart';
import '../widgets/transaction_list.dart';
import '../models/transaction.dart';
import '../widgets/new_transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? const CupertinoApp(
            title: 'Personal Expenses',
            theme: CupertinoThemeData(
              primaryColor: Colors.lightGreen,
              primaryContrastingColor: Colors.lightGreenAccent,
            ),
          )
        : MaterialApp(
            title: 'Personal Expenses',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.lightGreen,
              ).copyWith(
                secondary: Colors.lightGreenAccent,
              ),
              textTheme: const TextTheme(
                bodyText1: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                bodyText2: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                subtitle1: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                button: TextStyle(color: Colors.white),
              ),
              fontFamily: 'Quicksand',
              appBarTheme: const AppBarTheme(
                titleTextStyle: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            home: const Homepage(),
          );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  final List<Transaction> _userTransaction = [
    Transaction(
      id: 't1',
      title: 'Shoes',
      amount: 19.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: 'Rice',
      amount: 39.99,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't3',
      title: 'Mens Polo',
      amount: 29.69,
      date: DateTime.now(),
    ),
  ];

  bool _showChart = false;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
  }

  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransaction.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addTransactions(String title, double amount, DateTime chosenDate) {
    final newTransaction = Transaction(
      title: title,
      amount: amount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransaction.add(newTransaction);
    });
  }

  void _startAddingNewTransaction(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30.0),
          ),
        ),
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(_addTransactions),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((transaction) => transaction.id == id);
    });
  }

  List<Widget> _buildLandscapePage(
      MediaQueryData mediaQuery, appBar, txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Switch.adaptive(
            value: _showChart,
            activeColor: Theme.of(context).colorScheme.secondary,
            onChanged: (value) {
              setState(() {
                _showChart = value;
              });
            },
          ),
        ],
      ),
      _showChart
          ? SizedBox(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  .7,
              child: Chart(
                recentTransactions: _recentTransactions,
              ),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitPage(
      MediaQueryData mediaQuery, appBar, txListWidget) {
    return [
      SizedBox(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            .3,
        child: Chart(
          recentTransactions: _recentTransactions,
        ),
      ),
      txListWidget,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final landscape = mediaQuery.orientation == Orientation.landscape;

    final navigationBar = CupertinoNavigationBar(
      middle: const Text('Personal Expenses'),
      trailing: CupertinoButton(
        child: const Icon(CupertinoIcons.add),
        onPressed: () {
          _startAddingNewTransaction(context);
        },
      ),
    );

    final appBar = AppBar(
      title: const Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _startAddingNewTransaction(context);
          },
        ),
      ],
    );

    final chartLabel = SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Text(
              'Weekly Monitoring',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );

    final txListWidget = SizedBox(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          .7,
      child: TransactionList(
        _userTransaction,
        _deleteTransaction,
      ),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            chartLabel,
            if (landscape)
              ..._buildLandscapePage(
                mediaQuery,
                appBar,
                txListWidget,
              ),
            if (!landscape)
              ..._buildPortraitPage(
                mediaQuery,
                appBar,
                txListWidget,
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: navigationBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? const SizedBox()
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      _startAddingNewTransaction(context);
                    },
                  ),
          );
  }
}
