package redis;

class Queue<T> {
	public var key(default,null) : String;

	var q : tora.Queue<T>;

	public function new( key : String ){
		this.key = key;
		this.q = tora.Queue.get( key );
		this.q.redisConnect( redis.Key.CNX.host, redis.Key.CNX.port );
	}

	public function notify( e : T ){
		q.notify( e );
	}

	public function addHandler( h ){
		q.addHandler( h );
	}

	public function stop(){
		q.stop();
	}

}
