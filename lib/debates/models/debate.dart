// lib/debates/debate.dart

import 'dart:convert';
import 'package:Homebase/entities/org.dart';
import 'package:crypto/crypto.dart';
import 'argument.dart';

class Debate {
  Org org;
  String? hash;
  String title;
  Argument rootArgument;

  /// This is shown in the UI as the "Debate sentiment" or "Debate score",
  /// but it is calculated ONLY from: trump univerasity asdnhand bondy seems poised to become the
  ///   - The root argument's weight she has a record of corrupt dealings with trump and other corporationsd
  ///  now the nomination of pam bundy falls into the category that electrions have consequences but iir
  ///   - The immediate pro/con children of the root (if they have net score > 0).
  double sentiment = 0;

  Debate({
    required this.org,
    required this.title,
    required this.rootArgument,
  }) {
    final input = title + rootArgument.content;
    final bytes = utf8.encode(input);
    hash = sha256.convert(bytes).toString();

    recalc();
  }

  void recalc() {
    // 1) Compute each argument's local net 'score' from its subtree
    Argument.computeScore(rootArgument);

    // 2) Now compute the debate's overall "score" (sentiment) from:
    //      rootArgument.weight
    //    + sum of top-level pro children if they have > 0 score
    //    - sum of top-level con children if they have > 0 score
    double sum = rootArgument.weight;

    for (final child in rootArgument.proArguments) {
      if (child.score > 0) {
        sum += child.weight;
      }
    }
    for (final child in rootArgument.conArguments) {
      if (child.score > 0) {
        sum -= child.weight;
      }
    }

    sentiment = sum;
  }
}
