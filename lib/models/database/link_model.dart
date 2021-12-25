class LinkModel {
  final String date;
  final String datetime;
  final String title;
  final String url;

  LinkModel({
    required this.date,
    required this.datetime,
    required this.title,
    required this.url,
  });

  factory LinkModel.convertFromDatabase(Map<dynamic, dynamic> data) {
    return LinkModel(
      date: data['date'],
      datetime: data['datetime'],
      title: data['title'],
      url: data['url'],
    );
  }
}
