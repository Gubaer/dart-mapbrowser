import "package:mapbrowser/mapbrowser.dart";
import "dart:html";

main() {
  var mapview = new MapView(query("#container"));
  
  var ts = (query("#tile-sources") as SelectElement); 
  ts.on.change.add((event) {      
      mapview.tilesource = new TileSource(urlTemplate: ts.value);
  });
}