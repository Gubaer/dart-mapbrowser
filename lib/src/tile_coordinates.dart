part of mapbrowser;
/**
 * Represents tile coordinates given by tile position (ti,tj) and pixel position
 * (dx, dy) relative to the top left tile corner.
 */
class TileCoordinates {
   final int ti, tj, dx, dy;
   
   /// coordinates for the pixel ([dx], [dy]) on tile ([ti], [tj]) 
   TileCoordinates({int this.ti, int this.tj, int this.dx, int this.dy});   
   String toString() => "{tileCoordinates ti: ${ti}, tj: ${tj}, dx: ${dx}, dy: ${dy}"; 
   
   int tilePlaneX([sourceOrTileWidth]) {
     var tw = TileSource.DEFAULT_TILE_WIDTH;
     if (sourceOrTileWidth == null) {
       tw = TileSource.DEFAULT_TILE_WIDTH;
     } else if (sourceOrTileWidth is TileSource) {
       tw = (sourceOrTileWidth as TileSource).tileWidth;
     } else if (sourceOrTileWidth is int) {
       tw = (sourceOrTileWidth  as int);
     } else {
       throw "sourceOrTileWidth: unexpected value, got ${sourceOrTileWidth}";
     }
     return ti * tw + dx;
   }
   
   int tilePlaneY([sourceOrTileHeight]) {
     var th = TileSource.DEFAULT_TILE_HEIGHT;
     if (sourceOrTileHeight == null) {
       th = TileSource.DEFAULT_TILE_HEIGHT;
     } else if (sourceOrTileHeight is TileSource) {
       th = (sourceOrTileHeight as TileSource).tileHeight;
     } else if (sourceOrTileHeight is int) {
       th = (sourceOrTileHeight  as int);
     } else {
       throw "sourceOrTileHeight: unexpected value, got ${sourceOrTileHeight}";
     }
     return tj * th + dy;
   }   
}