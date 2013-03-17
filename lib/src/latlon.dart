part of mapbrowser;

/**
 * A pair of latitude/longitude coordinates
 */
class LatLon {
  double _lat;
  double _lon;
  /// creates a pair ([lat, lon]). Default for both, if missing,
  /// is 0.0.
  LatLon([double lat=0.0, double lon=0.0]): _lat=lat, _lon=lon;
  
  /// creates a new lat/lon at position (0.0,0.0)
  LatLon.origin():_lat=0.0, _lon=0.0;   
  
  /// creates a clone of [other]
  LatLon.clone(LatLon other): _lat=other.lat, _lon=other.lon;
  
  /// the latitude 
  double get lat => _lat;
  /// the longitude 
  double get lon => _lon;
  
  String toString() => "{LatLon: lat: ${_lat}, lon: ${_lon}}";
  
  LatLon translate(double dlat, double dlon) {
    return new LatLon(_lat + dlat, _lon + dlon);
  }
}