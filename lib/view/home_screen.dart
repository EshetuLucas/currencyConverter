import 'package:currency_exchange/controller/check_internet_connection.dart';
import 'package:currency_exchange/controller/currency_controller.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currencyController = CurrencyController.to;
  final amountController = new TextEditingController();
  final toController = new TextEditingController();

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
    getSymbols();
  }

  getSymbols() async {
    await SharedPreferences.getInstance().then((value) {
      if (value.getStringList("symbols") != null) {
        value.getStringList("symbols").forEach((value) {
          currencyController.setListOfSymbolsForDropDown(value);
        });
        value.getStringList('values').forEach((value) {
          currencyController.setListofSymbolsValue(value);
        });
      } else {
        currencyController.setOnApiError(true);
        onSybolFetch();
      }
    });
  }

  BuildContext dialogcontext;
  onSearch() {
    currencyController.setIsLoading(false);
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogcontext = context;

          return GestureDetector(
            onTap: () {
              Navigator.pop(dialogcontext);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: new AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.all(Radius.circular(20))),
                  backgroundColor: Color(0xFF141c35),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          height: 45,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(2, 4, 2, 0),
                            child: Obx(
                              () => TextField(
                                autofocus: true,
                                controller: toController,
                                onChanged: (value) {
                                  currencyController.setToCurrencySymbol(value);
                                  currencyController.setTochecker(true);

                                  searchSymbols();
                                },
                                style: textStyl(Colors.white),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  errorStyle:
                                      textStyl(Colors.red.withOpacity(0.7)),
                                  errorText: !currencyController.toChecker.value
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
                        SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          child: Obx(
                            () => Padding(
                              padding:
                                  EdgeInsets.only(left: 10, top: 0, right: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    currencyController.listOfSearch.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      currencyController
                                          .setToCurrencySymbolCoverted(
                                              currencyController
                                                  .listOfSearch[index]
                                                  .toString()
                                                  .substring(0, 3));
                                      currencyController.setIsConverted(false);
                                      Navigator.pop(dialogcontext);
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 16, 8, 10),
                                        child: Text(
                                          currencyController
                                              .listOfSearch[index],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  onApiLoadDialog() {
    currencyController.setIsLoading(false);
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogcontext = context;

          return GestureDetector(
            onTap: () {
              Navigator.pop(dialogcontext);
            },
            child: Container(
              color: Colors.transparent,
              child: new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(Radius.circular(20))),
                backgroundColor: Color(0xFF141c35),
                content: Container(
                  height: 50,
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Container(
                          height: 80,
                          child: currencyController.onApiError.value
                              ? SpinKitCircle(
                                  color: Colors.white,
                                  size: 30,
                                  duration: Duration(seconds: 1),
                                )
                              : Container(),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Obx(
                        () => Text(
                          currencyController.onApiError.value
                              ? "Fetching Data"
                              : "",
                          style: TextStyle(
                            letterSpacing: 1.4,
                            color: Colors.white,
                            //fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: "RaleWay",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  onErrorMessage() {
    currencyController.setIsLoading(false);
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogcontext = context;

          return Container(
            height: 300,
            child: new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.all(Radius.circular(20))),
              backgroundColor: Color(0xFF141c35),
              title: new Text(
                "Error",
                style: TextStyle(color: Colors.white),
              ),
              content: setupAlertDialoadContainer(
                  "${currencyController.errorMessage.value}\nPlease try again!"),
              actions: <Widget>[
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(dialogcontext);
                    },
                    child: Container(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          "Ok",
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
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget setupAlertDialoadContainer(String text) {
    return Container(
      width: 300.0,
      child: ListTile(
        title: Obx(
          () => Text(text,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.4,
                fontFamily: "RaleWay",
                fontSize: 16,
              )),
        ),
      ),
    );
  }

  onError(var apiBody) {
    switch (apiBody['error']['code']) {
      case 404:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 101:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 103:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 104:
        currencyController.setErrorMessage(apiBody['error']['type']);
        break;
      case 105:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 106:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 102:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 201:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      case 202:
        currencyController.setErrorMessage(apiBody['error']['type']);
        onErrorMessage();
        break;
      default:
        currencyController.setErrorMessage("Something went wrong");
        onErrorMessage();
    }
  }

  dropDownValue() async {
    currencyController.symbols.forEach((key, value) {
      {
        currencyController.setListOfSymbolsForDropDown(key);
        currencyController.setListofSymbolsValue("$key ($value)");
      }
    });
    await SharedPreferences.getInstance().then((value) {
      List<String> newValueList =
          currencyController.listOfSymbols.cast<String>();

      value.setStringList("symbols", newValueList);
      newValueList = currencyController.listOfSymbolsValue.cast<String>();
      value.setStringList("values", newValueList);

      currencyController.setOnApiError(false);
    });
  }

  searchSymbols() {
    currencyController.listOfSearch.clear();
    currencyController.listOfSearchKeys.clear();

    currencyController.listOfSymbolsValue.forEach((value) {
      if (value
          .toLowerCase()
          .contains(currencyController.symbol.value.toLowerCase())) {
        currencyController.setListOfSearch(value);
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
        Map<String, dynamic> apiResponse = json.decode(value.body);
        if (apiResponse['success']) {
          Navigator.pop(dialogcontext);
          currencyController.setSymbols(apiResponse['symbols']);
          dropDownValue();
        } else {
          Navigator.pop(dialogcontext);
          currencyController.setOnApiError(false);
          onError(apiBody);
        }
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
        Map<String, dynamic> apiResponse = json.decode(value.body);

        if (apiResponse['success']) {
          currencyController.setRates(apiResponse['rates']);
          currencyController.setIsConverted(true);
          currencyController.setIsLoading(false);
        } else {
          onError(apiResponse);
        }
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
    currencyController.setIsLoading(false);
    currencyController.setOnApiError(false);
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
        currencyController.setIsLoading(true);
        fetchCurrency();
      } else {
        toastMessage("No interent connection");
      }
    });
  }

  onSybolFetch() async {
    await checkInternet.getInternet().then((value) async {
      if (value) {
        onApiLoadDialog();
        currencyController.setOnApiError(true);
        fetchSymbols();
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
        child: SingleChildScrollView(
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
                      borderRadius: new BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
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
                                        currencyController
                                            .setAmountChecker(true);
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
                                        errorStyle: textStyl(
                                            Colors.red.withOpacity(0.7)),
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
                                  Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Container(
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
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (currencyController
                                                    .listOfSymbols.length ==
                                                0) {
                                              currencyController
                                                  .setOnApiError(true);
                                              getSymbols();
                                            }
                                          },
                                          child: Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 40,
                                                  ),
                                                  Obx(
                                                    () => DropdownButton(
                                                      focusColor: Colors.white,
                                                      isExpanded: false,
                                                      isDense: false,
                                                      elevation: 10,

                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      hint: Obx(
                                                        () => Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            currencyController
                                                                .toCurrecySymbol
                                                                .value,
                                                            style: TextStyle(
                                                                letterSpacing:
                                                                    1.4,
                                                                color: Colors
                                                                    .white,
                                                                // fontSize: 16,
                                                                fontFamily:
                                                                    "RaleWay",
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ), // Not necessary for Option 1
                                                      onChanged: (newValue) {
                                                        currencyController
                                                            .setIsConverted(
                                                                false);
                                                        currencyController
                                                            .setToCurrencySymbolCoverted(
                                                                newValue
                                                                    .toString());
                                                      },
                                                      items: currencyController
                                                          .listOfSymbols
                                                          .toList()
                                                          .map((value) {
                                                        return DropdownMenuItem(
                                                          child: Container(
                                                            child: new Text(
                                                              value,
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      1.4,

                                                                  // fontSize: 16,
                                                                  fontFamily:
                                                                      "RaleWay",
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          value: value,
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Container(
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.search,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              onPressed: () {
                                                if (currencyController
                                                        .listOfSymbols.length ==
                                                    0) {
                                                  currencyController
                                                      .setOnApiError(true);
                                                  getSymbols();
                                                } else
                                                  onSearch();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
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
                                      currencyController
                                          .setAmountChecker(false);
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
                                        child: !currencyController
                                                .isLoading.value
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
            ],
          ),
        ),
      ),
    );
  }
}
