// dart version of hw7

// ------------ abstract classes -----------
abstract class GeometryTerm {
  GeometryTerm preprocessProg();
  GeometryValue evalProg(List<(String, GeometryValue)> env);
}

abstract class GeometryExpression extends GeometryTerm {
  static const double epsilon = 0.00001;
}

abstract class GeometryValue extends GeometryTerm {
  bool realClose(double r1, double r2) {
    return (r1 - r2).abs() < GeometryExpression.epsilon;
  }

  bool realClosePoint(double x1, double y1, double x2, double y2) {
    return realClose(x1, x2) && realClose(y1, y2);
  }

  GeometryValue twoPointsToLine(double x1, double y1, double x2, double y2) {
    if (realClose(x1, x2)) {
      return VerticalLine(x1);
    } else {
      var m = (y2 - y1) / (x2 - x1);
      var b = y1 - m * x1;
      return Line(m, b);
    }
  }

  @override
  GeometryValue preprocessProg() => this;
  @override
  GeometryValue evalProg(List<(String, GeometryValue)> env) => this;

  GeometryValue shift(double dx, double dy);
  GeometryValue intersect(GeometryValue other);
  NoPoints intersectNoPoints(NoPoints np) => np;
  GeometryValue intersectPoint(Point p);
  GeometryValue intersectLine(Line line);
  GeometryValue intersectVerticalLine(VerticalLine vline);

  GeometryValue intersectLineSegment(LineSegment seg) {
    var lineResult = intersect(twoPointsToLine(seg.x1, seg.y1, seg.x2, seg.y2));
    return lineResult.intersectWithSegmentAsLineResult(seg);
  }

  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg);
}

// ------------ Values -----------
class NoPoints extends GeometryValue {
  @override
  NoPoints shift(double dx, double dy) {
    return this;
  }

  @override
  GeometryValue intersect(GeometryValue other) => other.intersectNoPoints(this);

  @override
  GeometryValue intersectLine(Line line) => this;

  @override
  GeometryValue intersectPoint(Point p) => this;

  @override
  GeometryValue intersectVerticalLine(VerticalLine vline) => this;

  @override
  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg) => this;
}

class Point extends GeometryValue {
  double x, y;
  Point(this.x, this.y);

  @override
  Point shift(double dx, double dy) => Point(x + dx, y + dy);

  @override
  GeometryValue intersect(GeometryValue other) => other.intersectPoint(this);

  @override
  GeometryValue intersectPoint(Point p) =>
      realClosePoint(x, y, p.x, p.y) ? this : NoPoints();

  @override
  GeometryValue intersectLine(Line line) =>
      realClose(y, line.m * x + line.b) ? this : NoPoints();

  @override
  GeometryValue intersectVerticalLine(VerticalLine vline) =>
      realClose(x, vline.x) ? this : NoPoints();

  @override
  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg) =>
      _inbetween(x, seg.x1, seg.x2) && _inbetween(y, seg.y1, seg.y2)
          ? this
          : NoPoints();

  bool _inbetween(double v, double end1, double end2) {
    var eps = GeometryExpression.epsilon;
    return ((end1 - eps <= v && v <= end2 + eps) ||
        (end2 - eps <= v && v <= end1 + eps));
  }
}

class Line extends GeometryValue {
  double m, b;
  Line(this.m, this.b);

  @override
  Line shift(double dx, double dy) => Line(m, b + dy - m * dx);

  @override
  GeometryValue intersect(GeometryValue other) => other.intersectLine(this);

  @override
  GeometryValue intersectPoint(Point p) => p.intersectLine(this);

  @override
  GeometryValue intersectLine(Line line) {
    var (m1, m2, b1, b2) = (m, line.m, b, line.b);

    if (realClose(m1, m2)) {
      if (realClose(b1, b2)) {
        return this;
      } else {
        return NoPoints();
      }
    } else {
      var x = (b2 - b1) / (m1 - m2);
      var y = m1 * x + b1;
      return Point(x, y);
    }
  }

  @override
  GeometryValue intersectVerticalLine(VerticalLine vline) =>
      Point(vline.x, m * vline.x + b);

  @override
  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg) => seg;
}

class VerticalLine extends GeometryValue {
  double x;
  VerticalLine(this.x);

  @override
  VerticalLine shift(double dx, double dy) => VerticalLine(x + dx);

  @override
  GeometryValue intersect(GeometryValue other) =>
      other.intersectVerticalLine(this);

  @override
  GeometryValue intersectPoint(Point p) => p.intersectVerticalLine(this);

  @override
  GeometryValue intersectLine(Line line) => line.intersectVerticalLine(this);

  @override
  GeometryValue intersectVerticalLine(VerticalLine vline) =>
      realClose(x, vline.x) ? this : NoPoints();

  @override
  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg) => seg;
}

