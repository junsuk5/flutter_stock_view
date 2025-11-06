class PricePoint {
  const PricePoint({required this.time, required this.close});

  final DateTime time;
  final double close;

  PricePoint copyWith({DateTime? time, double? close}) {
    return PricePoint(time: time ?? this.time, close: close ?? this.close);
  }
}
