part of mapbrowser;

class Point {
  final int x;
  final int y;
  Point(int this.x, int this.y);
  Point.origin() : x=0, y=0;
  Point.offset(event) : x=event.offsetX, y=event.offsetY;
  Point.clone(Point other) : x=other.x, y=other.y;
  Point.polar(num r, num theta) : this((r * cos(theta)).toInt(),(r * sin(theta)).toInt());
  String toString() => "{Point: x=$x, y=$y}";
  Point translate(dx, dy) => new Point(x + dx, y + dy);
  double distance(Point other) => sqrt(pow(x - other.x, 2) + pow(y - other.y,2));
  double direction(Point other) => other.theta - theta;
  double get r => sqrt(pow(x,2) + pow(y,2));
  double get theta {
    if (x == 0) return y > 0 ? PI / 2 : - PI / 2;
    else if (x > 0) return atan(y/x);
    else return atan(y/x) + PI;
  }
  bool operator ==(other) => other.x == x && other.y == y;
  Point operator +(other) => new Point(x + other.x, y + other.y);
  Point operator -(other) => new Point(x - other.x, y - other.y);
}