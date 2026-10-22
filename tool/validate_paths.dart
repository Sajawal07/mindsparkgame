import 'dart:io';

bool oneApart(String a, String b) {
  if (a.length != b.length) return false;
  var d = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) d++;
    if (d > 1) return false;
  }
  return d == 1;
}

void check(String name, List<String> p) {
  for (var i = 0; i < p.length - 1; i++) {
    if (!oneApart(p[i], p[i + 1])) {
      stderr.writeln('FAIL $name at $i: ${p[i]} -> ${p[i + 1]}');
      exit(1);
    }
  }
  stdout.writeln('OK $name (${p.length}) ${p.first}->${p.last}');
}

void main() {
  check('e1', ['SLEEP', 'BLEEP', 'BLEED', 'BREED', 'CREED', 'GREED', 'TREED', 'TREAD']);
  check('e2', ['STONE', 'STORE', 'SCORE', 'SCARE', 'STARE', 'STATE', 'STALE', 'STALL']);
  check('e3', ['SMOKE', 'SPOKE', 'STOKE', 'STOVE', 'STOLE', 'STALE', 'STALK', 'STALL']);
  check('e4', ['BREAD', 'BROAD', 'BROOD', 'BROOK', 'BROOM', 'GROOM', 'GLOOM', 'BLOOM']);
  check('e5', ['FLAME', 'FLAKE', 'FLARE', 'GLARE', 'GLADE', 'BLADE', 'BLAME', 'BLARE']);
  check('e6', ['GLASS', 'GRASS', 'BRASS', 'BRASH', 'BRUSH', 'CRUSH', 'CRUST', 'TRUST']);
  check('e7', ['BLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPINE', 'SHINE', 'WHINE']);
  check('m1', ['BLACK', 'CLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPICY', 'SPINY', 'SHINY', 'SHINE', 'WHINE', 'WHILE']);
  check('m2', ['CRACK', 'BRACK', 'BLACK', 'SLACK', 'SLICK', 'SLICE', 'SPICE', 'SPICY', 'SPINY', 'SHINY', 'SHINE', 'WHINE']);
  check('m3', ['STONE', 'STORE', 'SCORE', 'SCARE', 'STARE', 'STATE', 'STALE', 'STALL', 'STILL', 'STILT', 'STINT', 'STING']);
  check('m4', ['CRACK', 'BRACK', 'BLACK', 'BLANK', 'BLAND', 'BLEND', 'BLEED', 'BREED', 'CREED', 'GREED', 'TREED', 'TREAD']);
  check('m5', ['SMOKE', 'SPOKE', 'STOKE', 'STOVE', 'STOLE', 'STALE', 'STALK', 'STALL', 'STILL', 'STILT', 'STINT', 'STING']);
  check('m6', ['CRACK', 'BRACK', 'BLACK', 'BLANK', 'BLAND', 'BLEND', 'BLEED', 'BREED', 'CREED', 'GREED', 'TREED', 'TREAD']);
  check('m7', ['SMOKE', 'SPOKE', 'STOKE', 'STOVE', 'STOLE', 'STALE', 'STALK', 'STALL', 'STILL', 'STILT', 'STINT', 'STING']);
  check('h2', ['CRACK', 'BRACK', 'BLACK', 'BLANK', 'BLAND', 'BLEND', 'BLEED', 'BREED', 'CREED', 'GREED', 'TREED', 'TREAD', 'TREAT', 'TERSE', 'VERSE', 'VERGE', 'FORGE', 'GROVE', 'GRAVE', 'BRACE']);
}
