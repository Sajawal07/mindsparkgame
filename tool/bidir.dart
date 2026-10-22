import 'find_ladders.dart' show wordLadderBank;


bool oneApart(String a, String b) {
  if (a.length != b.length) return false;
  var d = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) d++;
    if (d > 1) return false;
  }
  return d == 1;
}

late final Map<String, List<String>> _n = () {
  final m = <String, List<String>>{};
  for (final w in wordLadderBank) {
    m[w] = [
      for (final o in wordLadderBank)
        if (w != o && oneApart(w, o)) o,
    ];
  }
  return m;
}();

Map<String, List<String>> frontier(String start, int steps) {
  var layer = <String, List<String>>{start: [start]};
  for (var s = 0; s < steps; s++) {
    final next = <String, List<String>>{};
    for (final e in layer.entries) {
      for (final nb in _n[e.key]!) {
        if (e.value.contains(nb)) continue;
        next[nb] = [...e.value, nb];
      }
    }
    layer = next;
  }
  return layer;
}

List<String>? pathLen(String start, String end, int wordCount) {
  final edges = wordCount - 1;
  for (final a in [edges ~/ 2, (edges + 1) ~/ 2, 9, 10]) {
    final b = edges - a;
    if (b < 0) continue;
    final fwd = frontier(start, a);
    final bwd = frontier(end, b);
    for (final w in fwd.keys) {
      if (!bwd.containsKey(w)) continue;
      final left = fwd[w]!;
      final right = bwd[w]!.reversed.toList();
      final full = [...left, ...right.skip(1)];
      if (full.length != wordCount) continue;
      if (full.first != start || full.last != end) continue;
      var ok = true;
      for (var i = 0; i < full.length - 1; i++) {
        if (!oneApart(full[i], full[i + 1])) {
          ok = false;
          break;
        }
      }
      if (ok) return full;
    }
  }
  return null;
}

void main(List<String> args) {
  final len = int.parse(args.isEmpty ? '20' : args[0]);
  final need = int.parse(args.length < 2 ? '8' : args[1]);
  final seeds = [
    ('SLEEP', 'BRACE'),
    ('BLACK', 'BRACE'),
    ('CRACK', 'TRUST'),
    ('FLAME', 'WHILE'),
    ('STONE', 'STING'),
    ('BREAD', 'BREAK'),
    ('GLASS', 'GRACE'),
    ('SMOKE', 'NIGHT'),
    ('HEART', 'SMART'),
    ('LIGHT', 'NIGHT'),
    ('BEACH', 'BRACE'),
    ('BEACH', 'TRUST'),
    ('CRACK', 'BRACE'),
    ('BLACK', 'TRUST'),
    ('STONE', 'BRACE'),
    ('FLAME', 'PLANT'),
    ('BREAD', 'GRAVE'),
    ('SLEEP', 'TRUST'),
    ('CRACK', 'WHILE'),
    ('SMOKE', 'BRACE'),
  ];
  final used = <String>{};
  var n = 0;
  for (final s in seeds) {
    final p = pathLen(s.$1, s.$2, len);
    if (p == null) {
      print('NO ${s.$1}->${s.$2}');
      continue;
    }
    final sig = p.join(',');
    if (used.contains(sig)) continue;
    used.add(sig);
    n++;
    print('$n: ${s.$1} -> ${s.$2}');
    print(sig);
    print('');
    if (n >= need) return;
  }
  final list = wordLadderBank.toList()..sort();
  outer:
  for (final a in list) {
    for (final b in list) {
      if (a == b) continue;
      final p = pathLen(a, b, len);
      if (p == null) continue;
      final sig = p.join(',');
      if (used.contains(sig)) continue;
      used.add(sig);
      n++;
      print('$n: $a -> $b');
      print(sig);
      print('');
      if (n >= need) break outer;
    }
  }
}
