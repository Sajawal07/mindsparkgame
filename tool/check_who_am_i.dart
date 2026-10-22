import '../lib/data/catalog/who_am_i_database.dart';

void main() {
  for (final q in WhoAmIDatabase.questions) {
    if (!q.options.contains(q.name)) {
      print('MISMATCH: id=${q.id} name=${q.name} options=${q.options}');
    }
    if (q.options.length != 4) {
      print('BAD OPTIONS LENGTH: id=${q.id} len=${q.options.length}');
    }
    if (q.clues.length != 6) {
      print('BAD CLUES LENGTH: id=${q.id} len=${q.clues.length}');
    }
  }
  print('Checked ${WhoAmIDatabase.questions.length} questions');
}
