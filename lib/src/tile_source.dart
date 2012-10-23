part of mapbrowser;

/**
 * Represents a tile source. It is described with an URL template
 * from which URL for specific map tiles are derived. The template
 * can include three makros $x, $y, and $zoom. 
 */
class TileSource {
  static const int DEFAULT_TILE_WIDTH = 256;
  static const int DEFAULT_TILE_HEIGHT = 256;
  static const int DEFAULT_ZOOM_LEVELS = 18;
  /// default Open Street Map tile server
  static const DEFAULT_TILE_SOURCE = r"http://a.tile.openstreetmap.org/$zoom/$x/$y.png";
  
  String _urlTemplate;
  int _tileWidth = DEFAULT_TILE_WIDTH;
  int _tileHeight = DEFAULT_TILE_HEIGHT;
  int _zoomLevels = DEFAULT_ZOOM_LEVELS;
  
  /**
   * Creates a tile source for a given [urlTemplate]. Assumes
   * [DEFAULT] if missing or null. 
   * 
   * [tileWidth] (defaults to [DEFAULT_TILE_WIDTH]) and [tileHeight] (defaults to [DEFAULT_TILE_HEIGHT]) indicate the 
   * width and height of tiles served by this tile source. 
   */
  TileSource({String urlTemplate:DEFAULT_TILE_SOURCE, int tileWidth: DEFAULT_TILE_WIDTH, int tileHeight: DEFAULT_TILE_HEIGHT, int zoomLevels: DEFAULT_ZOOM_LEVELS}) {
    if (urlTemplate == null) urlTemplate = DEFAULT_TILE_SOURCE;
    assert(tileWidth > 0);
    assert(tileHeight > 0);
    this._tileWidth = tileWidth;
    this._tileHeight = tileHeight;
    this._urlTemplate = urlTemplate;
  }
  
  /// Replies the url template for building tile URLs   
  String get urlTemplate => _urlTemplate;
  
  /**
   * Replies the tile URL for accessing the tile
   * ([x], [y]) at zoom level [zoom].
   */
  String buildTileUrl(int x, int y, int zoom){
    return _urlTemplate.replaceAll("\$x", x.toString())
          .replaceAll("\$y", y.toString())
          .replaceAll("\$zoom", zoom.toString());
  }  
  
  /// the width of tiles served by this tile source
  int get tileWidth => _tileWidth;
  
  /// the height of tiles served by this tile source
  int get tileHeight => _tileHeight;
  
  /// the max zoom level this tile source serves 
  int get zoomLevels => _zoomLevels;
}
