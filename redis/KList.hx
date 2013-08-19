package redis;

class KList extends Key {
	
	public function lpush( value : String ){
		return Key.CNX.lpush(key,[value]);
	}

	public function rpush( value : String ){
		return Key.CNX.rpush(key,[value]);
	}

	public function length(){
		return Key.CNX.llen(key);
	}

	public function getAt( idx : Int ){
		return Key.CNX.lindex(key,idx);
	}

	public function setAt( idx : Int, value : String ){
		return Key.CNX.lset(key,idx,value);
	}

	public function lpop(){
		return Key.CNX.lpop(key);
	}

	public function rpop(){
		return Key.CNX.rpop(key);
	}

	public function range( start : Int = 0, stop: Int = -1 ){
		return Key.CNX.lrange(key, start, stop);
	}

	public function remove( value : String, ?count = 0 ){
		return Key.CNX.lrem(key,value,count);
	}

}
