import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/bloc/timer_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  final List<String> history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'STOPWATCH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: CircularProgress(),
                ),
              ),

              Actions(
                onSave: () {
                  final duration =
                      context.read<TimerBloc>().state.duration;

                  final minutes =
                      ((duration ~/ 60) % 60)
                          .toString()
                          .padLeft(2, '0');

                  final seconds =
                      (duration % 60)
                          .toString()
                          .padLeft(2, '0');

                  final milliseconds =
                      ((duration * 100) % 100)
                          .toString()
                          .padLeft(2, '0');

                  setState(() {
                    history.add(
                      '$minutes:$seconds:$milliseconds',
                    );
                  });
                },
              ),

              const SizedBox(height: 40),

              const Text(
                'HISTORY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: Text(
                        history[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
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
    final duration = context.select(
      (TimerBloc bloc) => bloc.state.duration,
    );

    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 12.0,
      percent: (duration / 600).clamp(0.0, 1.0),
      animation: true,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.greenAccent,
      backgroundColor: Colors.white12,
      center: const TimerText(),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = context.select(
      (TimerBloc bloc) => bloc.state.duration,
    );

    final minutesStr = ((duration ~/ 60) % 60)
        .toString()
        .padLeft(2, '0');

    final secondsStr = (duration % 60)
        .toString()
        .padLeft(2, '0');

    final millisecondsStr = ((duration * 100) % 100)
        .toString()
        .padLeft(2, '0');

    return Text(
      '$minutesStr:$secondsStr:$millisecondsStr',
      style: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 4,
        shadows: [
          Shadow(
            blurRadius: 20,
            color: Colors.greenAccent,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
  }
}

class Actions extends StatelessWidget {
  final VoidCallback onSave;

  const Actions({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) =>
          prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...switch (state) {
              TimerInitial() => [
                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
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
                  elevation: 8,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.pause),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(const TimerPaused()),
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.save),
                  onPressed: onSave,
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.replay),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(const TimerReset()),
                ),
              ],

              TimerRunPause() => [
                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(const TimerResumed()),
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.save),
                  onPressed: onSave,
                ),

                const SizedBox(width: 25),

                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.replay),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(const TimerReset()),
                ),
              ],

              TimerRunComplete() => [
                FloatingActionButton(
                  heroTag: null,
                  elevation: 8,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.replay),
                  onPressed: () => context
                      .read<TimerBloc>()
                      .add(const TimerReset()),
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
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
        ),
      ),
    );
  }
}