/**
 * Copyright (c) 2010, Jeash contributors.
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

package jeash.net;
//import haxe.remoting.Connection;
import jeash.events.NetStatusEvent;
import haxe.Timer;
import jeash.display.Graphics;
import jeash.events.Event;
import jeash.events.EventDispatcher;
import jeash.events.NetStreamEvent;
import jeash.media.VideoElement;
import jeash.Lib;

import jeash.Html5Dom;

class NetStream extends EventDispatcher {
	/*
	 * todo:
	var audioCodec(default,null) : UInt;
	var bufferLength(default,null) : Float;
	var bufferTime :s Float;
	var bytesLoaded(default,null) : UInt;
	var bytesTotal(default,null) : UInt;
	var checkPolicyFile : Bool;
	var client : Dynamic;
	var currentFPS(default,null) : Float;
	var decodedFrames(default,null) : UInt;
	var liveDelay(default,null) : Float;
	var objectEncoding(default,null) : UInt;
	var soundTransform : jeash.media.SoundTransform;
	var time(default,null) : Float;
	var videoCodec(default,null) : UInt;
	*/
	public var bufferTime :Float;
	
	public var client:Dynamic;
	private static inline var fps:Int = 30;

	public var jeashVideoElement(default, null):HTMLMediaElement;
	
	//private var timer:Timer;
	private var jeashConnection: NetConnection;

	private var currentReadyState:Int;
	var stateTimer:Timer;

	/* events */
	public static inline var BUFFER_UPDATED:String = "jeash.net.NetStream.updated";
	
	public static inline var CODE_PLAY_STREAMNOTFOUND:String 	= "NetStream.Play.StreamNotFound";
	public static inline var CODE_BUFFER_EMPTY:String 			= "NetStream.Buffer.Empty";
	public static inline var CODE_BUFFER_FULL:String 			= "NetStream.Buffer.Full";
	public static inline var CODE_BUFFER_FLUSH:String 			= "NetStream.Buffer.Flush";
	public static inline var CODE_BUFFER_START:String 			= "NetStream.Play.Start";
	public static inline var CODE_BUFFER_STOP:String 			= "NetStream.Play.Stop";
	
	public function new(connection:NetConnection) : Void
	{	
		super();

		jeashVideoElement = cast js.Lib.document.createElement("video");
		jeashVideoElement.addEventListener("canplay", onCanPlay, false);

		jeashVideoElement.addEventListener("abort", function(e:Dynamic):Void {
			//Console.log("abort");
		}, false);

		jeashVideoElement.addEventListener("canplaythrough", function(e:Dynamic):Void {
			//Console.log("canplaythrough");
		}, false);

		jeashVideoElement.addEventListener("durationchange", function(e:Dynamic):Void {
			//Console.log("durationchange");
		}, false);

		jeashVideoElement.addEventListener("emptied", function(e:Dynamic):Void {
			//Console.log("emptied");
		}, false);

		jeashVideoElement.addEventListener("ended", function(e:Dynamic):Void {
			//Console.log("ended");
		}, false);

		jeashVideoElement.addEventListener("error", function(e:Dynamic):Void {
			//Console.log("error");
		}, false);

		jeashVideoElement.addEventListener("loadeddata", function(e:Dynamic):Void {
			//Console.log("loadeddata");
		}, false);

		jeashVideoElement.addEventListener("loadedmetadata", function(e:Dynamic):Void {
			//Console.log("loadedmetadata");
		}, false);

		jeashVideoElement.addEventListener("loadstart", function(e:Dynamic):Void {
			//Console.log("loadstart");
		}, false);

		jeashVideoElement.addEventListener("pause", function(e:Dynamic):Void {
			//Console.log("pause");
		}, false);

		jeashVideoElement.addEventListener("play", function(e:Dynamic):Void {
			//Console.log("play");
			dispatchEvent(new NetStreamEvent(NetStreamEvent.PLAY));
		}, false);

		jeashVideoElement.addEventListener("playing", function(e:Dynamic):Void {
			//Console.log("playing");
			dispatchEvent(new NetStreamEvent(NetStreamEvent.PLAYING));
		}, false);

		jeashVideoElement.addEventListener("progress", function(e:Dynamic):Void {
			//Console.log("progress " + e);
		}, false);

		jeashVideoElement.addEventListener("ratechange", function(e:Dynamic):Void {
			//Console.log("ratechange");
		}, false);

		jeashVideoElement.addEventListener("seeked", function(e:Dynamic):Void {
			//Console.log("seeked");
		}, false);

		jeashVideoElement.addEventListener("seeking", function(e:Dynamic):Void {
			//Console.log("seeking");
		}, false);

		jeashVideoElement.addEventListener("stalled", function(e:Dynamic):Void {
			//Console.log("stalled");
		}, false);

		jeashVideoElement.addEventListener("suspend", function(e:Dynamic):Void {
			//Console.log("suspend");
		}, false);

		jeashVideoElement.addEventListener("timeupdate", function(e:Dynamic):Void {
			//Console.log("timeupdate");
		}, false);

		jeashVideoElement.addEventListener("volumechange", function(e:Dynamic):Void {
			//Console.log("volumechange");
		}, false);

		jeashVideoElement.addEventListener("waiting", function(e:Dynamic):Void {
			//Console.log("waiting");
		}, false);

		_soundTransform = new flash.media.SoundTransform(1.0);

		jeashConnection = connection;

		currentReadyState = -1;

		stateTimer = new Timer(500);
		stateTimer.run = onStateTimer;

		//play = Reflect.makeVarArgs(jeashPlay);
	}

	function onCanPlay(e:Dynamic):Void {
		//Console.log("canplay event received " + jeashVideoElement.readyState + " " + e);
		dispatchEvent(new NetStreamEvent(NetStreamEvent.CAN_PLAY, currentReadyState = jeashVideoElement.readyState));
	}

	public function jeashBufferEmpty (e) jeashConnection.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_EMPTY })) 
	public function jeashBufferStop (e) jeashConnection.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_STOP }))
	public function jeashBufferStart (e) jeashConnection.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code : CODE_BUFFER_START })) 
	public function jeashNotFound (e) jeashConnection.dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, { code : CODE_PLAY_STREAMNOTFOUND })) 
	
	function jeashPlay(val:Array<Dynamic>) : Void
	{
		var url = Std.string(val[0]);
		jeashVideoElement.src = url;
	}

	public var time(getTime, setTime):Float;

	public function getTime():Float {
		return jeashVideoElement.currentTime;
	}
	public function setTime(value:Float):Float {
		return jeashVideoElement.currentTime = value;
	}

	public var soundTransform(getSoundTransform, setSoundTransform):flash.media.SoundTransform;

	var _soundTransform:flash.media.SoundTransform;
	public function getSoundTransform():flash.media.SoundTransform {
		return _soundTransform;
	}
	public function setSoundTransform(value:flash.media.SoundTransform):flash.media.SoundTransform {
		_soundTransform = value;
		jeashVideoElement.volume = _soundTransform.volume;
		return _soundTransform;
	}

	public function pause() : Void {
		jeashVideoElement.pause();
	}

	public function resume() : Void {
		jeashVideoElement.play();
	}

	public function play(url:String) : Void {
		jeashVideoElement.src = url;
		jeashVideoElement.load();
		jeashVideoElement.play();
	}

	public function seek(offset : Float) : Void {
		jeashVideoElement.currentTime = offset;
	}

	function onStateTimer():Void {
		//Console.log("state -- " + jeashVideoElement.readyState);

		if (jeashVideoElement.readyState != currentReadyState) {
			currentReadyState = jeashVideoElement.readyState;
			dispatchEvent(new NetStreamEvent(NetStreamEvent.READY_STATE_CHANGED, currentReadyState));
			if (currentReadyState == 4) {
				stateTimer.stop();
			} 
		}
	}
	
	/*
	todo:
	function attachAudio(microphone : jeash.media.Microphone) : Void;
	function attachCamera(theCamera : jeash.media.Camera, ?snapshotMilliseconds : Int) : Void;
	function close() : Void;
	function pause() : Void;
	function publish(?name : String, ?type : String) : Void;
	
	function receiveVideoFPS(FPS : Float) : Void;
	function resume() : Void;
	function seek(offset : Float) : Void;
	function send(handlerName : String, ?p1 \: Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Void;
	function togglePause() : Void;

	#if flash10
	var maxPauseBufferTime : Float;
	var farID(default,null) : String;
	var farNonce(default,null) : String;
	var info(default,null) : NetStreamInfo;
	var nearNonce(default,null) : String;
	var peerStreams(default,null) : Array<Dynamic>;

	function onPeerConnect( subscriber : NetStream ) : Bool;
	function play2( param : NetStreamPlayOptions ) : Void;

	static var DIRECT_CONNECTIONS : String;
	#end
	*/
}
