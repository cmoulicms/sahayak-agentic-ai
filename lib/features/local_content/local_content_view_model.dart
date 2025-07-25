import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:myapp/features/generated_content/generated_content_model.dart';
import 'package:myapp/features/prompt/prompt_model.dart';
import 'package:myapp/services/filestore.dart';
import 'package:myapp/services/vertexai.dart';
import 'package:myapp/util/filter_enums.dart';

class LocalContentViewModel extends ChangeNotifier {
  LocalContentViewModel({
    required this.multiModalModel,
    required this.textModel,
  });

  final GenerativeModel multiModalModel;
  final GenerativeModel textModel;
  bool loadingNewContent = false;

  PromptData userPrompt = PromptData.empty();
  TextEditingController promptTextController = TextEditingController();

  String badImageFailure =
      "The recipe request either does not contain images, or does not contain images of food items. I cannot recommend a recipe.";

  GeneratedContent? generatedContent;
  String? _geminiFailureResponse;
  String? get geminiFailureResponse => _geminiFailureResponse;
  set geminiFailureResponse(String? value) {
    _geminiFailureResponse = value;
    notifyListeners();
  }

  void notify() => notifyListeners();

  // void addImage(XFile image) {
  //   userPrompt.images!.insert(0, image);
  //   notifyListeners();
  // }

  // void removeImage(XFile image) {
  //   userPrompt.images!.removeWhere((el) => el.path == image.path);
  //   notifyListeners();
  // }

  void resetPrompt() {
    userPrompt = PromptData.empty();
    notifyListeners();
  }

  // Creates an ephemeral prompt with additional text that the user shouldn't be
  // concerned with to send to Gemini, such as formatting.
  PromptData buildPrompt() {
    return PromptData(
      query: userPrompt.query,
      textInput: mainPrompt,
      standards: userPrompt.selectedStandards,
      language: userPrompt.language,
      additionalTextInputs: [format],
    );
  }

  Future<void> submitPrompt(
    String query,
    String language,
    String standard,
  ) async {
    loadingNewContent = true;
    notifyListeners();
    // Create an ephemeral PromptData, preserving the user prompt data without
    // adding the additional context to it.
    // var model = userPrompt.images!.isEmpty ? textModel : multiModalModel;
    var model = textModel;
    List<StandardsFilter> castStandard = [
      StandardsFilter.values.firstWhere(
        (e) => e.name.toLowerCase() == standard.toLowerCase(),
        orElse: () => StandardsFilter.None, // fallback if no match
      ),
    ];
    userPrompt.query = query;
    userPrompt.language = language;
    userPrompt.selectedStandards = castStandard;
    final prompt = buildPrompt();

    try {
      final content = await GeminiService.generateContent(model, prompt);

      // handle no image or image of not-food
      if (content.text != null && content.text!.contains(badImageFailure)) {
        geminiFailureResponse = badImageFailure;
      } else {
        generatedContent = GeneratedContent.fromGeneratedContent(content);
      }
    } catch (error) {
      geminiFailureResponse = 'Failed to reach Gemini. \n\n$error';
      if (kDebugMode) {
        print(error);
      }
      loadingNewContent = false;
    }

    loadingNewContent = false;
    resetPrompt();
    notifyListeners();
  }

  void saveGeneratedContent() {
    FirestoreService.saveGeneratedContent(generatedContent!);
  }

  // void addBasicIngredients(Set<BasicIngredientsFilter> ingredients) {
  //   userPrompt.selectedBasicIngredients.addAll(ingredients);
  //   notifyListeners();
  // }

  // void addCategoryFilters(Set<CuisineFilter> categories) {
  //   userPrompt.selectedCuisines.addAll(categories);
  //   notifyListeners();
  // }

  // void addDietaryRestrictionFilter(
  //   Set<DietaryRestrictionsFilter> restrictions,
  // ) {
  //   userPrompt.selectedDietaryRestrictions.addAll(restrictions);
  //   notifyListeners();
  // }

  String get mainPrompt {
    return '''

You are an assistant to the Teacher in generating the local specific content. 
The teacher's request: ${userPrompt.query}
Generate the response in ${userPrompt.language} for the class ${userPrompt.selectedStandards}

${promptTextController.text.isNotEmpty ? promptTextController.text : ''}
''';
  }

  final String format = '''
Return the valid JSON using the following structure:
{
  "id": \$uniqueId,
  "title": \$generatedContentTitle,
 "text": \$generatedContent,
 "language": \$language,
 "standard": \$class

}
  
uniqueId should be unique and of type String. 
title, response should be of String type. 
''';
}
