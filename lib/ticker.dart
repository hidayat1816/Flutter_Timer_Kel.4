class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}