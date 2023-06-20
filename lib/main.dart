import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Quiz {
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({required this.title, required this.description, required this.questions});
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final bool hasTextAnswer;
  final String correctAnswerText;
  final String hint;

  int attempts = 0; // Nombre d'essais effectués pour la question
  bool isAnsweredCorrectly = false;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.hasTextAnswer,
    this.correctAnswerText = '',
    this.hint = '',
  });
}

class ImageQuestion extends Question {
  final String imageUrl;
  final String correctAnswerImageUrl;

  ImageQuestion({
    required String questionText,
    required this.imageUrl,
    required this.correctAnswerImageUrl,
    List<String> options = const [],
    int correctAnswerIndex = 0,
    bool hasTextAnswer = false,
    String correctAnswerText = '',
    String hint = '',
  }) : super(
          questionText: questionText,
          options: options,
          correctAnswerIndex: correctAnswerIndex,
          hasTextAnswer: hasTextAnswer,
          correctAnswerText: correctAnswerText,
          hint: hint,
        );
}

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  final List<Quiz> quizzes = [
    Quiz(
      title: 'Quiz 1',
      description: 'Un quiz sur des sujets divers.',
      questions: [
        Question(
          questionText: 'Quelle est la capitale de la France ?',
          options: ['Paris', 'Londres', 'Berlin', 'Rome'],
          correctAnswerIndex: 0,
          hasTextAnswer: false,
          hint: 'C\'est aussi la ville la plus peuplée du pays.',
        ),
        Question(
          questionText: 'Qui a peint la Joconde ?',
          options: ['Leonardo da Vinci', 'Pablo Picasso', 'Vincent van Gogh', 'Michelangelo'],
          correctAnswerIndex: 0,
          hasTextAnswer: false,
          hint: 'C\'est un peintre italien de la Renaissance.',
        ),
        Question(
          questionText: 'Quelle est la monnaie officielle du Japon ?',
          options: [],
          correctAnswerIndex: 0,
          hasTextAnswer: true,
          correctAnswerText: 'Yen',
          hint: 'Cela commence par la lettre Y.',
        ),
      ],
    ),
    Quiz(
      title: 'Quiz 2',
      description: 'Un autre quiz sur des sujets variés.',
      questions: [
        Question(
          questionText: 'Quelle est la planète la plus proche du soleil ?',
          options: ['Vénus', 'Mars', 'Mercure', 'Jupiter'],
          correctAnswerIndex: 2,
          hasTextAnswer: false,
          hint: 'Il s\'agit de la planète la plus petite de notre système solaire.',
        ),
        Question(
          questionText: 'Quelle est la plus grande mer du monde ?',
          options: ['Mer Méditerranée', 'Mer Rouge', 'Mer Caspienne', 'Mer d\'Okhotsk'],
          correctAnswerIndex: 2,
          hasTextAnswer: false,
          hint: 'Elle est située entre l\'Asie et l\'Amérique et porte le nom d\'un océan.',
        ),
        Question(
          questionText: 'Quelle est la plus haute montagne du monde ?',
          options: [],
          correctAnswerIndex: -1,
          hasTextAnswer: true,
          correctAnswerText: 'Mont Everest',
          hint: 'Elle se trouve dans la chaîne de l\'Himalaya.',
        ),
      ],
    ),
    Quiz(
      title: 'Quiz 3',
      description: 'Un quiz avec des questions d\'identification d\'image.',
      questions: [
        ImageQuestion(
          questionText: 'Quel est cet animal ?',
          imageUrl: 'https://cdn.futura-sciences.com/sources/images/chien-min.jpeg',
          correctAnswerImageUrl: 'https://cdn.futura-sciences.com/sources/images/chien-min.jpeg',
          options: ['Chien', 'Chat', 'Lion', 'Tigre'],
          correctAnswerIndex: 0,
          hasTextAnswer: false,
          hint: 'C\'est un animal domestique courant.',
        ),
        ImageQuestion(
          questionText: 'Quel est cet instrument de musique ?',
          imageUrl: 'https://images.pexels.com/photos/164743/pexels-photo-164743.jpeg?cs=srgb&dl=pexels-pixabay-164743.jpg&fm=jpg',
          correctAnswerImageUrl: 'https://images.pexels.com/photos/164743/pexels-photo-164743.jpeg?cs=srgb&dl=pexels-pixabay-164743.jpg&fm=jpg',
          options: ['Guitare', 'Violon', 'Piano', 'Trompette'],
          correctAnswerIndex: 2,
          hasTextAnswer: false,
          hint: 'Cet instrument a des touches et des cordes.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizListScreen(quizzes: quizzes),
    );
  }
}

class QuizListScreen extends StatelessWidget {
  final List<Quiz> quizzes;

  QuizListScreen({required this.quizzes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeux Quiz'),
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return ListTile(
            title: Text(quiz.title),
            subtitle: Text(quiz.description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(quiz: quiz),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  QuizScreen({required this.quiz});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  ValueNotifier<int> currentQuestionIndexNotifier = ValueNotifier<int>(0);
  ValueNotifier<bool> isNextButtonEnabledNotifier = ValueNotifier<bool>(false);
  TextEditingController textAnswerController = TextEditingController();

  void checkAnswer(int selectedIndex) {
    final currentQuestion = widget.quiz.questions[currentQuestionIndex];

    if (currentQuestion.attempts >= 3) {
      showSnackBar('Vous avez atteint le nombre maximum d\'essais !');
      return;
    }

    if (currentQuestion.hasTextAnswer && currentQuestionIndex == 2) {
      final textAnswer = textAnswerController.text.trim();

      if (textAnswer.isEmpty) {
        showSnackBar('Veuillez entrer une réponse.');
        return;
      }

      if (textAnswer != currentQuestion.correctAnswerText) {
        currentQuestion.attempts++; // Incrémenter le nombre d'essais effectués
        showSnackBar('Réponse incorrecte. Réessayez !');
        showHintSnackBar(currentQuestion.hint);
      } else {
        setState(() {
          score++;
          isNextButtonEnabledNotifier.value = true;
          currentQuestion.isAnsweredCorrectly = true;
        });
      }
    } else {
      if (selectedIndex != currentQuestion.correctAnswerIndex) {
        currentQuestion.attempts++; // Incrémenter le nombre d'essais effectués
        showSnackBar('Réponse incorrecte. Réessayez !');
        showHintSnackBar(currentQuestion.hint);
      } else {
        setState(() {
          score++;
          isNextButtonEnabledNotifier.value = true;
          currentQuestion.isAnsweredCorrectly = true;
        });
      }
    }
  }

  void showHintSnackBar(String hint) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Indice: $hint'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      isNextButtonEnabledNotifier.value = false;
      textAnswerController.clear();
      for (final question in widget.quiz.questions) {
        question.attempts = 0; // Réinitialiser le nombre d'essais pour chaque question
        question.isAnsweredCorrectly = false;
      }
    });
  }

  @override
  void dispose() {
    currentQuestionIndexNotifier.dispose();
    isNextButtonEnabledNotifier.dispose();
    textAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= widget.quiz.questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz terminé !',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Text(
                'Score : $score / ${widget.quiz.questions.length}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: resetQuiz,
                child: Text('Rejouer'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Retour à la page principale'),
              ),
            ],
          ),
        ),
      );
    }

    final question = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${widget.quiz.questions.length}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              question.questionText,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            if (question is ImageQuestion) ...[
              Image.network(
                (question as ImageQuestion).imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.0),
            ],
            if (question.hasTextAnswer && currentQuestionIndex == 2) ...[
              TextField(
                controller: textAnswerController,
                onChanged: (text) {
                  setState(() {
                    isNextButtonEnabledNotifier.value = text.isNotEmpty;
                  });
                },
              ),
            ] else ...[
              Column(
                children: question.options.map((option) {
                  final optionIndex = question.options.indexOf(option);
                  return Container(
                    child: Row(
                      children: [
                        Radio(
                          value: optionIndex,
                          groupValue: null,
                          onChanged: (selectedIndex) {
                            checkAnswer(selectedIndex as int);
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          fillColor: question.isAnsweredCorrectly && optionIndex == question.correctAnswerIndex
                              ? MaterialStateProperty.all<Color>(Colors.green)
                              : question.isAnsweredCorrectly && optionIndex != question.correctAnswerIndex
                                  ? MaterialStateProperty.all<Color>(Colors.red)
                                  : null,
                        ),
                        SizedBox(width: 8.0),
                        Text(option),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: isNextButtonEnabledNotifier,
              builder: (context, isEnabled, child) {
                return ElevatedButton(
                  onPressed: isEnabled
                      ? () {
                          setState(() {
                            currentQuestionIndex++;
                            isNextButtonEnabledNotifier.value = false;
                          });
                        }
                      : null,
                  child: Text('Suivant'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}




