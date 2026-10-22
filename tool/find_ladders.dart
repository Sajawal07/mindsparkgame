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

const wordLadderBank = {
  'ABOUT', 'ABOVE', 'ABUSE', 'ACUTE', 'ADAPT', 'ADMIT', 'ADOBE', 'ADOPT', 'ADULT', 'AFTER',
  'AGAIN', 'AGENT', 'AGILE', 'ALARM', 'ALBUM', 'ALERT', 'ALIEN', 'ALIGN', 'ALIVE', 'ALLEY',
  'ALLOW', 'ALONE', 'ALONG', 'ALTER', 'AMBER', 'AMONG', 'ANGEL', 'ANGER', 'ANGLE', 'ANGRY',
  'APART', 'APPLE', 'APPLY', 'ARENA', 'ARGUE', 'ARISE', 'ARMOR', 'AROMA', 'ARROW', 'ASIDE',
  'ASSET', 'AUDIO', 'AVOID', 'AWAKE', 'AWARD', 'AWARE', 'BADLY', 'BAKER', 'BASIC', 'BASIN',
  'BATCH', 'BEACH', 'BEARD', 'BEARS', 'BEAST', 'BEGAN', 'BEGIN', 'BEING', 'BELLY', 'BELOW',
  'BENCH', 'BERRY', 'BIRTH', 'BLACK', 'BLADE', 'BLAME', 'BLAND', 'BLANK', 'BLARE', 'BLAST',
  'BLEAK', 'BLEED', 'BLEND', 'BLESS', 'BLIND', 'BLINK', 'BLOCK', 'BLOND', 'BLOOD', 'BLOOM',
  'BLOWN', 'BLUES', 'BLUNT', 'BLUSH', 'BOARD', 'BOAST', 'BOATS', 'BONES', 'BONUS', 'BOOKS',
  'BOOST', 'BOOTH', 'BOOTS', 'BOUND', 'BOXES', 'BRACE', 'BRAIN', 'BRAKE', 'BRAND', 'BRASS',
  'BRAVE', 'BREAD', 'BREAK', 'BREED', 'BRICK', 'BRIDE', 'BRIEF', 'BRINE', 'BRING', 'BRISK',
  'BROAD', 'BROKE', 'BROOD', 'BROOK', 'BROOM', 'BROWN', 'BRUSH', 'BUILD', 'BUILT', 'BUNCH',
  'BURST', 'CABLE', 'CACHE', 'CAMEL', 'CANAL', 'CANDY', 'CANOE', 'CARDS', 'CARRY', 'CARVE',
  'CATCH', 'CAUSE', 'CEASE', 'CHAIN', 'CHAIR', 'CHAOS', 'CHARM', 'CHART', 'CHASE', 'CHEAP',
  'CHEAT', 'CHECK', 'CHEEK', 'CHEER', 'CHEST', 'CHIEF', 'CHILD', 'CHILI', 'CHINA', 'CHIPS',
  'CHOIR', 'CHORD', 'CHORE', 'CHUNK', 'CIVIC', 'CIVIL', 'CLAIM', 'CLAMP', 'CLASH', 'CLASS',
  'CLEAN', 'CLEAR', 'CLERK', 'CLICK', 'CLIFF', 'CLIMB', 'CLING', 'CLOCK', 'CLONE', 'CLOSE',
  'CLOTH', 'CLOUD', 'CLUBS', 'CLUCK', 'CLUMP', 'COACH', 'COAST', 'COLOR', 'COMET', 'COMIC',
  'CORAL', 'CORDS', 'CORES', 'CORNS', 'CORPS', 'COSTS', 'COUCH', 'COULD', 'COUNT', 'COURT',
  'COVER', 'CRACK', 'CRAFT', 'CRANE', 'CRANK', 'CRASH', 'CRATE', 'CRAWL', 'CRAZY', 'CREAK',
  'CREAM', 'CREED', 'CREEK', 'CREEP', 'CREST', 'CRIME', 'CRISP', 'CROSS', 'CROWD', 'CROWN',
  'CRUDE', 'CRUSH', 'CRUST', 'CURVE', 'CYCLE', 'DAILY', 'DANCE', 'DATED', 'DEALT', 'DEATH',
  'DEBUT', 'DELAY', 'DEPTH', 'DIRTY', 'DOUBT', 'DOZEN', 'DRAFT', 'DRAMA', 'DRANK', 'DRAWN',
  'DREAM', 'DRESS', 'DRIED', 'DRIFT', 'DRILL', 'DRINK', 'DRIVE', 'DROVE', 'DROWN', 'DRUGS',
  'DRUMS', 'DRUNK', 'DUSTY', 'EAGER', 'EAGLE', 'EARLY', 'EARTH', 'EIGHT', 'ELITE', 'EMPTY',
  'ENEMY', 'ENJOY', 'ENTER', 'ENTRY', 'EQUAL', 'ERROR', 'EVENT', 'EVERY', 'EXACT', 'EXIST',
  'EXTRA', 'FAITH', 'FALSE', 'FANCY', 'FATAL', 'FAULT', 'FAVOR', 'FEAST', 'FIBER', 'FIELD',
  'FIERY', 'FIFTH', 'FIGHT', 'FINAL', 'FIRST', 'FIXED', 'FLAME', 'FLAKE', 'FLANK', 'FLARE',
  'FLASH', 'FLEET', 'FLESH', 'FLICK', 'FLINT', 'FLIRT', 'FLOAT', 'FLOOD', 'FLOOR', 'FLOUR',
  'FLOWN', 'FLUID', 'FLUSH', 'FLUTE', 'FOCUS', 'FORCE', 'FORGE', 'FORTH', 'FOUND', 'FRAME',
  'FRANK', 'FRAUD', 'FRESH', 'FRONT', 'FROST', 'FROZE', 'FRUIT', 'FULLY', 'FUNNY', 'GAINS',
  'GAMES', 'GATES', 'GAUGE', 'GENRE', 'GHOST', 'GIANT', 'GIFTS', 'GIVEN', 'GLADE', 'GLAND',
  'GLARE', 'GLASS', 'GLAZE', 'GLEAM', 'GLIDE', 'GLOBE', 'GLOOM', 'GLORY', 'GLOVE', 'GOING',
  'GRACE', 'GRADE', 'GRAIN', 'GRAND', 'GRANT', 'GRAPE', 'GRASP', 'GRASS', 'GRAVE', 'GREAT',
  'GREED', 'GREEN', 'GREET', 'GRIEF', 'GRILL', 'GRIND', 'GROAN', 'GROOM', 'GROSS', 'GROUP',
  'GROVE', 'GROWN', 'GUARD', 'GUESS', 'GUEST', 'GUIDE', 'GUILD', 'GUILT', 'HABIT', 'HAPPY',
  'HASTE', 'HATED', 'HAVEN', 'HEARD', 'HEART', 'HEAVY', 'HENCE', 'HONEY', 'HONOR', 'HORSE',
  'HOTEL', 'HOUSE', 'HUMAN', 'HUMOR', 'IDEAL', 'IMAGE', 'IMPLY', 'INBOX', 'INDEX', 'INNER',
  'INPUT', 'ISSUE', 'IVORY', 'JEWEL', 'JOINT', 'JOKES', 'JUDGE', 'JUICE', 'JUMPS', 'KEEPS',
  'KINGS', 'KNEES', 'KNIFE', 'KNOCK', 'KNOWN', 'LABEL', 'LARGE', 'LASER', 'LATER', 'LAUGH',
  'LAYER', 'LEARN', 'LEASE', 'LEAST', 'LEAVE', 'LEGAL', 'LEMON', 'LEVEL', 'LIGHT', 'LIKED',
  'LIMIT', 'LINED', 'LINKS', 'LIONS', 'LISTS', 'LIVED', 'LIVER', 'LOADS', 'LOANS', 'LOCAL',
  'LOCKS', 'LODGE', 'LOGIC', 'LOOSE', 'LOVER', 'LOWER', 'LOYAL', 'LUCKY', 'LUNCH', 'LYING',
  'MAGIC', 'MAJOR', 'MAKER', 'MAPLE', 'MARCH', 'MATCH', 'MAYOR', 'MEANT', 'MEDIA', 'MERCY',
  'MERIT', 'METAL', 'METER', 'MIDST', 'MIGHT', 'MINOR', 'MINUS', 'MIXED', 'MODEL', 'MONEY',
  'MONTH', 'MORAL', 'MOTOR', 'MOUNT', 'MOUSE', 'MOUTH', 'MOVED', 'MOVIE', 'MUSIC', 'NAKED',
  'NAMED', 'NASTY', 'NAVAL', 'NEEDS', 'NERVE', 'NEVER', 'NEWLY', 'NIGHT', 'NOBLE', 'NOISE',
  'NORTH', 'NOTED', 'NOVEL', 'NURSE', 'OCCUR', 'OCEAN', 'OFFER', 'OFTEN', 'OLIVE', 'ONSET',
  'OPERA', 'ORDER', 'ORGAN', 'OTHER', 'OUGHT', 'OUNCE', 'OUTER', 'OWNED', 'OWNER', 'OXIDE',
  'PACKS', 'PAINT', 'PANEL', 'PANIC', 'PAPER', 'PARTY', 'PASTA', 'PATCH', 'PATHS', 'PAUSE',
  'PEACE', 'PEACH', 'PEARL', 'PEDAL', 'PENNY', 'PHASE', 'PHONE', 'PHOTO', 'PIANO', 'PIECE',
  'PILOT', 'PITCH', 'PIZZA', 'PLACE', 'PLAIN', 'PLANE', 'PLANT', 'PLATE', 'PLAZA', 'PLEAD',
  'PLUCK', 'PLUMB', 'PLUMP', 'POEMS', 'POINT', 'POKER', 'POLAR', 'POLES', 'PORCH', 'POUND',
  'POWER', 'PRESS', 'PRICE', 'PRIDE', 'PRIME', 'PRINT', 'PRIOR', 'PRIZE', 'PROBE', 'PRONE',
  'PROOF', 'PROSE', 'PROUD', 'PROVE', 'PSALM', 'PULSE', 'PUMPS', 'PUNCH', 'PUPIL', 'QUEEN',
  'QUERY', 'QUEST', 'QUEUE', 'QUICK', 'QUIET', 'QUITE', 'QUOTE', 'RADAR', 'RADIO', 'RAISE',
  'RALLY', 'RANGE', 'RAPID', 'RATED', 'RATIO', 'REACH', 'REACT', 'READY', 'REALM', 'REBEL',
  'REFER', 'RELAX', 'RELAY', 'REPAY', 'REPLY', 'RIDER', 'RIDGE', 'RIGHT', 'RIGID', 'RINGS',
  'RISKY', 'RIVAL', 'RIVER', 'ROADS', 'ROAST', 'ROBIN', 'ROBOT', 'ROCKY', 'ROGUE', 'ROMAN',
  'ROOMS', 'ROSES', 'ROUGH', 'ROUND', 'ROUTE', 'ROYAL', 'RUGBY', 'RUINS', 'RULER', 'RURAL',
  'SADLY', 'SAFER', 'SALAD', 'SALES', 'SALON', 'SANDS', 'SATIN', 'SAUCE', 'SAVED', 'SAVES',
  'SCALE', 'SCARE', 'SCARF', 'SCARY', 'SCENE', 'SCENT', 'SCORE', 'SCORN', 'SCOUT', 'SCRAP',
  'SEATS', 'SEEDS', 'SEEMS', 'SEIZE', 'SENSE', 'SERVE', 'SETUP', 'SEVEN', 'SHADE', 'SHAKE',
  'SHALL', 'SHAME', 'SHAPE', 'SHARE', 'SHARK', 'SHARP', 'SHEEP', 'SHEER', 'SHEET', 'SHELF',
  'SHELL', 'SHIFT', 'SHINE', 'SHINY', 'SHIPS', 'SHIRT', 'SHOCK', 'SHOES', 'SHOOK', 'SHOOT',
  'SHOPS', 'SHORE', 'SHORT', 'SHOUT', 'SHOWN', 'SIDES', 'SIGHT', 'SILLY', 'SINCE', 'SIXTH',
  'SIZED', 'SKATE', 'SKIFF', 'SKILL', 'SKINS', 'SKIRT', 'SLACK', 'SLAIN', 'SLANG', 'SLATE',
  'SLAVE', 'SLEEK', 'SLEEP', 'SLICE', 'SLIDE', 'SLIME', 'SLING', 'SLINK', 'SLOPE', 'SLOTS',
  'SLUMP', 'SMACK', 'SMALL', 'SMART', 'SMASH', 'SMEAR', 'SMELL', 'SMILE', 'SMOKE', 'SNACK',
  'SNAKE', 'SNAPS', 'SNARE', 'SNEAK', 'SNICK', 'SNIFF', 'SNIPS', 'SNORE', 'SNORT', 'SOBER',
  'SOLAR', 'SOLID', 'SOLVE', 'SORRY', 'SOUND', 'SOUTH', 'SPACE', 'SPARE', 'SPARK', 'SPEAK',
  'SPEAR', 'SPEED', 'SPELL', 'SPEND', 'SPICE', 'SPICY', 'SPIED', 'SPIKE', 'SPILL', 'SPINE',
  'SPINY', 'SPIRE', 'SPITE', 'SPLIT', 'SPOIL', 'SPOKE', 'SPOOF', 'SPOON', 'SPORT', 'SPOTS',
  'SPRAY', 'SPURN', 'SQUAD', 'STACK', 'STAFF', 'STAGE', 'STAIN', 'STAIR', 'STAKE', 'STALE',
  'STALK', 'STALL', 'STAMP', 'STAND', 'STARK', 'STARS', 'START', 'STATE', 'STAYS', 'STEAD',
  'STEAK', 'STEAL', 'STEAM', 'STEEL', 'STEEP', 'STEER', 'STEMS', 'STEPS', 'STICK', 'STIFF',
  'STILL', 'STILT', 'STING', 'STINK', 'STINT', 'STOCK', 'STOIC', 'STOKE', 'STOLE', 'STOMP',
  'STONE', 'STOOL', 'STORE', 'STORK', 'STORM', 'STORY', 'STOVE', 'STRAP', 'STRAW', 'STRAY',
  'STUCK', 'STUDY', 'STUFF', 'STYLE', 'SUGAR', 'SUITE', 'SUNNY', 'SUPER', 'SURGE', 'SUSHI',
  'SWAMP', 'SWEAR', 'SWEAT', 'SWEEP', 'SWEET', 'SWELL', 'SWIFT', 'SWING', 'SWISS', 'SWORD',
  'SWORE', 'SWORN', 'SWUNG', 'TABLE', 'TAKEN', 'TALES', 'TALKS', 'TANKS', 'TAPES', 'TASTE',
  'TAXES', 'TEACH', 'TEAMS', 'TEARS', 'TEASE', 'TEETH', 'TEMPO', 'TENDS', 'TENTH', 'TERMS',
  'TERSE', 'TESTS', 'THANK', 'THEFT', 'THEIR', 'THEME', 'THERE', 'THESE', 'THICK', 'THIEF',
  'THIGH', 'THING', 'THINK', 'THIRD', 'THORN', 'THOSE', 'THREE', 'THREW', 'THROW', 'THUMB',
  'TIGER', 'TIGHT', 'TILES', 'TIMER', 'TIMES', 'TIRED', 'TITLE', 'TOAST', 'TODAY', 'TOKEN',
  'TOMBS', 'TONES', 'TOOLS', 'TOOTH', 'TOPIC', 'TORCH', 'TOTAL', 'TOUCH', 'TOUGH', 'TOWEL',
  'TOWER', 'TOXIC', 'TRACE', 'TRACK', 'TRADE', 'TRAIL', 'TRAIN', 'TRAIT', 'TRAMP', 'TRASH',
  'TREAD', 'TREAT', 'TREED', 'TREES', 'TREND', 'TRIAL', 'TRIBE', 'TRICK', 'TRIED', 'TRIES',
  'TRIPE', 'TRUCK', 'TRULY', 'TRUNK', 'TRUST', 'TRUTH', 'TULIP', 'TUNER', 'TUNES', 'TUNIC',
  'TURBO', 'TUTOR', 'TWICE', 'TWINS', 'TWIST', 'TYING', 'UNCLE', 'UNDER', 'UNDUE', 'UNION',
  'UNITE', 'UNITY', 'UNTIL', 'UPPER', 'UPSET', 'URBAN', 'URGED', 'USAGE', 'USERS', 'USING',
  'USUAL', 'VALID', 'VALUE', 'VALVE', 'VAPOR', 'VAULT', 'VEGAN', 'VENOM', 'VENUE', 'VERSE',
  'VIDEO', 'VIEWS', 'VILLA', 'VINYL', 'VIOLA', 'VIRAL', 'VIRUS', 'VISIT', 'VITAL', 'VIVID',
  'VOCAL', 'VOICE', 'VOTER', 'WAGES', 'WAGON', 'WAIST', 'WASTE', 'WATCH', 'WATER', 'WAVES',
  'WEARY', 'WEAVE', 'WEDGE', 'WEIGH', 'WEIRD', 'WHALE', 'WHEAT', 'WHEEL', 'WHERE', 'WHICH',
  'WHILE', 'WHINE', 'WHINY', 'WHIPS', 'WHITE', 'WHOLE', 'WHOSE', 'WIDEN', 'WIDOW', 'WIDTH',
  'WIELD', 'WITCH', 'WOMAN', 'WOMEN', 'WORLD', 'WORMS', 'WORRY', 'WORSE', 'WORST', 'WORTH',
  'WOULD', 'WOUND', 'WRATH', 'WRECK', 'WREST', 'WRIST', 'WRITE', 'WRONG', 'WROTE', 'YACHT',
  'YEARS', 'YEAST', 'YIELD', 'YOUNG', 'YOUTH', 'ZEBRA', 'ZONES',
};

