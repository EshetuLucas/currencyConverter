import 'package:currency_exchange/controller/check_internet_connection.dart';
import 'package:currency_exchange/controller/currency_controller.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:io';
import 'package:currency_exchange/model/currency_model.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currencyController = CurrencyController.to;
  final amountController = new TextEditingController();
  final toController = new TextEditingController();
  String toSymbol;
  Dio dio = new Dio();
  CheckInternet checkInternet = new CheckInternet();
  var apiBody;
  List<CurrencyModel> listOfrates = new List();
  TextStyle textStyl(Color color) {
    return TextStyle(
      letterSpacing: 1.4,
      color: color,
      fontWeight: FontWeight.w400,
      fontFamily: "RaleWay",
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSymbols();
  }

  searchSymbols() {
    currencyController.listOfSearch.clear();
    currencyController.listOfSearchKeys.clear();
    currencyController.symbols.forEach((key, value) {
      if (key
              .toLowerCase()
              .contains(currencyController.symbol.value.toLowerCase()) ||
          value
              .toLowerCase()
              .contains(currencyController.symbol.value.toLowerCase())) {
        currencyController.setListOfSearch(value);
        currencyController.setListOfKeySearch(key);
      }
    });
  }

  fetchSymbols() async {
    try {
      await http.get(
        "http://data.fixer.io/api/symbols?access_key=0c5879512e68f3cf6556f96a2990aec6",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).then((value) async {
        if (value.statusCode == 200) {
          Map<String, dynamic> apiResponse = json.decode(value.body);
          currencyController.setSymbols(apiResponse['symbols']);
        } else
          toastMessage("Something went wrong");
      });
    } on SocketException {
      toastMessage("Something went wrong");
    } on HttpException {
      toastMessage("Something went wrong");
    } on FormatException {
      toastMessage("Something went wrong");
    } on TimeoutException {
      toastMessage("Something went wrong");
    } catch (e) {
      toastMessage("Something went wrong");
    }
  }

  fetchCurrency() async {
    try {
      await http.get(
        "http://data.fixer.io/api/latest?access_key=0c5879512e68f3cf6556f96a2990aec6&base=EUR&symbols=${currencyController.toCurrecySymbol.value}",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).then((value) async {
        if (value.statusCode == 200) {
          Map<String, dynamic> apiResponse = json.decode(value.body);
          currencyController.setRates(apiResponse['rates']);
          currencyController.setIsConverted(true);
          currencyController.setIsLoading(false);
        } else
          toastMessage("Something went wrong");
      });
    } on SocketException {
      toastMessage("Something went wrong");
    } on HttpException {
      toastMessage("Something went wrong");
    } on FormatException {
      toastMessage("Something went wrong");
    } on TimeoutException {
      toastMessage("Something went wrong");
    } catch (e) {
      toastMessage("Something went wrong");
    }
  }

  toastMessage(String title) {
    return Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white12,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  onConvert() async {
    await checkInternet.getInternet().then((value) async {
      if (value) {
        fetchCurrency();
      } else {
        toastMessage("No interent connection");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141c35),
      appBar: AppBar(
        backgroundColor: Color(0xFF141c35),
        elevation: 0,
        title: Center(child: Text("Currency Converter")),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  color: Color(0xFF35a8cd),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 250,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "EUR",
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.4,
                                    fontFamily: "RaleWay",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Card(
                              elevation: 15,
                              // color: Colors.white.withOpacity(0.8),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(2, 4, 2, 2),
                                child: Obx(
                                  () => TextField(
                                    controller: amountController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    onChanged: (value) {
                                      currencyController.setamount(
                                          double.parse(value.toString()));
                                      currencyController.setAmountChecker(true);
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      errorStyle:
                                          textStyl(Colors.red.withOpacity(0.7)),
                                      errorText: !currencyController
                                              .amountChecker.value
                                          ? "This field can't be empty"
                                          : null,
                                      labelStyle: textStyl(
                                        Color(0xFF141c35),
                                      ),
                                      labelText: 'Amount'.toString(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 2),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "To",
                                    style: TextStyle(
                                        letterSpacing: 1.4,
                                        color: Colors.white,
                                        // fontSize: 16,

                                        fontFamily: "RaleWay",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(2, 4, 2, 0),
                                      child: Obx(
                                        () => TextField(
                                          controller: toController,
                                          onChanged: (value) {
                                            currencyController
                                                .setToCurrencySymbol(value);
                                            currencyController
                                                .setTochecker(true);

                                            searchSymbols();
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            errorStyle: textStyl(
                                                Colors.red.withOpacity(0.7)),
                                            errorText: !currencyController
                                                    .toChecker.value
                                                ? "This field can't be empty"
                                                : null,
                                            labelStyle: textStyl(
                                              Colors.white,
                                            ),
                                            labelText: ''.toString(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Obx(
                            () => Container(
                              child: currencyController.isConverted.value
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RichText(
                                            text: TextSpan(
                                                text: "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontFamily: "RaleWay",
                                                    fontWeight:
                                                        FontWeight.w700),
                                                children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    "${(currencyController.amount.value * currencyController.rates['${currencyController.toCurrecySymbol.value}']).toStringAsFixed(2)}  ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontFamily: "RaleWay",
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${currencyController.toCurrecySymbol.value}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontFamily: "RaleWay",
                                                ),
                                              )
                                            ])),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: GestureDetector(
                                onTap: () {
                                  if (currencyController.amount.value == 0) {
                                    currencyController.setAmountChecker(false);
                                  }
                                  if (currencyController
                                          .toCurrecySymbol.value ==
                                      "") {
                                    currencyController.toChecker(false);
                                  }
                                  if (currencyController.amount.value != 0 &&
                                      currencyController
                                              .toCurrecySymbol.value !=
                                          "") {
                                    currencyController.setIsLoading(true);

                                    onConvert();
                                  }
                                },
                                child: Card(
                                  elevation: 30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: !currencyController.isLoading.value
                                          ? Text(
                                              "Convert",
                                              style: TextStyle(
                                                letterSpacing: 1.4,
                                                color: Colors.white,
                                                // fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "RaleWay",
                                              ),
                                            )
                                          : Text(
                                              "Converting...",
                                              style: TextStyle(
                                                letterSpacing: 1.4,
                                                color: Colors.white,
                                                // fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "RaleWay",
                                              ),
                                            ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF141c35),
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => Padding(
                    padding: EdgeInsets.only(left: 10, top: 0, right: 10),
                    child: currencyController.symbol.value != ""
                        ? Container(
                            decoration: BoxDecoration(
                              // color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            child: Obx(
                              () => ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    currencyController.listOfSearch.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      currencyController
                                          .setToCurrencySymbolCoverted(
                                              currencyController
                                                  .listOfSearchKeys[index]
                                                  .toString());

                                      currencyController.setToValue(
                                          currencyController
                                              .listOfSearch[index]);
                                      currencyController.symbol.value = "";
                                      toController.text =
                                          currencyController.toValue.value;
                                      if (currencyController
                                          .isConverted.value) {
                                        currencyController
                                            .setIsConverted(false);
                                        currencyController.setIsLoading(true);
                                        onConvert();
                                      }
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(12, 16, 8, 10),
                                        child: Text(
                                          currencyController
                                              .listOfSearch[index],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ))
                        : Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
