// lib/debates/models/argument.dart

import 'dart:math';

// Generates a random 4-6 character username, e.g. "X9za0"
String randomUsername() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  final length = 4 + rand.nextInt(3);
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
      .join();
}

class Argument {
  final String content;
  Argument? parent;
  final String author; // Either provided or auto-generated
  final double weight; // Raw voting power assigned at creation
  double score = 0; // Net effect after factoring children

  List<Argument> proArguments;
  List<Argument> conArguments;

  Argument({
    required this.content,
    this.parent,
    String? author, // If null, we generate a random username
    required this.weight,
    List<Argument>? proArguments,
    List<Argument>? conArguments,
  })  : proArguments = proArguments ?? [],
        conArguments = conArguments ?? [],
        author = author ?? randomUsername();

  int get proCount => proArguments.length;
  int get conCount => conArguments.length;

  /// Recompute net score of entire subtree:
  ///   score(arg) = arg.weight
  ///     + sum( score(pro child) if > 0 )
  ///     - sum( score(con child) if > 0 )
  ///
  /// If an argument's computed score <= 0, it is considered "invalid" (or cancelled),
  /// and it does not pass any of its weight up to its parent.
  static double computeScore(Argument arg) {
    double sum = arg.weight;
    for (var child in arg.proArguments) {
      final childScore = computeScore(child);
      if (childScore > 0) sum += childScore;
    }
    for (var child in arg.conArguments) {
      final childScore = computeScore(child);
      if (childScore > 0) sum -= childScore;
    }
    arg.score = sum;
    return sum;
  }
}
