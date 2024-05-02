// ignore_for_file: non_constant_identifier_names

import './hw7.dart';
import 'package:test/test.dart';

// Constants for testing
var ZERO = 0.0;
var ONE = 1.0;
var TWO = 2.0;
var THREE = 3.0;
var FOUR = 4.0;
var FIVE = 5.0;
var SIX = 6.0;
var SEVEN = 7.0;
var NINE = 9.0;
var TEN = 10.0;

void main() {
  group("[Point tests]", () {
    Point a = Point(THREE, FIVE);

    test("initialized properly", () {
      expect(a.x == THREE && a.y == FIVE, isTrue);
    });

    test("evalProg should return self", () {
      expect((a.evalProg([]) == a), isTrue);
    });

    test("preprocessProg should return self", () {
      expect(a.preprocessProg() == a, isTrue);
    });

    test("shift should shift by (dx, dy)", () {
      var a1 = a.shift(THREE, FIVE);
      expect((a1.x == SIX && a1.y == TEN), isTrue);
    });

    test("intersect test 1", () {
      var a2 = a.intersect(Point(THREE, FIVE)) as Point;
      expect((a2.x == THREE && a2.y == FIVE), isTrue);
    });

    test("intersect test 1", () {
      var a3 = a.intersect(Point(FOUR, FIVE));
      expect((a3.runtimeType == NoPoints), isTrue);
    });
  });

  group("[Line tests]", () {
    var b = Line(THREE, FIVE);

    test("Line initialized properly", () {
      expect((b.m == THREE && b.b == FIVE), isTrue);
    });

    test("evalProg should return self", () {
      expect(b.evalProg([]) == b, isTrue);
    });

    test("preprocessProg should return self", () {
      expect(b.preprocessProg() == b, isTrue);
    });

    var b1 = b.shift(THREE, FIVE);
    test("shift should shift properly", () {
      expect(b1.m == THREE && b1.b == ONE, isTrue);
    });

    var b2 = b.intersect(Line(THREE, FIVE));
    test("intersect test 1", () {
      expect(b2.runtimeType == Line && (b2 as Line).m == THREE && b2.b == FIVE,
          isTrue);
    });

    var b3 = b.intersect(Line(THREE, FOUR));
    test("intersect test 2", () {
      expect(b3.runtimeType == NoPoints, isTrue);
    });
  });

  group("[VerticalLine tests]", () {
    var c = VerticalLine(THREE);

    test("VerticalLine initialized properly", () {
      expect(c.x == THREE, isTrue);
    });

    test("evalProg should return self", () {
      expect(c.evalProg([]) == c, isTrue);
    });

    test("preprocessProg should return self", () {
      expect(c.preprocessProg() == c, isTrue);
    });

    test("shift should shift properly", () {
      var c1 = c.shift(THREE, FIVE);
      expect(c1.x == SIX, isTrue);
    });

    test("intersect test 1", () {
      var c2 = c.intersect(VerticalLine(THREE));
      expect(c2.runtimeType == VerticalLine && (c2 as VerticalLine).x == THREE,
          isTrue);
    });

    test("intersect test 2", () {
      var c3 = c.intersect(VerticalLine(FOUR));
      expect(c3.runtimeType == NoPoints, isTrue);
    });
  });

  group("[LineSegment tests]", () {
    var d = LineSegment(ONE, TWO, -THREE, -FOUR);

    test("evalProg should return self", () {
      expect(d.evalProg([]) == d, isTrue);
    });

    test("preprocessProg should convert to a Point if ends are real_close", () {
      var d1 = LineSegment(ONE, TWO, ONE, TWO);
      var d2 = d1.preprocessProg();
      expect(d2.runtimeType == Point && (d2 as Point).x == ONE && d2.y == TWO,
          isTrue);
    });

    var d3 = d.preprocessProg() as LineSegment;
    test("preprocessProg should make x1 and y1 on the left of x2 and y2", () {
      expect(d3.x1 == -THREE && d3.y1 == -FOUR && d3.x2 == ONE && d3.y2 == TWO,
          isTrue);
    });

    test("shift should shift properly", () {
      var d4 = d3.shift(THREE, FIVE);
      expect(d4.x1 == ZERO && d4.y1 == ONE && d4.x2 == FOUR && d4.y2 == SEVEN,
          isTrue);
    });

    test("intersect test 1", () {
      var d5 = d3.intersect(LineSegment(-THREE, -FOUR, ONE, TWO));
      expect(d5.runtimeType == LineSegment, isTrue);
      var d5ls = d5 as LineSegment;
      expect(
          d5.runtimeType == LineSegment &&
              d5ls.x1 == -THREE &&
              d5ls.y1 == -FOUR &&
              d5ls.x2 == ONE &&
              d5ls.y2 == TWO,
          isTrue);
    });

    test("intersect test 2", () {
      var d6 = d3.intersect(LineSegment(TWO, THREE, FOUR, FIVE));
      expect(d6.runtimeType == NoPoints, isTrue);
    });
  });

  group("[Intersect tests]", () {
    var i = Intersect(LineSegment(-ONE, -TWO, THREE, FOUR),
        LineSegment(THREE, FOUR, -ONE, -TWO));

    var i1 = i.preprocessProg().evalProg([]);
    test("evalProg should return the intersect between e1 and e2", () {
      expect(i1.runtimeType == LineSegment, isTrue);
      var i2 = i1 as LineSegment;
      expect(i2.x1 == -ONE && i2.y1 == -TWO && i2.x2 == THREE && i2.y2 == FOUR,
          isTrue);
    });

    test("parallel lines", () {
      var li = LineSegment(ONE, TWO, THREE, FOUR);
      var i3 = Intersect(li, Shift(TWO, 0.0, li)).preprocessProg().evalProg([]);
      expect(i3.runtimeType == NoPoints, isTrue);
    });
  });

  group("[Var tests]", () {
    var v = Var("a");

    test("evalProg is working properly", () {
      var v1 = v.evalProg([("a", Point(THREE, FIVE))]);
      expect(
          v1.runtimeType == Point && (v1 as Point).x == THREE && v1.y == FIVE,
          isTrue);
    });

    test("preprocessProg should return self", () {
      expect(v.preprocessProg() == v, isTrue);
    });
  });

  group("[Let tests]", () {
    var l = Let("a", LineSegment(-ONE, -TWO, THREE, FOUR),
        Intersect(Var("a"), LineSegment(THREE, FOUR, -ONE, -TWO)));
    var l1 = l.preprocessProg().evalProg([]) as LineSegment;
    test("evalProg should evaluate e2 after adding [s, e1] to the environment",
        () {
      expect(l1.x1 == -ONE && l1.y1 == -TWO && l1.x2 == THREE && l1.y2 == FOUR,
          isTrue);
    });
  });

  group("[Let Variable Shadowing Test]", () {
    var l2 = Let(
        "a",
        LineSegment(-ONE, -TWO, THREE, FOUR),
        Let("b", LineSegment(THREE, FOUR, -ONE, -TWO),
            Intersect(Var("a"), Var("b"))));

    var l3 =
        l2.preprocessProg().evalProg([("a", Point(ZERO, ZERO))]) as LineSegment;
    test("evalProg should evaluate e2 after adding [s, e1] to the environment",
        () {
      expect(l3.x1 == -ONE && l3.y1 == -TWO && l3.x2 == THREE && l3.y2 == FOUR,
          isTrue);
    });

    group("[Shift tests]", () {
      var s = Shift(THREE, FIVE, LineSegment(-ONE, -TWO, THREE, FOUR));

      var s1 = s.preprocessProg().evalProg([]) as LineSegment;
      test("Shift should shift e by dx and dy", () {
        expect(s1.x1 == TWO && s1.y1 == THREE && s1.x2 == SIX && s1.y2 == NINE,
            isTrue);
      });
    });
  });
}
