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

  double sentiment = 0; // Single metric for the entire debate

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
    sentiment = Argument.computeScore(rootArgument);
  }
}
