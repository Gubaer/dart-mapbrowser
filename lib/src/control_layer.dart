part of mapbrowser;

//
// four directions of panning
const int PAN_UP = 0;
const int PAN_RIGHT = 1;
const int PAN_DOWN = 2;
const int PAN_LEFT = 3;

/// callback type for notification about pan events, see
/// addPanListener() in ControlLayer
typedef PanListener(int direction);


/**
 * Renders navigation control (pan navigation control, zoom slider, etc.) and
 * responds to mouse events.
 */
class ControlLayer extends Layer {
  
  PanNavigator _panNavigator;
  ZoomSlider _zoomSlider;
  
  ControlLayer(Viewport viewport) : super(viewport) {
    _panNavigator = new PanNavigator(this, 40, 40);
    _zoomSlider = new ZoomSlider(this);
    render();
    repaint();
  }
  
  addPanListener(listener) {
    _panNavigator.addPanListener(listener);    
  }
  
  render() {
    gc.clearRect(0,0,width,height);
    _panNavigator.render();
    _zoomSlider.render();
  }
  
  onMouseMove(event) {
    _panNavigator.onMouseMove(event);
    _zoomSlider.onMouseMove(event);
  }
  
  onClick(event) {
    _panNavigator.onClick(event);
    _zoomSlider.onClick(event);
  } 
  
  bool canDragStart(event) {
    return _zoomSlider.canDragStart(event);
  }
  
  onMouseDrag(event) {
    _zoomSlider.onMouseDrag(event);
  }
}

class Rectangle {
  int x,y, width, height;
  Rectangle(this.x, this.y, this.width, this.height);
  
  translate(dx, dy) {
    return new Rectangle(x + dx, y + dy, width, height);
  }
  
  moveTo(x,y) => new Rectangle(x,y, width, height);
  
  isInside(p) {
    return p.x >= this.x && p.x < this.x + this.width
        && p.y >= this.y && p.y <  this.y + this.height;
  }
    
  dynamic get center =>  new Point (x + width ~/ 2, y + height ~/ 2);
  
  Rectangle centeredAt(a1, [int a2]) {
    if (a1 is Point) {
      assert(a1 != null);
      return new Rectangle(a1.x - width ~/ 2, a1.y - height ~/ 2, width, height); 
    } else if (a1 is int) {
      assert(?a2);
      return new Rectangle(a1 - width ~/ 2, a2 - height ~/ 2, width, height);
    }
    throw "usage: centeredAt(aPoint) or centeredAt(x,y)";        
  }
  
  stroke(gc) {
    gc.strokeRect(x,y,width, height);
  }
  fill(gc) {
    gc.fillRect(x,y,width,height);
  }
}

/**
 * A rectangular are which keepts track of whether the mouse is currently inside
 * or outside the area.
 */
class FeedbackRectangle extends Rectangle {
  var mouseOver = false;
  Layer _layer;
  
  FeedbackRectangle(Layer this._layer, int x, int y, int width, int height) : super(x,y,width,height);
  FeedbackRectangle.byRectangle(layer, r) :  this(layer, r.x, r.y, r.width, r.height);
  
  _setCursor(name) {
    Viewport v = _layer.viewport;
    if (v== null) return;
    v.cursor = name;
  }
  
  onMouseMove(p) {
    var inside = isInside(p);
    if (inside && !mouseOver) {
       _setCursor("pointer");
       mouseOver = true;
    } else if (!inside && mouseOver) {
      _setCursor("default");
      mouseOver = false;
    }
  }
  
  translate(dx, dy) => new FeedbackRectangle.byRectangle(_layer, super.translate(dx,dy));
  moveTo(x,y) => new FeedbackRectangle.byRectangle(_layer, super.moveTo(x,y));
  centeredAt(a1,[a2]) => new FeedbackRectangle.byRectangle(_layer, super.centeredAt(a1,a2));
}


/**
 * The pan navigator rendered in the top left corner of the map.
 */
class PanNavigator {
  static const RADIUS = 25;
      
  var up, right, down, left; 
   
  int _x;
  int _y; 
  Layer _layer;
  bool _mouseOver = false;
  
  /* ---------------------  pan event handling -------------------------------- */
  List<PanListener> _panListeners = [];
  
