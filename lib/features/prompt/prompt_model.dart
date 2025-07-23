import 'package:image_picker/image_picker.dart';
import '../../util/filter_enums.dart';

class PromptData {
  PromptData({
    required this.query,
    required this.textInput,
    required this.language,
    List<StandardsFilter>? standards,
    List<String>? additionalTextInputs,
  }) : selectedStandards = standards ?? [],
       additionalTextInputs = additionalTextInputs ?? [];

  PromptData.empty()
    : textInput = '',
      query = '',
      language = '',
      selectedStandards = [],
      additionalTextInputs = [];

  String get standards {
    return selectedStandards.map((catFilter) => catFilter.name).join(",");
  }

  String query;
  String textInput;
  String language;
  List<StandardsFilter> selectedStandards;
  List<String>? additionalTextInputs;

  PromptData copyWith({
    String? query,
    String? textInput,
    String? language,
    List<StandardsFilter>? standards,
    List<String>? additionalTextInputs,
  }) {
    return PromptData(
      query: query ?? this.query,
      textInput: textInput ?? this.textInput,
      language: language ?? this.language,
      standards: standards ?? selectedStandards,
      additionalTextInputs: additionalTextInputs ?? this.additionalTextInputs,
    );
  }
}
