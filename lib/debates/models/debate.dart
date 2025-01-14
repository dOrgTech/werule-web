// lib/debates/models/debate.dart

import 'dart:convert';
import 'package:Homebase/entities/org.dart';
import 'package:crypto/crypto.dart';
import 'argument.dart';

class Debate {
  Org org;
  String? hash;
  String title;
  Argument rootArgument;

  double debateScore = 0;

  Debate({
    required this.org,
    required this.title,
    required this.rootArgument,
  }) {
    // Generate a hash for the debate
    String input = title + rootArgument.content;
    List<int> bytes = utf8.encode(input);
    String sha256Hash = sha256.convert(bytes).toString();
    hash = sha256Hash;

    // Initialize the debate score
    debateScore = Argument.computeScore(rootArgument);
  }

  /// Convenience method to recalc the entire debate
  void recalcScore() {
    debateScore = Argument.computeScore(rootArgument);
  }
}
