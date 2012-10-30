import "package:mapbrowser/mapbrowser.dart";
import "dart:html";

main() {
  var viewport = new Viewport(query("#viewport"));
  var tiles = new TileLayer(viewport);  
  var controls = new ControlLayer(viewport);
  controls.addPanListener(viewport.onPan);

  var ts = (query("#tile-sources") as SelectElement); 
  ts.on.change.add((event) {      
      tiles.tilesource = new TileSource(urlTemplate: ts.value);
  });
}