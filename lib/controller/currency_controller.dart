import 'package:currency_exchange/controller/check_internet_connection.dart';
import 'package:currency_exchange/model/currency_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class CurrencyController extends GetxController {
  final amount = 0.0.obs;
  final amountChecker = true.obs;
  final toChecker = true.obs;
  final isLoading = false.obs;
  final isConverted = false.obs;
  final symbol = "".obs;
  final isSymbol = false.obs;
  final toValue = "".obs;
  final toCurrecySymbol = "".obs;
  final symbols = Map<String, dynamic>().obs;
  final List listOfSearch = [].obs;
  final List listOfSearchKeys = [].obs;
  Dio dio = new Dio();
  CheckInternet checkInternet = new CheckInternet();
  final rates = <String, dynamic>{}.obs;
  CurrencyModel currencyModel;
  List<CurrencyModel> listOfrates = new List();
  @override
  void onInit() {
    super.onInit();
  }

  setToCurrencySymbolCoverted(String value) {
    toCurrecySymbol(value);
  }

  setRates(var rate) {
    rates.addAll(rate);
  }

  setListOfSearch(String listofSearchValue) {
    listOfSearch.add(listofSearchValue);
  }

  setListOfKeySearch(String listofSearchKey) {
    listOfSearchKeys.add(listofSearchKey);
  }

  setSymbols(Map<String, dynamic> symbolslist) {
    symbols(symbolslist);
  }

  setToValue(String toVal) {
    toValue(toVal);
  }

  setToCurrencySymbol(String symbolName) {
    symbol(symbolName);
  }

  setIsSymbol(bool isSymbolSet) {
    isSymbol(isSymbolSet);
  }

  setamount(double amountTo) {
    amount(amountTo);
  }

  setAmountChecker(bool isAmount) {
    amountChecker(isAmount);
  }

  setTochecker(bool isTo) {
    toChecker(isTo);
  }

  setIsLoading(bool loading) {
    isLoading(loading);
  }

  setIsConverted(bool isConvertedValue) {
    isConverted(isConvertedValue);
  }

  static CurrencyController get to => Get.find<CurrencyController>();
}
