import "package:flutter/material.dart";


String shortenString(String input) {
  if (input.length <= 8) {
    return input;
  } else {
    return input.substring(0, 5) + "..." + input.substring(input.length - 5);
  }
}
