part of mapbrowser;

/// true if currently running in a firefox browser 
bool get isFirefox => window.navigator.userAgent.toLowerCase().indexOf("firefox") > -1;


typedef ZoomListener(int oldValue, int newValue);

class Viewport {
 
  CanvasElement _canvas;
  var _layers = [];
  CanvasElement _buffer;
  int _zoom = 0;
  LatLon _center = new LatLon.origin();
  
  /// Creates a new viewport attached to the canvas element [canvas].
  /// [canvas] must not be null.
  Viewport(CanvasElement canvas) {
    assert(canvas != null);
    this._canvas = canvas;
    _canvas
      ..width = _canvas.clientWidth
      ..height = _canvas.clientHeight;
    
    _buffer = new Element.tag("canvas");
    _buffer.width = _canvas.width;
    _buffer.height = _canvas.height;
    
    _wireListeners();
  }
  
  int get width => _canvas.width;
  int get height => _canvas.height;
  int get zoom => _zoom;
  LatLon get center => _center;
  set center(LatLon value) {
    assert(value != null);
    _center = value;
  }
 
  /// adds the layer [layer] to the viewport 
  addLayer(Layer layer) {
    assert(layer != null);
    _layers.add(layer);
  }
  
  set cursor(String name) {
    _canvas.style.cursor = name; 
  }
  
  /// request to repaint the canvas
  repaint() {
    paint();
  }
  
  /// paints the frames to the viewport  
  paint(){
    var gc = _buffer.context2d;
    // refresh the offscreen buffer with the current layer buffers 
    gc.clearRect(0,0, width, height);
    _layers.forEach((layer) => layer.paint(gc));
    
    // paint the offscreen buffer 
    _canvas.context2d.drawImage(_buffer, 0,0);
  }  
  
  render() {
    _layers.forEach((layer) => layer.render());
    paint();
  }
    
  /* --------------------------------     zooming      -------------------------------- */
  static const MAX_ZOOM = 20;
  /// zoom in by [levels] steps 
  zoomIn([int levels=1]) {
    _setZoom(min(_zoom + levels, MAX_ZOOM));     
  }
  
  /// zoom out by [levels] steps 
  zoomOut([int levels=1]) {
    _setZoom(max(_zoom - levels, 0)); 
  }
  
  /// zoom to a specific zoom level. 
  /// If [v] is an int, then zoom to this zoom level (normalized to 0..MAX_ZOOM).
  /// If [v] is a double, then zoom to the relative zoom level v * MAX_ZOOM
  zoomTo(v) {
    if (v is int) {
      v = max(v, 0);
      v = min(v, MAX_ZOOM);
      _setZoom(v);
    } else if (v is double) {
      v = min(v, 1.0);
      v = max(v, 0.0);
      _setZoom((MAX_ZOOM * v).floor().toInt());
    } else {
      throw "usage: zoomTo(int /* abs. zoom level */) or zoomTo(double /* 0.0 ... 1.0 */)";
    }
  }
  
  _setZoom(zoom) {
     var old = _zoom;
     _zoom = zoom;
     if (old != _zoom) {
       _fireZoomChanged(old, _zoom);
       render();
       repaint();
     }
  }
  
  List _zoomlisteners = [];
  addZoomListener(ZoomListener listener) {
    if (listener == null) return;
    if (_zoomlisteners.indexOf(listener) >= 0) return; 
    _zoomlisteners.add(listener);
  }
  
  _fireZoomChanged(oldValue, newValue) {
    _zoomlisteners.forEach((notifyChanged) => notifyChanged(oldValue, newValue));
  }
  

  /* -------------------------------- raw mouse handling -------------------------------- */
  var _lastMouseDownTimestamp = 0;
  var _lastMouseDownPos = null;
  var _mouseDown = false;
  var _isDragging = false;
  
  Point _dragStart = null;
  LatLon _dragCenter = null;  
  
  _rawMouseDown(event) {
    _mouseDown = true;
    _lastMouseDownTimestamp = new Date.now().millisecondsSinceEpoch;
    _lastMouseDownPos = new Point.offset(event);
    (event as MouseEvent).preventDefault();
  }
  
  _rawMouseUp(event) {
    if (_isDragging) onDragEnd(event);
    _mouseDown = false;
    _isDragging = false; 
    (event as MouseEvent).preventDefault();
  }
  
  _rawMouseMove(event){
    if (_mouseDown) {
       if (!_isDragging) onDragStart(event);
      _isDragging = true;
    }
    if (_isDragging) {
      onMouseDrag(event);
    } else {
      onMouseMove(event);
    }
    (event as MouseEvent).preventDefault();
  }
  
