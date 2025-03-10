class TimeSlotGenerator {
  List<String> generateTimeSlots(int waitingTime, String range) {
    List<String> slots = [];
    List<String> rangeParts = range.split(" - ");
    Map<String, int> startTime = convertTo24HourFormat(rangeParts[0]);
    Map<String, int> endTime = convertTo24HourFormat(rangeParts[1]);

    DateTime now = DateTime.now();
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    start = DateTime(start.year, start.month, start.day, startTime['hours']!,
        startTime['minutes']!);
    end = DateTime(
        end.year, end.month, end.day, endTime['hours']!, endTime['minutes']!);

    now = now.add(Duration(minutes: waitingTime));
    now = now.add(Duration(
        minutes: 10 - (now.minute % 10))); // Round to the next 10 minutes

    for (int i = 0; i < 6; i++) {
      if (start.isAfter(end)) {
        if (now.isAfter(start) || now.isBefore(end)) {
          slots.add(formatTime(now));
        } else {
          slots.add("Closed");
        }
      } else {
        if (now.isBefore(start) || now.isAfter(end)) {
          slots.add("Closed");
        } else {
          slots.add(formatTime(now));
        }
      }
      now = now.add(Duration(minutes: 30));
    }
    return slots;
  }

  Map<String, int> convertTo24HourFormat(String timeStr) {
    List<String> parts = timeStr.split(" ");
    List<String> timeParts = parts[0].split(":");
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    if (parts[1] == "PM" && hours != 12) {
      hours += 12;
    }
    if (parts[1] == "AM" && hours == 12) {
      hours = 0;
    }
    return {'hours': hours, 'minutes': minutes};
  }

  String formatTime(DateTime time) {
    int hours = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minutes = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? "PM" : "AM";
    return "$hours:$minutes $period";
  }
}
