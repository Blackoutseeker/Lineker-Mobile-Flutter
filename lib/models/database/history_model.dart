class HistoryModel {
  final String title;
  final String url;
  final String date;
  final String datetime;

  const HistoryModel({
    required this.title,
    required this.url,
    required this.date,
    required this.datetime,
  });

  factory HistoryModel.convertFromDatabase(Map<dynamic, dynamic> data) {
    return HistoryModel(
      title: data['title'],
      url: data['url'],
      date: data['date'],
      datetime: data['datetime'],
    );
  }
}
