

// shuffles the option and updates if the correct answer is affected by the shuffle 
Iterable<Option> shuffleIterable<Option>(Iterable<Option> iterable) {
  var list = List<Option>.from(iterable);
  list.shuffle();
  return list;
}