late final Map<String, List<String>> neighbors = () {
  final m = <String, List<String>>{};
  for (final w in wordLadderBank) {
    final n = <String>[];
    for (final o in wordLadderBank) {
      if (w != o && oneApart(w, o)) n.add(o);
    }
    m[w] = n;
  }
  return m;
}();

List<String>? bfs(String start, String end, int wordCount) {
  final depth = wordCount - 1;
  final q = <List<String>>[[start]];
  while (q.isNotEmpty) {
    final path = q.removeAt(0);
    if (path.length - 1 == depth) {
      if (oneApart(path.last, end)) return [...path, end];
      continue;
    }
    if (path.length > depth) continue;
    final last = path.last;
    for (final w in neighbors[last]!) {
      if (path.contains(w)) continue;
      q.add([...path, w]);
    }
  }
  return null;
}

void main(List<String> args) {
  final len = int.parse(args.isEmpty ? '20' : args[0]);
  final need = int.parse(args.length < 2 ? '10' : args[1]);
  final used = <String>{};
  var found = 0;
  final starts = wordLadderBank.toList()..sort();
  for (final start in starts) {
    for (final end in starts) {
      if (start == end) continue;
      final key = '$start->$end';
      if (used.contains(key)) continue;
      final p = bfs(start, end, len);
      if (p == null) continue;
      final sig = p.join(',');
      if (used.contains(sig)) continue;
      used.add(sig);
      used.add(key);
      print('${found + 1}: $start -> $end');
      print(p.join(','));
      print('');
      found++;
      if (found >= need) return;
    }
  }
  stderr.writeln('Only found $found paths of length $len');
}
