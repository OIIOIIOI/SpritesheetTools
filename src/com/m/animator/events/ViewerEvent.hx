package com.m.animator.events;

import flash.events.Event;

/**
 * ...
 * @author 01101101
 */

class ViewerEvent extends Event
{
	inline static public var SAVE:String = "save";
	inline static public var OPEN_SETTINGS:String = "open_settings";
	inline static public var OPEN_HELP:String = "open_help";
	
	public var data:Dynamic;
	
	public function new (type:String, ?_data:Dynamic = null, ?bubbles:Bool = false, ?cancelable:Bool = false)
	{
		data = _data;
		super(type, bubbles, cancelable);
	}
	
	public override function clone () :Event
	{
		return new ViewerEvent(type, data, bubbles, cancelable);
	}
	
	public override function toString () :String
	{
		return formatToString("ViewerEvent", "data", "type", "bubbles", "cancelable", "eventPhase");
	}
	
}