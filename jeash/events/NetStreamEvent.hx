package jeash.events;

class NetStreamEvent extends Event {

	public static var CAN_PLAY:String = "canPlay";
	public static var READY_STATE_CHANGED:String = "readyStateChanged";
	public static var PLAY:String = "play";
	public static var PLAYING:String = "playing";

	public var readyState(default, default):Int;

	public function new(inType : String, inReadyState:Int = -1, inBubbles : Bool=false, inCancelable : Bool=false) {
		super(inType, inBubbles, inCancelable);

		readyState = inReadyState;
	}
}