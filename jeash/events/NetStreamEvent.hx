package jeash.events;

class NetStreamEvent extends Event {

	public static var READY_STATE_CHANGED:String = "readyStateChanged";

	public var readyState(default, default):Int;

	public function new(inType : String, inReadyState:Int, inBubbles : Bool=false, inCancelable : Bool=false) {
		super(inType, inBubbles, inCancelable);

		readyState = inReadyState;
	}
}