class LineSegment extends GeometryValue {
  double x1, y1, x2, y2;
  LineSegment(this.x1, this.y1, this.x2, this.y2);

  @override
  GeometryValue preprocessProg() {
    if (realClosePoint(x1, y1, x2, y2)) {
      return Point(x1, y1);
    } else if (realClose(x1, x2)) {
      return (y1 < y2) ? this : LineSegment(x2, y2, x1, y1);
    } else {
      return (x1 < x2) ? this : LineSegment(x2, y2, x1, y1);
    }
  }

  @override
  LineSegment shift(double dx, double dy) =>
      LineSegment(x1 + dx, y1 + dy, x2 + dx, y2 + dy);

  @override
  GeometryValue intersect(GeometryValue other) =>
      other.intersectLineSegment(this);

  @override
  GeometryValue intersectPoint(Point p) => p.intersectLineSegment(this);

  @override
  GeometryValue intersectLine(Line line) => line.intersectLineSegment(this);

  @override
  GeometryValue intersectVerticalLine(VerticalLine vline) =>
      vline.intersectLineSegment(this);

  @override
  GeometryValue intersectWithSegmentAsLineResult(LineSegment seg) {
    var seg1Points = (x1, y1, x2, y2);
    var seg2Points = (seg.x1, seg.y1, seg.x2, seg.y2);
    // ignore: unused_local_variable
    var (x1start, y1start, x1end, y1end) = seg1Points;
    // ignore: unused_local_variable
    var (x2start, y2start, x2end, y2end) = seg2Points;

    if (realClose(x1start, x1end)) {
      // the segments are on a vertical line
      // let segment a start at or below start of segment b
      // ignore: unused_local_variable
      var ((aXstart, aYstart, aXend, aYend), (bXstart, bYstart, bXend, bYend)) =
          (y1start < y2start)
              ? (seg1Points, seg2Points)
              : (seg2Points, seg1Points);

      if (realClose(aYend, bYstart)) {
        return Point(aXend, aYend);
      } else if (aYend < bYstart) {
        return NoPoints(); // disjoint
      } else if (aYend > bYend) {
        return LineSegment(bXstart, bYstart, bXend, bYend); // b inside a
      } else {
        return LineSegment(bXstart, bYstart, aXend, aYend); // overlapping
      }
    } else {
      // the segments are on a (non-vertical) line
      // let segment a start at or to the left of start of segment b
      // ignore: unused_local_variable
      var ((aXstart, aYstart, aXend, aYend), (bXstart, bYstart, bXend, bYend)) =
          (x1start < x2start)
              ? (seg1Points, seg2Points)
              : (seg2Points, seg1Points);

      if (realClose(aXend, bXstart)) {
        return Point(aXend, aYend);
      } else if (aXend < bXstart) {
        return NoPoints();
      } else if (aXend > bXend) {
        return LineSegment(bXstart, bYstart, bXend, bYend); // b inside a
      } else {
        return LineSegment(bXstart, bYstart, aXend, aYend); // overlapping
      }
    }
  }
}

// ------------ Expressions -----------
class Intersect implements GeometryExpression {
  GeometryTerm e1, e2;
  Intersect(this.e1, this.e2);

  @override
  GeometryExpression preprocessProg() =>
      Intersect(e1.preprocessProg(), e2.preprocessProg());

  @override
  GeometryValue evalProg(List<(String, GeometryValue)> env) {
    var v1 = e1.evalProg(env);
    var v2 = e2.evalProg(env);
    return v1.intersect(v2);
  }
}

class Let extends GeometryExpression {
  String s;
  GeometryTerm e1, e2;
  Let(this.s, this.e1, this.e2);

  @override
  GeometryExpression preprocessProg() =>
      Let(s, e1.preprocessProg(), e2.preprocessProg());

  @override
  GeometryValue evalProg(List<(String, GeometryValue)> env) {
    var newVar = (s, e1.evalProg(env));
    var newEnv = [newVar] + env;
    return e2.evalProg(newEnv);
  }
}

class Var extends GeometryExpression {
  String s;
  Var(this.s);

  @override
  GeometryExpression preprocessProg() => this;

  @override
  GeometryValue evalProg(List<(String, GeometryValue)> env) {
    var prs = env.where((element) => element.$1 == s);
    if (prs.isEmpty) {
      throw Exception('undefined variable');
    }
    return prs.first.$2;
  }
}

class Shift extends GeometryExpression {
  double dx, dy;
  GeometryTerm e;
  Shift(this.dx, this.dy, this.e);

  @override
  GeometryExpression preprocessProg() => Shift(dx, dy, e.preprocessProg());

  @override
  GeometryValue evalProg(List<(String, GeometryValue)> env) =>
      (e.evalProg(env)).shift(dx, dy);
}
