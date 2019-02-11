// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Import relevant packages
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:task_11_api/unit.dart';

/// The REST API retrieves unit conversions for [Categories] that change.
///
/// For example, the currency exchange rate, stock prices, the height of the
/// tides change often.
/// We have set up an API that retrieves a list of currencies and their current
/// exchange rate (mock data).
///   GET /currency: get a list of currencies
///   GET /currency/convert: get conversion from one currency amount to another
class Api {
  // Add any relevant variables and helper functions
  static final _url = 'https://flutter.udacity.com';

  /// Gets all the units and conversion rates for a given category.
  ///
  /// The `category` parameter is the name of the [Category] from which to
  /// retrieve units. We pass this into the query parameter in the API call.
  ///
  /// Returns a list. Returns null on error.
  Future<List<Unit>> getUnits(String categoryName) async {
    final url = '$_url/$categoryName';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = JsonDecoder().convert(response.body);

      return data['units']
          .map<Unit>((dynamic data) => Unit.fromJson(data))
          .toList();
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load units for category $categoryName');
    }
  }

  /// Given two units, converts from one to another.
  ///
  /// Returns a double, which is the converted amount. Returns null on error.
  Future<double> convert(String categoryName, String fromUnit, String toUnit,
      String amount) async {
    final url = '$_url/$categoryName/convert?amount=$amount&from=$fromUnit&to=$toUnit';
    final response = await http.get(url.toString());

    if (response.statusCode == 200) {
      final data = JsonDecoder().convert(response.body);
      print (data['conversion'].toDouble());

      return data['conversion'];
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to convert units for category $categoryName');
    }
  }
}
