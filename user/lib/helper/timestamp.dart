class Timestampss {
  int seconds;
  int nanoseconds;

  Timestampss(this.seconds, this.nanoseconds);

  // Convert Timestamp to DateTime
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000);
  }

  // Factory constructor to parse from a string
  factory Timestampss.fromString(String timestampString) {
    final regex = RegExp(r'Timestamp\(seconds=(\d+), nanoseconds=(\d+)\)');
    final match = regex.firstMatch(timestampString);

    if (match != null) {
      int seconds = int.parse(match.group(1)!);
      int nanoseconds = int.parse(match.group(2)!);
      return Timestampss(seconds, nanoseconds);
    } else {
      throw const FormatException("Invalid timestamp format");
    }
  }
}
