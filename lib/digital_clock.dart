// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

enum _Element {
  background,
  bigCircleColor,
  mediumCircleColor,
  smallCircleColor,
  text,
}

final _lightTheme = {
  _Element.background: Colors.grey[200],
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.background: Colors.grey[900],
  _Element.text: Colors.white,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  var _temperature = '';
  var _condition = '';
  Timer _timer;

  final Tween _temperatureOpacity = Tween<double>(
    begin: 0,
    end: 1,
  );

  final Tween _temperatureOpacityRe = Tween<double>(
    begin: 1,
    end: 0,
  );

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 7),
    )..repeat();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _condition = widget.model.weatherString;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final _hours =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final _minutes = DateFormat('mm').format(_dateTime);
    final _date = DateFormat('d MMMM').format(_dateTime);
    final _year = DateFormat('y').format(_dateTime);
    final _day = DateFormat('EEEE').format(_dateTime);

    final _clockFontSize = MediaQuery.of(context).size.width / 5;

    final _deviceWidth = MediaQuery.of(context).size.width;
    final _deviceHeight = MediaQuery.of(context).size.height;

    final _mainContainerWidth = _deviceWidth / 2;
    final _mainContainersHeight = _deviceHeight / 2;

    final _temperatureFontSize = _mainContainersHeight / 3;

    final RelativeRectTween _temperaturePosition = RelativeRectTween(
      begin: RelativeRect.fromLTRB(35, _mainContainersHeight, 0, 0),
      end: RelativeRect.fromLTRB(10, _mainContainersHeight, 0, 0),
    );

    final RelativeRectTween _datePosition = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, 20, 0, 0),
      end: RelativeRect.fromLTRB(0, 0, 0, 0),
    );

    final RelativeRectTween _yearPosition = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, (_clockFontSize / 3) + 20, 0, 0),
      end: RelativeRect.fromLTRB(0, _clockFontSize / 3, 0, 0),
    );

    final monoChromaticClock = DefaultTextStyle(
      style: TextStyle(color: colors[_Element.text]),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            height: _mainContainersHeight,
            width: _mainContainerWidth,
            child: CustomPaint(
              painter: ShapesPainter(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: _mainContainersHeight,
              width: _mainContainerWidth,
              alignment: Alignment.bottomRight,
              child: Text(
                _hours,
                style: TextStyle(
                  height: 0,
                  fontSize: _clockFontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            top: _mainContainersHeight * 1.2,
            left: _mainContainerWidth * 1.1,
            child: Container(
              height: _mainContainersHeight,
              width: _mainContainerWidth,
              alignment: Alignment.topLeft,
              child: Text(
                _minutes,
                style: TextStyle(
                  height: 1.0,
                  fontSize: _clockFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: _mainContainerWidth * 1.1,
            child: Container(
              width: _mainContainerWidth,
              height: _mainContainersHeight,
              child: Stack(
                children: <Widget>[
                  PositionedTransition(
                    rect: _temperaturePosition.animate(
                      new CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.5,
                          1,
                          curve: Curves.easeOutCirc,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _temperatureOpacity.animate(
                        new CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.5,
                            0.6,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _temperatureOpacityRe.animate(
                          new CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.9,
                              1,
                              curve: Curves.easeInQuint,
                            ),
                          ),
                        ),
                        child: Text(
                          _temperature,
                          style: TextStyle(
                            fontSize: _temperatureFontSize,
                            height: 0.0,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedTransition(
                    rect: _temperaturePosition.animate(
                      new CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0,
                          0.5,
                          curve: Curves.easeOutCirc,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _temperatureOpacity.animate(
                        new CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0,
                            0.1,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _temperatureOpacityRe.animate(
                          new CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.4,
                              0.5,
                              curve: Curves.easeInQuint,
                            ),
                          ),
                        ),
                        child: Text(
                          _condition,
                          style: TextStyle(
                            fontSize: _temperatureFontSize / 1.5,
                            height: 0.0,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _mainContainersHeight * 1.2,
            left: 0,
            child: Container(
              width: _mainContainerWidth,
              height: _mainContainersHeight,
              child: Stack(
                children: <Widget>[
                  PositionedTransition(
                    rect: _datePosition.animate(
                      new CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.5,
                          0.6,
                          curve: Curves.ease,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _temperatureOpacity.animate(
                        new CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.5,
                            0.6,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _temperatureOpacityRe.animate(
                          new CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.87,
                              0.97,
                              curve: Curves.easeInQuint,
                            ),
                          ),
                        ),
                        child: Text(
                          _date,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: _clockFontSize / 3,
                            height: 1.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedTransition(
                    rect: _yearPosition.animate(
                      new CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.53,
                          0.63,
                          curve: Curves.ease,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _temperatureOpacity.animate(
                        new CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.53,
                            0.63,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _temperatureOpacityRe.animate(
                          new CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.9,
                              1,
                              curve: Curves.easeInQuint,
                            ),
                          ),
                        ),
                        child: Text(
                          _year,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: _clockFontSize / 3.5,
                            height: 1.0,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedTransition(
                    rect: _datePosition.animate(
                      new CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0,
                          0.1,
                          curve: Curves.ease,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _temperatureOpacity.animate(
                        new CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0,
                            0.1,
                            curve: Curves.easeInOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _temperatureOpacityRe.animate(
                          new CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.4,
                              0.5,
                              curve: Curves.easeInQuint,
                            ),
                          ),
                        ),
                        child: Text(
                          _day,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: _clockFontSize / 2,
                            height: 1.0,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      width: _deviceWidth,
      height: _deviceHeight,
      child: monoChromaticClock,
      color: colors[_Element.background],
    );
  }
}

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint _bigCircle = Paint()..color = Colors.black45;
    Paint _mediumCircle = Paint()..color = Colors.black54;
    Paint _smallCircle = Paint()..color = Colors.black87;

    Offset topRight = Offset(size.width * 1.2, size.height / 1.3);
    Offset bottomLeft = Offset(size.width * 0.8, size.height / 0.7);
    Offset topLeft = Offset(size.width * 0.6, size.height / 1.5);

    canvas.drawCircle(topRight, size.height * 1.3, _bigCircle);
    canvas.drawCircle(bottomLeft, size.height, _mediumCircle);
    canvas.drawCircle(topLeft, size.height * 0.9, _smallCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
