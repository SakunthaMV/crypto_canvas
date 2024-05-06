import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey calKey = GlobalKey<FormState>();

  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _riskPercentageController =
      TextEditingController();
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _coinNameController = TextEditingController();

  double _entryPrice = 0.0;
  double _stopLoss = 0.0;
  late double _capital;
  late double _riskPercentage;
  late String _coinName = "NULL";
  late List<String> _history;

  void _loadStoredData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('History') ?? [];
      _capital = prefs.getDouble('Capital') ?? 30.00;
      _riskPercentage = prefs.getDouble('Risk Percentage') ?? 100 / 30;
      _capitalController.text = _capital.toStringAsFixed(2);
      _riskPercentageController.text =
          "${_riskPercentage.toStringAsFixed(2)} %";
    });
  }

  @override
  void initState() {
    _loadStoredData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Center(
          child: Text(
            widget.title,
            style: GoogleFonts.caveat(
              fontSize: 30,
              color: colorScheme.primary,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 6.0,
                  color: colorScheme.primary.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
      ),
      body: Form(
        key: calKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  inputFields(
                    label: 'Entry Price',
                    controller: _entryPriceController,
                  ),
                  inputFields(
                    label: 'Stop Loss',
                    controller: _stopLossController,
                  ),
                  inputFields(
                    label: 'Coin Name',
                    number: false,
                    controller: _coinNameController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: calculateFunction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 30,
                      ),
                    ),
                    child: Text(
                      'Calculate',
                      style: GoogleFonts.neuton(
                        fontSize: 30,
                        letterSpacing: 1.3,
                        color: colorScheme.background,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: colorScheme.background,
                        context: context,
                        builder: (BuildContext context) {
                          return modelSheetData();
                        },
                      );
                    },
                    icon: Icon(
                      size: 30,
                      Icons.settings,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.primary,
              indent: width * 0.05,
              endIndent: width * 0.05,
              thickness: 1,
            ),
            Expanded(
              child: FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    List<String> history =
                        snapshot.data?.getStringList("History") ?? [];
                    return historyList(history);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget historyList(List<String> history) {
    final double width = MediaQuery.of(context).size.width;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
      itemCount: history.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> details = json.decode(_history[index]);
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    detailTile(
                      'Coin Name',
                      details['Coin Name'],
                      size: 20,
                      valueColor: Colors.black,
                    ),
                    detailTile(
                      'Position Type',
                      details['Type'],
                      valueColor:
                          details['Type'] == 'Long' ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Builder(builder: (context) {
                    int decimals =
                        details['Entry Price'].toString().split('.')[1].length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        detailTile(
                          'Entry Price',
                          "${details['Entry Price'].toStringAsFixed(decimals > 2 ? decimals : 2)} \$",
                        ),
                        detailTile(
                          'Stop Loss',
                          "${details['Stop Loss'].toStringAsFixed(decimals > 2 ? decimals : 2)} \$",
                        ),
                        Builder(builder: (context) {
                          int level = details['Type'] == 'Long' ? 3 : 1;
                          return detailTile(
                            'Target Price',
                            "${details['Target Levels'][level].toStringAsFixed(decimals > 2 ? decimals : 2)} \$",
                          );
                        }),
                      ],
                    );
                  }),
                ),
                Builder(builder: (context) {
                  int decimals =
                      details['Entry Price'].toString().split('.')[1].length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      detailTile(
                        'Leverage',
                        "${details['Leverage'].toString()} X",
                      ),
                      Builder(builder: (context) {
                        int coinDecimals =
                            (5 - decimals) > 0 ? 5 - decimals : 0;
                        return detailTile(
                          'Position Size',
                          "${details['Position Size'].toStringAsFixed(coinDecimals)} ${details['Coin Name']}",
                        );
                      }),
                      detailTile(
                        'Margin',
                        "${details['Margin'].toStringAsFixed(2)} \$",
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      detailTile(
                        'Value',
                        "${details['Value'].toStringAsFixed(2)} \$",
                      ),
                      detailTile(
                        'Profit',
                        "${details['Profit'].toStringAsFixed(2)} \$",
                        valueColor: Colors.green,
                      ),
                      detailTile(
                        'Loss',
                        "${details['Loss'].toStringAsFixed(2)} \$",
                        valueColor: Colors.red,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Target Levels",
                      style: GoogleFonts.notoSerifKannada(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        _history = prefs.getStringList('History') ?? [];
                        _history.removeAt(0);
                        prefs.setStringList("History", _history);
                        setState(() {});
                      },
                      icon: Icon(
                        size: 30,
                        Icons.delete,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Builder(builder: (context) {
                    int decimals =
                        details['Entry Price'].toString().split('.')[1].length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return detailTile(
                          "Level ${1.5 * (index + 1)}",
                          "${details['Target Levels'][index].toStringAsFixed(decimals > 2 ? decimals : 2)} \$",
                          size: 15,
                        );
                      }),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget detailTile(
    String hedding,
    String value, {
    double size = 16,
    Color? valueColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          hedding,
          style: GoogleFonts.notoSerifKannada(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            fontSize: size,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSerifKannada(
            fontWeight: FontWeight.bold,
            color: valueColor ?? colorScheme.tertiary,
            fontSize: size * 4 / 5,
          ),
        ),
      ],
    );
  }

  Widget inputFields({
    TextEditingController? controller,
    bool number = true,
    required String label,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double width = MediaQuery.of(context).size.width;
    return Container(
      height: 55,
      width: width * 0.28,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 4,
            spreadRadius: -1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.name,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: colorScheme.primary,
        ),
        cursorColor: colorScheme.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.openSans(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5),
        ),
        onChanged: (text) {
          if (text.isNotEmpty) {
            setState(() {
              switch (label) {
                case 'Entry Price':
                  _entryPrice = double.parse(text);
                  break;
                case 'Stop Loss':
                  _stopLoss = double.parse(text);
                  break;
                case 'Capital':
                  _capital = double.parse(text);
                  break;
                case 'Risk %':
                  _riskPercentage = double.parse(text.split(' ').first);
                  break;
                case 'Coin Name':
                  _coinName = text.toUpperCase();
              }
            });
          }
        },
      ),
    );
  }

  Widget modelSheetData() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom > 20
            ? MediaQuery.of(context).viewInsets.bottom + 20
            : 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          inputFields(label: 'Capital', controller: _capitalController),
          inputFields(label: 'Risk %', controller: _riskPercentageController),
          IconButton(
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setDouble('Capital', _capital);
              prefs.setDouble('Risk Percentage', _riskPercentage);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.done,
              color: colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  void calculateFunction() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    Map<String, dynamic> details = {};

    if (_entryPrice > 0.0 && _stopLoss > 0.0 && _coinName != "NULL") {
      String type = _entryPrice > _stopLoss ? "Long" : "Short";
      int leverage = 0;
      double size =
          _capital * _riskPercentage / 100 / (_entryPrice - _stopLoss).abs();
      double value = size * _entryPrice;
      double diff = 100.0;
      for (int lev = 5; lev < 30; lev++) {
        for (int margin = 100 * (_capital * 0.05).toInt();
            margin < 100 * (_capital * 0.15).toInt();
            margin++) {
          if (value / (margin / 100) < lev) {
            if (diff > (margin / 100) * lev - value) {
              diff = (margin / 100) * lev - value;
              leverage = lev;
            }
          }
        }
      }
      List<double> tpLevels = List.generate(
          4,
          (index) => type == "Long"
              ? _entryPrice +
                  _capital * _riskPercentage * 1.5 * (index + 1) / (100 * size)
              : _entryPrice -
                  _capital *
                      _riskPercentage *
                      1.5 *
                      (index + 1) /
                      (100 * size));
      details.addAll({
        "Entry Price": _entryPrice,
        "Stop Loss": _stopLoss,
        "Coin Name": _coinName,
        "Type": type,
        "Leverage": leverage,
        "Position Size": size,
        "Value": value,
        "Target Levels": tpLevels,
        "Margin": value / leverage,
        "Profit": type == "Long"
            ? (tpLevels[3] - _entryPrice) * size
            : (_entryPrice - tpLevels[1]) * size,
        "Loss": _capital * _riskPercentage / 100,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String encodedMap = json.encode(details);
      _history = prefs.getStringList('History') ?? [];
      _history.insert(0, encodedMap);
      prefs.setStringList("History", _history);
      setState(() {
        _entryPriceController.text = '';
        _stopLossController.text = '';
        _coinNameController.text = '';
        _entryPrice = 0.0;
        _stopLoss = 0.0;
        _coinName = 'NULL';
      });
      // ignore: use_build_context_synchronously
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.background,
          content: Center(
            child: Text(
              'Enter Valid Prices and Coin Name',
              style: GoogleFonts.robotoSlab(
                color: colorScheme.error,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }
  }
}
