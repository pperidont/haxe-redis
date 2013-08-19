package redis;

class KString extends Key {

	public function set( val : String, ?expire : Int ){
		return Key.CNX.set( key, val, expire );
	}

	public function get(){
		return Key.CNX.get( key );
	}

	public function length(){
		return Key.CNX.strlen( key );
	}

}
