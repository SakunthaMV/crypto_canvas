import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

bool hasInternet(BuildContext context) {
  return Provider.of<InternetStatus>(context) == InternetStatus.connected;
}
