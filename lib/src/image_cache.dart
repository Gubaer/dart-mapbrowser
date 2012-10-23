part of mapbrowser;
/**
 * Global image cache with bound capacity
 */

class ImageCacheEntry {
  var image;
  var _ts;
  ImageCacheEntry(this.image, [ts]){
    if (!?ts) ts = new Date.now().millisecondsSinceEpoch;
    this._ts = ts;
  }
  
  set ts(value) => this._ts = value;
  int get ts => _ts;
}

class ImageCache {
  static final int DEFAULT_CAPACITY=1000;
  
  static ImageCache _inst;
  static ImageCache get instance { 
    if (_inst == null) _inst = new ImageCache();
    return _inst;
  }
  
  var _cache = {};
  int _capacity = DEFAULT_CAPACITY;
  
  /// clears the cache 
  clear() {
    _cache = {};
  }
  
  /// remembers [tile] in the cache 
  remember(String url, image) {
    _cache[url] = new ImageCacheEntry(image);
    if (_cache.length > _capacity + 10) shrink(10);
  }

  /// the tile given by [url]. null, if no such tile is in the cache 
  lookup(String url) {
    var entry = _cache[url];
    if (entry == null) return null;
    
    entry.ts = new Date.now().millisecondsSinceEpoch;
    return entry.image;    
  }
  
  /// shrinks the size of the cache by [by] entries, removing the
  /// least recently accessed [by] images 
  shrink([by=10]) {
    assert(by is num && by > 0);

    print("ImageCache: shrinking by $by");

    var l = [];
    _cache.forEach((url, entry) {
      l.add({"url": url, "ts": entry.ts});
    });
    l.sort((a,b) {
      //FIXME: compareTo doesn't work in M1 on int? 
      if (a["ts"] > b["ts"]) return -1;
      if (a["ts"] == b["ts"]) return 0;
      return 1;
    });
    for (var i = 0; i < by && i < l.length - 1; i++) {
      _cache.remove(l[i]["url"]);
    }
  }
  
  /// set the cache capacity [value]
  set capacity(int value) {
    assert(value > 0);    
    if (_cache.length > value) shrink(_cache.length-value);
    this._capacity = value;
  }
  
  /// the cache capacity 
  int get capacity => _capacity;
}
