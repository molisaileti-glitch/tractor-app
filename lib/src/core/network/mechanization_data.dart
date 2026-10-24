/// Preserve fields omitted by a brief API response; explicit null clears them.
Map<String, Object?> mergeMechanizationData(
  Map<String, Object?> previous,
  Map<String, Object?> incoming,
) {
  final result = Map<String, Object?>.from(previous);
  for (final entry in incoming.entries) {
    final old = result[entry.key];
    final next = entry.value;
    result[entry.key] =
        old is Map &&
            next is Map &&
            (next['id'] == null || old['id'] == next['id'])
        ? mergeMechanizationData(jsonMap(old), jsonMap(next))
        : next;
  }
  return result;
}

Map<String, Object?> jsonMap(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : <String, Object?>{};

DateTime? localApiTime(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '')?.toLocal();

DateTime? apiScheduleTime(Object? date, Object? time) {
  final day = date?.toString().split('T').first;
  if (day == null || day.isEmpty) return null;
  final clock = time?.toString();
  return localApiTime(clock == null || clock.isEmpty ? day : '${day}T$clock');
}

Future<Map<String, Object?>> allApiPages(
  Future<Map<String, Object?>> Function(int page) fetch, {
  required bool Function() isCurrent,
}) async {
  final rows = <Object?>[];
  var page = 1;
  while (isCurrent()) {
    final response = await fetch(page);
    if (!isCurrent()) break;
    final data = response['data'];
    final batch = data is List ? data : jsonMap(data)['data'];
    if (batch is List) rows.addAll(batch);
    final last =
        int.tryParse('${jsonMap(response['meta'])['last_page']}') ?? page;
    if (page >= last || batch is! List || batch.isEmpty) {
      return {...response, 'data': rows};
    }
    page++;
  }
  return {'data': <Object?>[]};
}
