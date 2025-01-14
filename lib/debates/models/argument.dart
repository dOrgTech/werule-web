// lib/debates/models/argument.dart

class Argument {
  final String content;
  Argument? parent;

  final String author;
  final double weight; // The original voting power assigned by the user

  double score = 0; // The net effect after factoring in children

  List<Argument> proArguments;
  List<Argument> conArguments;

  Argument({
    required this.content,
    this.parent,
    required this.author,
    required this.weight,
    List<Argument>? proArguments,
    List<Argument>? conArguments,
  })  : proArguments = proArguments ?? [],
        conArguments = conArguments ?? [];

  int get proCount => proArguments.length;
  int get conCount => conArguments.length;

  /// Recomputes the net score of this entire subtree:
  ///    score = weight + sum(pro child scores > 0) - sum(con child scores > 0)
  static double computeScore(Argument arg) {
    double sum = arg.weight;
    // Recurse into children
    for (var child in arg.proArguments) {
      double childScore = computeScore(child);
      // only add if childScore is strictly > 0
      if (childScore > 0) {
        sum += childScore;
      }
    }
    for (var child in arg.conArguments) {
      double childScore = computeScore(child);
      // only subtract if childScore is strictly > 0
      if (childScore > 0) {
        sum -= childScore;
      }
    }
    arg.score = sum;
    return sum;
  }
}
