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
  var _context;
  var _state = LOADING;
  int _x;
  int _y;
  
  Tile(int this.zoom, int this.ti, int this.tj, TileSource this.source){}
  
  /// attaches the graphics [context] the tile is rendered to. Renders itself
  /// at the position ([x],[y]).
  attach(context,int x, int y) {
    this._context = context;
    this._x = x;
    this._y = y;
    load();
  }
  
  /// detaches the graphics context the tile is rendered to. Doesn't render
  /// itself unless a graphics context is attached.
  detach() => this._context = null;
  bool get attached => this._context != null;
  
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
    render();
   }
  
  _onError(event) {    
    _state = ERROR;
    _removeListeners();
    render();
  }
  
  _onLoad(event) {
    _state = READY;
    _removeListeners();
    ImageCache.instance.remember(url, _image);
    render();
  }
  
  /// renders the tile. Attach the tile first to a canvas context, see attach()
  render() {
    if (!attached) return;
    switch(this._state) {
      case LOADING: _renderLoading(); break;
      case READY: _renderReady(); break;
      case ERROR: _renderError(); break;
    }
  }
  
  _renderLoading() {
     this._context.setFillColorRgb(255, 255, 255, 255); // white
     this._context.fillRect(_x, _y, source.tileWidth, source.tileHeight);
  }
  
  _renderReady() {
    this._context.drawImage(_image, _x, _y);
  }
  
  _renderError() {
    this._context.setFillColorRgb(255, 0, 0, 255); // red
    this._context.fillRect(_x, _y, source.tileWidth, source.tileHeight);
  }
}