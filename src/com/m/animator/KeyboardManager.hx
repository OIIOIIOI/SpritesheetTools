package com.m.animator;

import flash.display.Stage;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author 01101101
 */

typedef CBObject = {
	var param:Dynamic;
	var call:Dynamic;
	var once:Bool;
}

class KeyboardManager
{
	
	private static var m_stage:Stage;
	private static var m_keys:Hash<Bool>;
	private static var m_callbacks:Hash<CBObject>;
	
	public function new () { }
	
	public static function init (_stage:Stage) :Void
	{
		m_stage = _stage;
		m_keys = new Hash<Bool>();
		m_callbacks = new Hash<CBObject>();
		
		m_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		m_stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}
	
	private static function keyDownHandler (_event:KeyboardEvent) :Void
	{
		var _key:String = Std.string(_event.keyCode);
		// Check for callback
		if (m_callbacks.exists(_key)) {
			var _object:CBObject = m_callbacks.get(_key);
			// Call it
			if (_object.param != null)	_object.call(_object.param);
			else						_object.call();
			// Delete callback once fired (if needed)
			if (_object.once)	deleteCallback(_event.keyCode);
		}
		// Store the key state
		m_keys.set(_key, true);
	}
	
	private static function keyUpHandler (_event:KeyboardEvent) :Void
	{
		var _key:String = Std.string(_event.keyCode);
		m_keys.remove(_key);
	}
	
	public static function isDown (_keyCode:Int) :Bool
	{
		var _key:String = Std.string(_keyCode);
		return m_keys.get(_key);
	}
	
	public static function setCallback (_keyCode:Int, _callback:Dynamic, ?_param:Dynamic, _fireOnce:Bool = false) :Void
	{
		var _object:CBObject = { call:_callback, param:_param, once:_fireOnce };
		// Store the callback
		var _key:String = Std.string(_keyCode);
		m_callbacks.set(_key, _object);
	}
	
	public static function deleteCallback (_keyCode:Int) :Void
	{
		// Delete the callback
		var _key:String = Std.string(_keyCode);
		m_callbacks.remove(_key);
	}
	
}










