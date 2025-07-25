import 'package:firebase_ai/firebase_ai.dart';
import '../features/prompt/prompt_model.dart';

class GeminiService {
  /*
  This is class used to ccall the Gemini API for getting the response
*/
  static Future<GenerateContentResponse> generateContent(
    GenerativeModel model,
    PromptData prompt,
  ) async {
    return await GeminiService.generateContentFromText(model, prompt);
  }

  static Future<GenerateContentResponse> generateContentFromText(
    GenerativeModel model,
    PromptData prompt,
  ) async {
    final mainText = TextPart(prompt.textInput);
    final additionalTextParts = prompt.additionalTextInputs!.map(
      (t) => TextPart(t),
    );

    // if (prompt.images != null) {
    //   final bytes = await (prompt.images?[0]!.readAsBytes());
    //   //final imagePart = Part.fromBytes(mimeType: 'image/jpeg', bytes: bytes);

    //   return await model.generateContent([
    //     Content.multi([TextPart(mainText.text)]),
    //   ]);
    // } else {
    //   return await model.generateContent([
    //     Content.text(
    //       '${mainText.text} in ${language.text} language for class ${standards.text}',
    //     ),
    //   ]);
    // }
    final input = [
      Content.multi([mainText, ...additionalTextParts]),
    ];
    return await model.generateContent(input);
  }
}
