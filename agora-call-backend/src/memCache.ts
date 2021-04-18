
export class MemCache {

  public static hset(set: string, key: string, val: any) {
    if (!this.memCache[set]) {
      this.memCache[set] = {};
    }
    this.memCache[set][key] = val;
  }

  public static hget(set: string, key: string) {
    let val = null;
    if (this.memCache[set] && this.memCache[set][key]) {
      val = this.memCache[set][key];
    }
    return val;
  }

  public static hdel(set: string, key: string) {
    if (this.memCache[set] && this.memCache[set][key]) {
      delete this.memCache[set][key];
    }
  }

  private static memCache = {};
}
