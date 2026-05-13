import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/bloc/timer_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  List<String> history = [];

  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('timer_history', history);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      history = prefs.getStringList('timer_history') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'STOPWATCH',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Background(isDarkMode: isDarkMode),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgress(),
                  ),
                ),
              ),

              Actions(
                onSave: () {
                  final duration = context.read<TimerBloc>().state.duration;

                  final minutes = ((duration ~/ 60) % 60).toString().padLeft(
                    2,
                    '0',
                  );

                  final seconds = (duration % 60).toString().padLeft(2, '0');

                  final milliseconds = ((duration * 100) % 100)
                      .toString()
                      .padLeft(2, '0');

                  setState(() {
                    history.add('$minutes:$seconds:$milliseconds');
                  });

                  saveHistory();
                },
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HISTORY',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(width: 15),

                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: isDarkMode
                                ? const Color(0xFF203A43)
                                : Colors.white,
                            title: Text(
                              'Delete History',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete all history?',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    history.clear();
                                  });

                                  saveHistory();

                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        history[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);

    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 12.0,
      percent: (duration / 600).clamp(0.0, 1.0),
      animation: true,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.greenAccent,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white12
          : Colors.black12,
      center: const TimerText(),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);

    final minutesStr = ((duration ~/ 60) % 60).toString().padLeft(2, '0');

    final secondsStr = (duration % 60).toString().padLeft(2, '0');

    final millisecondsStr = ((duration * 100) % 100).toString().padLeft(2, '0');

    return Text(
      '$minutesStr:$secondsStr:$millisecondsStr',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        letterSpacing: 4,
      ),
    );
  }
}

class Actions extends StatelessWidget {
  final VoidCallback onSave;

  const Actions({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...switch (state) {
              TimerInitial() => [
                FloatingActionButton(
                  heroTag: null,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context.read<TimerBloc>().add(
                    TimerStarted(duration: state.duration),
                  ),
                ),
              ],

              TimerRunInProgress() => [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.pause),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerPaused()),
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.save),
                  onPressed: onSave,
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.replay),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerReset()),
                ),
              ],

              TimerRunPause() => [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.play_arrow),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerResumed()),
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.save),
                  onPressed: onSave,
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.replay),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerReset()),
                ),
              ],

              TimerRunComplete() => [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.replay),
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerReset()),
                ),
              ],
            },
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  final bool isDarkMode;

  const Background({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  const Color(0xFF2C5364),
                ]
              : [const Color(0xFFF5F7FA), const Color(0xFFE2E8F0),],
        ),
      ),
    );
  }
}