  addPanListener(listener) {
    if (listener == null) return;
    if (_panListeners.indexOf(listener) < 0) _panListeners.add(listener);
  }
  
  _firePanEvent(direction) {
    _panListeners.forEach((listener) => listener(direction)); 
  }
  
  PanNavigator(Layer this._layer, this._x, this._y) {
    up = new FeedbackRectangle(_layer, 35, 20, 10, 5);
    right = new FeedbackRectangle(_layer, 55, 35, 5, 10);
    left= new FeedbackRectangle(_layer, 20, 35, 5, 10);
    down= new FeedbackRectangle(_layer, 35, 55, 10, 5);
    render();
    _layer.repaint();
  }
  
  render() {
    var ctx = _layer.gc;
    ctx.beginPath();
    ctx.arc(_x, _y, RADIUS, 0, 2 * PI, false);
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#848282";
    if (_mouseOver) {
      ctx.fillStyle = "rgba(240,240,240,1.0)";
    } else {
      ctx.fillStyle = "rgba(255,255,255,0.8)";      
    }
    ctx.fill();
    ctx.stroke();    

    ctx.save();
    ctx.translate(_x, _y);   
    ctx.strokeStyle = "#848282";
    ctx.fillStyle = "#848282";
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    double angle = 0.0;
    while(angle < 2 * PI) {
      ctx.rotate(angle);
      ctx.beginPath();
      ctx.moveTo(0,-20);
      ctx.lineTo(5,-15);
      ctx.lineTo(-5,-15);
      ctx.closePath();
      ctx.stroke();
      ctx.fill();
      angle += PI / 2;
    }
    ctx.restore();
  }
  
  bool isInside(p) {
    var dist = sqrt(pow(_x - p.x, 2) + pow(_y - p.y, 2));
    return dist <= RADIUS;
  }
  
  onMouseMove(event) {
    var p = new Point.offset(event);
    var hit = isInside(p);
    if (hit && !_mouseOver) {
      _mouseOver = true;
      render();
      _layer.repaint();
    } else if (!hit && _mouseOver) {
      _mouseOver = false;
      render();
      _layer.repaint();
    }  
    up.onMouseMove(p);
    right.onMouseMove(p);
    down.onMouseMove(p);
    left.onMouseMove(p);
  }
  
  onClick(event) {
    var p = new Point.offset(event);
    if (up.isInside(p)) _firePanEvent(PAN_UP);
    else if (right.isInside(p)) _firePanEvent(PAN_RIGHT);
    else if (down.isInside(p)) _firePanEvent(PAN_DOWN);
    else if (left.isInside(p)) _firePanEvent(PAN_LEFT);
  } 
}


class ZoomNob extends FeedbackRectangle{
   static const int NOB_PLUS = 0;
   static const int NOB_MINUS = 1;
   
   int _type;
 
   ZoomNob(layer, int this._type, int x, int y, int width, int height): super(layer,x,y,width, height);
   
   ZoomNob.other(layer, type, Rectangle r) : this(layer, type, r.x, r.y, r.width, r.height);
   
   render() {
     var ctx = _layer.gc;
     var shadow = translate(3, 3);
     ctx.setFillColorRgb(120, 120, 120);
     ctx.lineWidth = 0;
     shadow.fill(ctx);
     shadow.stroke(ctx);
     ctx.setFillColorRgb(255,255,255); 
     ctx.lineWidth = 1;
     ctx.strokeStyle = "rgb(50,50,50)";
     ctx.lineWidth = 1;
     this.fill(ctx);
     this.stroke(ctx);
     
     switch(_type) {
       case NOB_PLUS: _renderPlus(ctx); break;
       case NOB_MINUS: _renderMinus(ctx); break;
     }
   }
    
   _renderPlus(CanvasRenderingContext2D ctx) {
     ctx
       ..strokeStyle = "rgb(100,100,100)"
       ..lineWidth = 3
       ..lineCap = "round";
     
     ctx
      ..beginPath()
      ..moveTo(x + 5, y + 10)
      ..lineTo(x + 15, y + 10)
      ..stroke();
          
     ctx
     ..beginPath()
     ..moveTo(x + 10, y + 5)
     ..lineTo(x + 10, y + 15)
     ..stroke();     
   }
   
