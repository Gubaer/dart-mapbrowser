part of mapbrowser;

class Point {
  final int x;
  final int y;
  Point(int this.x, int this.y);
  Point.origin() : x=0, y=0;
  Point.offset(event) : x=event.offsetX, y=event.offsetY;
  String toString() => "{Point: x=$x, y=$y}";
  Point translate(dx, dy) => new Point(x + dx, y + dy);
  bool operator ==(other) => other.x == x && other.y == y;
}