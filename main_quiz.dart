import 'dart:io';
import 'package:collection/collection.dart';

/// Base class for Question
class Question {
  String title;
  List<String> options;

  Question(this.title, this.options);

  // Default implementation (can be overridden by subclasses)
  bool isCorrect(List<String> answers) {
    return false; // Default to incorrect; 
  }

  List<String> getCorrectAnswers() {
    return []; // Default to empty; 
  }
}

/// SingleChoiceQuestion class that only allows one correct answer
class SingleChoiceQuestion extends Question {
  String correctAnswer;

  SingleChoiceQuestion(String title, List<String> options, this.correctAnswer)
      : super(title, options);

  @override
  bool isCorrect(List<String> answers) {
    return answers.length == 1 && answers[0].toLowerCase() == correctAnswer.toLowerCase();
  }

  @override
  List<String> getCorrectAnswers() {
    return [correctAnswer];
  }
}

/// MultipleChoiceQuestion class that allows multiple correct answers
class MultipleChoiceQuestion extends Question {
  List<String> correctAnswers;

  MultipleChoiceQuestion(String title, List<String> options, this.correctAnswers)
      : super(title, options);

  @override
  bool isCorrect(List<String> answers) {
    return const ListEquality().equals(
      answers.map((a) => a.toLowerCase()).toList(),
      correctAnswers.map((a) => a.toLowerCase()).toList(),
    );
  }

  @override
  List<String> getCorrectAnswers() {
    return correctAnswers;
  }
}

// Participant and Quiz classes remain the same as in your original code
class Participant {
  String firstName;
  String lastName;
  int score = 0;

  Participant(this.firstName, this.lastName);

  String get fullName => '$firstName $lastName';
}

class Quiz {
  List<Question> questions = [];

  void addQuestion(Question question) {
    questions.add(question);
  }

  void calculateScore(Participant participant, List<List<String>> participantAnswers) {
    int totalScore = 0;
    List<String> wrongAnswers = []; // List to track wrong answers

    for (int i = 0; i < questions.length; i++) {
      if (questions[i].isCorrect(participantAnswers[i])) {
        totalScore++;
      } else {
        // Collect the question title and incorrect answer(s)
        wrongAnswers.add('Question: "${questions[i].title}" - Your answer: ${participantAnswers[i].join(', ')}');
      }
    }
    participant.score = totalScore;

    // Display wrong answers and their correct responses
    showIncorrectAnswers(wrongAnswers);
  }

  void showIncorrectAnswers(List<String> wrongAnswers) {
    if (wrongAnswers.isNotEmpty) {
      print('\nYou answered the following questions incorrectly:');
      for (var wrongAnswer in wrongAnswers) {
        print(wrongAnswer);
      }
      print('Here are the correct answers:');
      for (var question in questions) {
        if (!question.isCorrect([])) { // Check if the question was answered incorrectly
          print('Correct answer(s) for: "${question.title}" - ${question.getCorrectAnswers().join(', ')}');
        }
      }
    } else {
      print('Congratulations! You answered all questions correctly.');
    }
  }

  void displayResult(Participant participant) {
    print('\n${participant.fullName} scored: ${participant.score} / ${questions.length}');
  }
}

void main() {
  // Create a new quiz
  Quiz quiz = Quiz();
  // Add questions to the quiz
  quiz.addQuestion(SingleChoiceQuestion(
    'What is the capital of Cambodia?',
    ['Vientiane', 'Bangkok', 'Phnom Penh', 'Hanoi'],
    'Phnom Penh',
  ));
  quiz.addQuestion(SingleChoiceQuestion(
    'Which famous temple complex is located in Cambodia?',
    ['Borobudur', 'Angkor Wat', 'Wat Arun', 'Shwedagon Pagoda'],
    'Angkor Wat',
  ));
  quiz.addQuestion(SingleChoiceQuestion(
    'What is the primary language spoken in Cambodia?',
    ['Thai', 'Lao', 'Vietnamese', 'Khmer'],
    'Khmer',
  ));
  quiz.addQuestion(MultipleChoiceQuestion(
    'Which of the following are Cambodian provinces?',
    ['Siem Reap', 'Chiang Mai', 'Kampong Cham', 'Battambang'],
    ['Siem Reap', 'Battambang', 'Kampong Cham'],
  ));
  quiz.addQuestion(MultipleChoiceQuestion(
    'Which of the following are traditional Cambodian dishes?',
    ['Amok', 'Pho', 'Lok Lak', 'Banh Mi'],
    ['Amok', 'Lok Lak'],
  ));

  // Create a participant
  stdout.write('Enter your first name: ');
  String firstName = stdin.readLineSync() ?? '';
  stdout.write('Enter your last name: ');
  String lastName = stdin.readLineSync() ?? '';
  Participant participant = Participant(firstName, lastName);

  // List to store participant answers
  List<List<String>> participantAnswers = [];

  // Ask each question and collect answers
  for (var question in quiz.questions) {
    print('\nQuestion: ${question.title}');
    for (int i = 0; i < question.options.length; i++) {
      print('${i + 1}. ${question.options[i]}');
    }

    if (question is SingleChoiceQuestion) {
      stdout.write('Enter the number of your answer: ');
      String? answer = stdin.readLineSync();
      if (answer != null && int.tryParse(answer) != null) {
        int answerIndex = int.parse(answer) - 1;
        if (answerIndex >= 0 && answerIndex < question.options.length) {
          participantAnswers.add([question.options[answerIndex]]);
        } else {
          print('Invalid choice. Answer skipped.');
          participantAnswers.add([]);
        }
      }
    } else if (question is MultipleChoiceQuestion) {
      stdout.write('Enter the numbers of all correct answers separated by commas (e.g., 1,3): ');
      String? answer = stdin.readLineSync();
      if (answer != null) {
        List<String> selectedAnswers = answer.split(',')
            .map((choice) => choice.trim())
            .where((choice) => int.tryParse(choice) != null)
            .map((choice) => question.options[int.parse(choice) - 1])
            .toList();
        participantAnswers.add(selectedAnswers);
      } else {
        participantAnswers.add([]);
      }
    }
  }

  // Calculate and display the participant's score
  quiz.calculateScore(participant, participantAnswers);
  quiz.displayResult(participant);
}


