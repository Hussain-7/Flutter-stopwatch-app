import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stopwatch/platfrom_alert.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';

  @override
  State createState() => StopWatchState();
}

class StopWatchState extends State<StopWatch> {
  bool isTicking = false;
  late int milliseconds = 0;
  late Timer timer;
  final laps = <int>[];
  final itemHeight = 60.0;
  ScrollController _scrollController = ScrollController();

  void dispose() {
    print('dispose');
    timer.cancel();
    super.dispose();
  }

  void _onTick(Timer time) {
    setState(() {
      milliseconds += 100;
    });
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
      _scrollController.animateTo(
        itemHeight * laps.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context)?.settings.arguments as String;
    void _startTimer() {
      timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
      setState(() {
        laps.clear();
        isTicking = true;
      });
    }

    void _stopTimer() {
      timer.cancel();
      setState(() {
        isTicking = false;
      });
      final totalRuntime =
          laps.fold(milliseconds, (total, lap) => (total as int) + (lap));
      final alert = PlatformAlert(
        title: 'Run Completed!',
        message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
      );
      alert.show(context);
    }

    Widget _buildCounter(BuildContext context) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lap ${laps.length + 1}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
            Text(
              _secondsText(milliseconds),
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Start',
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: isTicking ? null : _startTimer,
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                  ),
                  child: Text('Lap',
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: isTicking ? _lap : null,
                ),
                SizedBox(width: 20),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Stop'),
                  onPressed: isTicking ? _stopTimer : null,
                ),
              ],
            )
          ],
        ),
      );
    }

    Widget _buildLapDisplay() {
      return Scrollbar(
        child: ListView.builder(
          controller: _scrollController,
          itemExtent: itemHeight,
          itemCount: laps.length,
          itemBuilder: (context, index) {
            final milliseconds = laps[index];
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text('Lap ${index + 1}'),
              trailing: Text(_secondsText(milliseconds)),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }
}
