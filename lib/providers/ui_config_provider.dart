import 'package:flutter_riverpod/flutter_riverpod.dart';

// データの種類を明確に定義
class UIConfig {
  final String relieverName;
  final String pillName;
  final List<String> symptoms;
  final List<String> triggers;

  UIConfig({
    required this.relieverName,
    required this.pillName,
    required this.symptoms,
    required this.triggers,
  });

  UIConfig copyWith({
    String? relieverName,
    String? pillName,
    List<String>? symptoms,
    List<String>? triggers,
  }) {
    return UIConfig(
      relieverName: relieverName ?? this.relieverName,
      pillName: pillName ?? this.pillName,
      symptoms: symptoms ?? this.symptoms,
      triggers: triggers ?? this.triggers,
    );
  }
}

class UIConfigNotifier extends StateNotifier<UIConfig> {
  UIConfigNotifier() : super(UIConfig(
    relieverName: 'メプチン',
    pillName: 'プレドニン',
    symptoms: ['咳', '喘鳴', '息苦しさ', ],
    triggers: ['埃・ダニ', '運動', '気圧の変化', 'タバコ'],
  ));

  void updateMedicineNames({required String reliever, required String pill}) {
    state = state.copyWith(relieverName: reliever, pillName: pill);
  }

  void updateItems(String category, List<String> newList) {
    if (category == '症状') {
      state = state.copyWith(symptoms: newList);
    } else if (category == '誘因') {
      state = state.copyWith(triggers: newList);
    }
  }
}

final uiConfigProvider = StateNotifierProvider<UIConfigNotifier, UIConfig>((ref) {
  return UIConfigNotifier();
});