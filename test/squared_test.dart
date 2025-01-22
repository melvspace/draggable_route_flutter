import 'package:draggable_route/src/utility/squared_num_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test squared extension", () {
    expect(1.squared, 1);
    expect(2.squared, 4);
    expect((-2).squared, 4);
    expect(0.squared, 0);
    expect(1.5.squared, 2.25);
  });
}
