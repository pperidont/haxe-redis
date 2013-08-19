package redis;

class Queue<T> {
	public var key(default,null) : String;

	public function new( key : String ){
		this.key = key;
	}

	public function publishString( s : String ){
		Key.CNX.publish(key,s);
	}
}
