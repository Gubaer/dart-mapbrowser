part of mapbrowser;
/**
 * An individual map tile. Can render itself to a canvas.
 */
class Tile {
  static const LOADING = 0;
  static const READY = 1;
  static const ERROR = 2;
  
  final int zoom;
  final int ti;
  final int tj;
  final TileSource source;
  var _image;
  var _layer;
  var _state = LOADING;
  int _x;
  int _y;
  
  Tile(int this.zoom, int this.ti, int this.tj, TileSource this.source){}
  
  /// the parent tile or null, if this [Tile] is already the root tile
  Tile get parent {
    if (zoom == 0) return null;
    return new Tile(zoom -1, ti ~/ 2, tj ~/ 2, source);
  }
  
  /// attaches the graphics [context] the tile is rendered to. Renders itself
  /// at the position ([x],[y]).
  attach(Layer layer,int x, int y) {
    this._layer = layer;
    this._x = x;
    this._y = y;
    load();
  }
  
  /// detaches the tile from a layer
  detach() => this._layer = null;
  bool get isAttached => this._layer != null;
  
  /// the tile url for this tile
  String get url => source.buildTileUrl(ti, tj, zoom);
  
  _removeListeners() {
    _image.on
      ..error.remove(this._onError)
      ..load.remove(this._onLoad);
  }
  
  /// loads the tile image.
  load() {
    // already loaded? don't load again
    if (_image != null) return;
    _image = ImageCache.instance.lookup(url);
    if (_image != null) {
      // use an already loaded and cached image 
      _state = READY;
    } else {
      
      // only later add the image to the image cache, see
      // _onLoad()
      _image = new Element.tag("img");
      _image.src = url;
      _image.on
        ..error.add(this._onError)
        ..load.add(this._onLoad);
      _state = LOADING;
    }
    if (_layer != null) {
      render();
      _layer.repaint();
    }
   }
  
  _onError(event) {    
    _state = ERROR;
    _removeListeners();
    render();
    if (_layer != null) {
      render();
      _layer.repaint();     
    }
  }
  
  _onLoad(event) {
    _state = READY;
    _removeListeners();
    ImageCache.instance.remember(url, _image);
    if (_layer != null) {
      render();
      _layer.repaint();
    }
  }
  
  /// renders the tile. Attach the tile first to a canvas context, see attach()
  render() {
    if (!isAttached) return;
    switch(this._state) {
      case LOADING: _renderLoading(); break;
      case READY: _renderReady(); break;
      case ERROR: _renderError(); break;
    }
  }
  
  _renderLoading() {
     var p = parent;
     var pimage = null;
     if (p != null){
       pimage = ImageCache.instance.lookup(p.url);
     }
     if (pimage == null) {
       _layer.gc
          ..setFillColorRgb(255, 255, 255, 255) // white
          ..fillRect(_x, _y, source.tileWidth, source.tileHeight);
     } else {
       var tw = source.tileWidth ~/ 2;
       var th = source.tileHeight ~/ 2;
       var tx = 0, ty = 0;
       if (ti % 2 == 1) tx = tw;
       if (tj % 2 == 1) ty = th;
       _layer.gc.drawImage(pimage, 
         /* take section from parent image .. */ tx, ty,tw,th, 
         /* ... and draw onto tile space      */ _x, _y, source.tileWidth, source.tileHeight
       );
     }
  }
  
  _renderReady() {
    _layer.gc.drawImage(_image, _x, _y);
  }
  
  _renderError() {
    _layer.gc
      ..setFillColorRgb(255, 0, 0, 255) // red
      ..fillRect(_x, _y, source.tileWidth, source.tileHeight);
  }
}