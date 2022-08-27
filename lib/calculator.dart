import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'widgets.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:tele_web_app/tele_web_app.dart';
import 'package:intl/intl.dart';

String? init_value;
const int FIXED_DIGITS = 6; // round up to 6 places after dot

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  CalAppState createState() {
    return CalAppState();
  }
}

class CalAppState extends State<MyApp> {
  String _input = '';
  String _result = '0';
  String _expression = '';
  List<String> _history = [];
  static var tele;

  @override
  Widget build(BuildContext context) {
    if (init_value == null) {
      init_value = Uri.base.queryParameters["value"] ?? '';
      if (init_value!.isNotEmpty) {
        _result = init_value!;
      }
    }

    initTelegramObject();
    tele.mainButton.setParams(
      text: "Send history to bot, last value: $_result",
      //color: '#$rgb',
      isVisible: true,
    );
    tele.mainButton.show();
    tele.mainButton.enable();
    tele.mainButton.onClick(() {
      tele.sendData(_history.join('\n'));
    });

    return _makeHomePage(_input == '' ? _result : _input, _history);
  }

  static void initTelegramObject() {
    if (tele != null) {
      return;
    }
    tele = TeleWebApp();
    //tele.mainButton.show();
    //tele.mainButton.enable();
    tele.expand();
    tele.ready();
  }

  void clearValue(String text) {
    setState(() {
      _input = '';
      _result = '0';
      _expression = '';
    });
  }

  void clearHistory(String text) {
    setState(() {
      _history.clear();
    });
  }

  bool _isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

  void math(String text) {
    if (_expression.isNotEmpty &&
        _input.isEmpty &&
        (!_isDigit(_expression, _expression.length - 1))) {
      return;
    }

    if (_expression.isNotEmpty && _input.isNotEmpty) {
      eval('');
    }

    setState(() {
      _expression = (_input == '' ? _result : _input) + text;
      _result = '0';
      _input = '';
    });
  }

  void eval(String text) {
    String tmpExpr = _expression + _input;
    Parser p = Parser();
    Expression exp = p.parse(tmpExpr);
    ContextModel cm = ContextModel();

    setState(() {
      // round up to 6 digits after dot
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      if (eval == double.infinity) {
        eval = 0;
      }
      _result = num.tryParse(eval.toStringAsFixed(FIXED_DIGITS)).toString();
      if (_result.indexOf('e') > 0) {
        _result = '0';
      }
      _history.insert(0, tmpExpr + '=' + _result);
      _input = '';
      _expression = '';
    });
  }

  void digitPressed(String text) {
    setState(() => _input += text);
  }

  void inputInserted(String text) {
    setState(() => _input += text);
  }

  void inputOverwrite(String text) {
    setState(() => _input = text);
  }

  void pointPressed(String text) {
    setState(() {
      if (_input == '') {
        _input = '0.';
      } else if (!_input.contains('.')) {
        _input += '.';
      }
    });
  }

  Widget _historyList(List<String> _history) {

    //extract number after '='
    List<String> entries = _history.map((x) {
      var lst = x.split('=');
      return lst[lst.length - 1];
    }).toList();

    return ListView.builder(
        //padding: const EdgeInsets.only(top: 8.0),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(top: 4),
            child: Center(
                child: Column(
                    children: <Widget>[
                  Container(
                    height: CalcStyle.histButtonFontSize,
                    child: fittedTextBox(
                        _history[index], CalcStyle.histButtonFontSize),
                  ),
                  Container(
                    height: CalcStyle.histButtonFontSize,
                    child: buttonGradient(entries[index], inputOverwrite,
                        fontSize: CalcStyle.histButtonFontSize),
                  ),
                ])),
          );
        });
  }

  Widget _makeHomePage(String _display, List<String> _history) {
    return MaterialApp(
        title: 'Accounting Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          //primaryColor: Colors.lightBlue[800], - we use primarySwatch instead
          fontFamily: 'Georgia',
        ),
        home: Scaffold(
            body: Container(
                margin:
                    const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
                color: Colors.white,
                child: SafeArea(
                    child: LayoutGrid(
                        areas: '''
              expr    expr    expr    expr     expr
              display display display display  display
              CE      CH   empty   empty    history
              seven   eight   nine    divide   history
              four    five    six     multiply history
              one     two     three   minus    history
              zero    point   equals  plus     history
              ''',
                        columnSizes: [1.fr, 1.fr, 1.fr, 1.fr, 2.fr],
                        rowSizes: [1.fr, 2.fr, 2.fr, 2.fr, 2.fr, 2.fr, 2.fr],
                        rowGap: 4.0,
                        columnGap: 4.0,
                        children: [
                          _historyList(_history).inGridArea('history'),
                          fittedTextBox(
                                  _expression, CalcStyle.expressionFontSize)
                              .inGridArea('expr'),
                          fittedTextBox(
                                  NumberFormat.decimalPattern('en_us')
                                      .format(double.parse(_display)),
                                  CalcStyle.displayFontSize)
                              .inGridArea('display'),
                          buttonGradient('CE', clearValue).inGridArea('CE'),
                          buttonGradient('CH', clearHistory).inGridArea('CH'),
                          buttonGradient('.', pointPressed).inGridArea('point'),
                          buttonGradient('0', digitPressed).inGridArea('zero'),
                          buttonGradient('1', digitPressed).inGridArea('one'),
                          buttonGradient('2', digitPressed).inGridArea('two'),
                          buttonGradient('3', digitPressed).inGridArea('three'),
                          buttonGradient('4', digitPressed).inGridArea('four'),
                          buttonGradient('5', digitPressed).inGridArea('five'),
                          buttonGradient('6', digitPressed).inGridArea('six'),
                          buttonGradient('7', digitPressed).inGridArea('seven'),
                          buttonGradient('8', digitPressed).inGridArea('eight'),
                          buttonGradient('9', digitPressed).inGridArea('nine'),
                          buttonGradient('=', eval).inGridArea('equals'),
                          buttonGradient('/', math).inGridArea('divide'),
                          buttonGradient('*', math).inGridArea('multiply'),
                          buttonGradient('-', math).inGridArea('minus'),
                          buttonGradient('+', math).inGridArea('plus'),
                        ])))));
  }
}

