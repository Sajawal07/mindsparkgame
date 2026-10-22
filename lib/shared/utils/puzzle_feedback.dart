import '../../data/services/audio_service.dart';
import '../../data/services/haptics_service.dart';

void playAnswerFeedback(bool correct) {
  AudioService.instance.playSfx(correct ? Sfx.correct : Sfx.wrong);
  if (correct) {
    HapticsService.correct();
  } else {
    HapticsService.wrong();
  }
}
