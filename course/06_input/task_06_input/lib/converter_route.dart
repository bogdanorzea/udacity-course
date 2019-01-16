// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:math' as math;

import 'unit.dart';

const _padding = EdgeInsets.all(16.0);

/// [ConverterRoute] where users can input amounts to convert in one [Unit]
/// and retrieve the conversion in another [Unit] for a specific [Category].
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class ConverterRoute extends StatefulWidget {
  /// This [Category]'s name.
  final String name;

  /// Color for this [Category].
  final Color color;

  /// Units for this [Category].
  final List<Unit> units;

  /// This [ConverterRoute] requires the name, color, and units to not be null.
  const ConverterRoute({
    @required this.name,
    @required this.color,
    @required this.units,
  })  : assert(name != null),
        assert(color != null),
        assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<ConverterRoute> {
  // Set some variables, such as for keeping track of the user's input value and units
  bool _validInput = false;

  Unit _inputCurrentUnit;
  Unit _outputCurrentUnit;

  final _inputTextController = TextEditingController();
  final _outputTextController = TextEditingController();

  List<DropdownMenuItem<Unit>> _unitsDropdownMenuItems;

  RegExp regExp = RegExp(r"^\d*\.?\d*$");

  // Determine whether you need to override anything, such as initState()
  @override
  void initState() {
    _unitsDropdownMenuItems = _getDropdownMenuItems();
    _inputCurrentUnit = _unitsDropdownMenuItems[0].value;
    _outputCurrentUnit = _unitsDropdownMenuItems[1].value;
    _inputTextController.addListener(() {
      setState(() {
        var inputText = _inputTextController.text;
        _validInput = regExp.hasMatch(inputText);
        if (_validInput) {
          try {
            var result = double.parse(inputText) /
                _inputCurrentUnit.conversion *
                _outputCurrentUnit.conversion;

            _outputTextController.text = _format(result);
          } on Exception catch (e) {
            print('Error: $e');
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    _outputTextController.dispose();

    super.dispose();
  }

  // Add other helper functions. We've given you one, _format()
  List<DropdownMenuItem<Unit>> _getDropdownMenuItems() {
    return widget.units.map((Unit unit) {
      return DropdownMenuItem<Unit>(
        value: unit,
        child: Text(
          unit.name,
        ),
      );
    }).toList();
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  @override
  Widget build(BuildContext context) {
    // Create the 'input' group of widgets. This is a Column that
    // includes the input value, and 'from' unit [Dropdown].
    Widget inputGroup = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _inputTextController,
          style: Theme.of(context).textTheme.headline,
          keyboardType: TextInputType.numberWithOptions(),
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            labelText: 'Input',
            errorText: _validInput ? null : 'Please input valid number',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: DropdownButton<Unit>(
            value: _inputCurrentUnit,
            items: _unitsDropdownMenuItems,
            style: Theme.of(context).textTheme.headline,
            onChanged: (selectedUnit) {
              setState(() {
                _inputCurrentUnit = selectedUnit;
              });
            },
          ),
        ),
      ],
    );

    // Create a compare arrows icon.
    Widget compareArrowsGroup = Padding(
      padding: _padding,
      child: Transform.rotate(
        angle: -math.pi / 2,
        child: Icon(
          Icons.compare_arrows,
          size: 40.0,
        ),
      ),
    );

    // Create the 'output' group of widgets. This is a Column that
    // includes the output value, and 'to' unit [Dropdown].
    Widget resultGroup = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _outputTextController,
          style: Theme.of(context).textTheme.headline,
          enabled: false,
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            labelText: 'Result',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<Unit>(
                value: _outputCurrentUnit,
                items: _unitsDropdownMenuItems,
                style: Theme.of(context).textTheme.headline,
                onChanged: (selectedUnit) {
                  setState(() {
                    _outputCurrentUnit = selectedUnit;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );

    // Return the input, arrows, and output widgets, wrapped in a Column.
    return Padding(
      padding: _padding,
      child: Column(
        children: <Widget>[
          inputGroup,
          compareArrowsGroup,
          resultGroup,
        ],
      ),
    );
  }
}