   var deferredEvent = null;
   
  _fireDeferred() {
    if (deferredEvent != null) {
      var e = deferredEvent;
      deferredEvent = null;
      onClick(e);
    }      
  }
  
  _rawMouseClick(event) {
     if (deferredEvent == null) {
       var ts = new Date.now().millisecondsSinceEpoch;
       if (ts - _lastMouseDownTimestamp > 150) {
         // a click generated at the end of a drag sequence
         //      mouse down, mouse move, ..., mouse move, mouse up, click  
         // Ignore it.
         return;
       }
       deferredEvent = event;
       new Timer(200, (timer) => _fireDeferred());
     } else {
       deferredEvent = null;
       onDoubleClick(event);
     }
     (event as MouseEvent).preventDefault();
  }
  
  _wireListeners() {
    _canvas.on
      ..mouseDown.add((event) => _rawMouseDown(event))
      ..mouseUp.add((event) => _rawMouseUp(event))
      ..mouseMove.add((event) => _rawMouseMove(event))
      ..click.add((event) => _rawMouseClick(event))
      ..mouseWheel.add((event) => onMouseWheel(event));
  }
  
  onClick(event) => _layers.forEach((layer) => layer.onClick(event));
  onDoubleClick(event) => _layers.forEach((layer) => layer.onDoubleClick(event));
  onMouseMove(event) => _layers.forEach((layer) => layer.onMouseMove(event));  
  onMouseWheel(event) => _layers.forEach((layer) => layer.onMouseWheel(event));
 
  
  // we select the topmost layer which is interested in a drag start event. Subsequent
  // drag events are sent to this layer only.
  //
  var draggingLayer;
  onDragStart(event) {
    for (int i=_layers.length -1; i >= 0; i--) {
      if (_layers[i].canDragStart(event)) {
        draggingLayer = _layers[i];
        draggingLayer.onDragStart(event);
        draggingLayer.onMouseDrag(event);
        break;
      }
    }
  }
  onDragEnd(event) {
    if (draggingLayer != null) {
      draggingLayer.onDragEnd(event);
      draggingLayer = null;
    }
  }
  
  onMouseDrag(event) {
    if (draggingLayer != null) draggingLayer.onMouseDrag(event);
  }
  
  /* -----------------------------------------  paning -------------------------------- */ 
  _abs(x) =>  x < 0 ? -x : x;
  _animatePanToNewPos(LatLon pos) {
    
    createAnimationStep(toPos) => (timer){center = toPos; render();};
    
    double deltalat = _abs(_center.lat - pos.lat);
    double deltalon = _abs(_center.lon - pos.lon);
    if (pos.lat < _center.lat) deltalat = -deltalat;
    if (pos.lon < _center.lon) deltalon = -deltalon;
    var steps = 5;
    for(int i = 1; i< steps; i++) {
      var ll = _center.translate(deltalat / steps * i, deltalon / steps * i);
      new Timer(50*i, createAnimationStep(ll));
    }
    new Timer(50 * steps, createAnimationStep(pos));
  }
  
  int get _vpmax_x => (1 << _zoom) * 200;
  int get _vpmax_y => (1 << _zoom) * 200;
  
  /// project [pos] onto viewport coordinates. 
  //FIXME: can't have Point as return type. Leads to runtime errors. 
  dynamic latlon2viewport(LatLon pos) {
    var zz = (1 << _zoom);
    int x = ((pos.lon + 180) / 360 * _vpmax_x).floor().toInt();
    int y = ((1-log(tan(pos.lat*PI/180) + 1/cos(pos.lat*PI/180))/PI)/2 * _vpmax_y).floor().toInt();
    return new Point(x,y);
  }
 
  /// reverse projection of [p] to lat/lon coordinates
  LatLon viewport2latlon(Point p) {
    var zz = (1 << _zoom);
    double lon = p.x/_vpmax_x * 360-180;    
    var n = PI-2*PI*p.y/_vpmax_y;
    double lat = (180/PI* atan(0.5*(exp(n)-exp(-n))));
    return new LatLon(lat, lon);
  }
  
  _panByOffset(dx, dy) {
    Point p = latlon2viewport(_center).translate(dx,dy);
    LatLon pos = viewport2latlon(p);
    _animatePanToNewPos(pos);
  }
  
  onPan(direction) {
    switch(direction) {
      case PAN_UP: _panByOffset(0, -100); break;
      case PAN_RIGHT: _panByOffset(100,0); break;
      case PAN_DOWN: _panByOffset(0,100); break;
      case PAN_LEFT: _panByOffset(-100,0); break;
    }
  }
}
