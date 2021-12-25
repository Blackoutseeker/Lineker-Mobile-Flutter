class FilterModel {
  const FilterModel(this.filter);

  final String filter;

  factory FilterModel.convertFromDatabase(Map<dynamic, dynamic> data) {
    return FilterModel(data['filter']);
  }
}
