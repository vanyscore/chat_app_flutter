import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/counter.dart';

void main() {
  test('test counter class', () {
    final counter = Counter();

    print(counter.value);

    counter.increment();

    print(counter.value);

    counter.decrement();

    print(counter.value);

    expect(counter.value, 0);
  });
}