   _renderMinus(CanvasRenderingContext2D ctx) {
      ctx
       ..strokeStyle = "rgb(100,100,100)"
       ..lineWidth = 3
       ..lineCap = "round";
     
     ctx
      ..beginPath()
      ..moveTo(x + 5, y + 10)
      ..lineTo(x + 15, y + 10)
      ..stroke();
   }  
}

class ZoomSlider {  
  Layer _layer;
  
  ZoomNob plus;
  ZoomNob minus;
  FeedbackRectangle handle;
  
  
  ZoomSlider(this._layer) {
    plus = new ZoomNob(_layer,ZoomNob.NOB_PLUS, 30,90,20,20);
    minus = new ZoomNob.other(_layer, ZoomNob.NOB_MINUS, plus.translate(0, 200));   
    
    var y = _handleYForRelativeZoom(_layer.viewport.zoom / Viewport.MAX_ZOOM);
    handle = new FeedbackRectangle(_layer, 0,0,20,10);
    handle = handle.centeredAt(plus.center.x, y);    
    _layer.viewport.addZoomListener(this.onZoomChanged);    
  }
  
  _renderZoomNob(ctx, r) {
    var shadow = r.translate(3, 3);
    ctx.setFillColorRgb(120, 120, 120);
    ctx.lineWidth = 0;
    shadow.render(ctx);
    ctx.setFillColorRgb(255,255,255); 
    ctx.lineWidth = 1;
    ctx.strokeStyle = "rgb(50,50,50)";
    ctx.lineWidth = 1;
    r.render(ctx);
  }
  
  int _handleYForRelativeZoom(zoom) {
    num len = minus.center.y -20 - (plus.center.y + 20);
    return minus.center.y -20 - (len * zoom).floor().toInt();
  }
  
  _renderZoomSlider(ctx) {
     var c1 = plus.center;
     var c2 = minus.center;
     ctx.beginPath();
     ctx.moveTo(c1.x, c1.y);
     ctx.lineTo(c2.x, c2.y);
     ctx.strokeStyle = "rgba(150,150,150, 0.7)";
     ctx.lineWidth = 5;
     ctx.stroke();
  }
  
  _renderZoomSliderHandle(ctx) {
     var shadow = handle.translate(3, 3);
     ctx.setFillColorRgb(120, 120, 120);
     ctx.lineWidth = 0;
     shadow.fill(ctx);
     //shadow.stroke(ctx);
     ctx.setFillColorRgb(255,255,255); 
     ctx.lineWidth = 1;
     ctx.strokeStyle = "rgb(50,50,50)";
     ctx.lineWidth = 1;
     handle.fill(ctx);
     handle.stroke(ctx);
  }
  
  render() {
    var ctx = _layer.gc;
    ctx.save();    
    _renderZoomSlider(ctx);
    _renderZoomSliderHandle(ctx);    
    plus.render();
    minus.render();
    ctx.restore();
  }
  
  onMouseMove(event) {    
    var p = new Point.offset(event);
    plus.onMouseMove(p);
    minus.onMouseMove(p);
    handle.onMouseMove(p);
  }
  
  onClick(event) {
    var p = new Point.offset(event);
    if (plus.isInside(p)) _layer.viewport.zoomIn();
    else if (minus.isInside(p)) _layer.viewport.zoomOut();
  }
  
  canDragStart(event) {
    return handle.isInside(new Point.offset(event));
  }
  
  onMouseDrag(event) {
    var p = new Point.offset(event);
    var x = plus.center.x;
    var y = max(plus.center.y + 20, p.y);
    y = min(minus.center.y - 20, y);
    var newHandle = handle.centeredAt(x, y);
    if (newHandle.center != handle.center) {
      handle = newHandle;
      _layer.render();
      _layer.repaint();
    }    
    num len = minus.center.y -20 - (plus.center.y + 20);
    num dy = minus.center.y - 20 - handle.y;
    _layer.viewport.zoomTo(dy/len);
  }  
  
  onZoomChanged(oldValue, newValue) {
    var y = _handleYForRelativeZoom(newValue / Viewport.MAX_ZOOM);
    handle = handle.centeredAt(handle.center.x, y);  
  }
}