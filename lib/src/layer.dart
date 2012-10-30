part of mapbrowser;

abstract class Layer {
  CanvasElement _canvas;
  Viewport _viewport;
  
  /// creates a layer on the viewport [viewport]. [viewport] must not 
  /// be null.
  /// Adds itself to [viewport].
  ///
  Layer(Viewport this._viewport) {
    assert(this._viewport != null);
    _canvas = new Element.tag("canvas");    
    width = viewport.width;
    height = viewport.height;
    _viewport.addLayer(this);
  }
  
  int get width => _canvas.width;
  int get height => _canvas.height;
  set width(int value) {
    assert(value > 0);
    _canvas.width = value;
  }
  
  set height(int value) {
    assert(value > 0);
    _canvas.height = value;
  }
  
  CanvasRenderingContext2D get gc => _canvas.context2d;
  Viewport get viewport => _viewport;
  
  repaint() {
    if (this._viewport == null) return;
    this._viewport.repaint();
  }
  
  /// renders the layer at position (0,0) on the graphics context 
  /// [gc]
  paint(CanvasRenderingContext2D gc) {
    gc.drawImage(_canvas, 0,0);
  }
  
  /// implement in sub classes. Renders the layer in its offscreen
  /// buffer 
  abstract render();
  
  onMouseDown(event){}
  onMouseUp(event){}
  onMouseMove(event){}
  onMouseDrag(event){}
  onDragStart(event){}
  onDragEnd(event){}
  onClick(event){}
  onDoubleClick(event){}
  onMouseWheel(event){}
  bool canDragStart(event) => true;
}
