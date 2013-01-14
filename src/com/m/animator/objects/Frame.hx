package com.m.animator.objects;

import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

enum FrameState {
	editing;
	invalid;
	normal;
	highlighted;
	selected;
}

class Frame
{
	
	public var state (default, setState):FrameState;
	public var name:String;
	public var x:Int;
	public var y:Int;
	public var width (default, setWidth):Int;
	public var height (default, setHeight):Int;
	public var uid (default, null):String;
	public var bitmapData (getBitmapData, null):BitmapData;
	private var m_bitmapData:BitmapData;
	
	public function new (?_x:Int = 0, ?_y:Int = 0, ?_width:Int = 1, ?_height:Int = 1)
	{
		uid = Std.string(Date.now().getTime() + "_" + Std.random(1000));
		state = FrameState.normal;
		name = uid;
		x = _x;
		y = _y;
		width = _width;
		height = _height;
	}
	
	public function fromObject (_data:Dynamic) :Void
	{
		name = _data.name;
		uid = _data.uid;
		x = _data.x;
		y = _data.y;
		width = _data.width;
		height = _data.height;
	}
	
	private function setWidth (_width:Int) :Int
	{
		width = Std.int(Math.max(_width, 1));
		if (m_bitmapData != null)	m_bitmapData = null;
		return width;
	}
	
	private function setHeight (_height:Int) :Int
	{
		height = Std.int(Math.max(_height, 1));
		if (m_bitmapData != null)	m_bitmapData = null;
		return height;
	}
	
	private function setState (_state:FrameState) :FrameState
	{
		state = _state;
		if (m_bitmapData != null)	m_bitmapData = null;
		return state;
	}
	
	public function getBitmapData () :BitmapData
	{
		if (m_bitmapData == null) {
			var _borderAlpha:UInt = switch (state) {
				case FrameState.editing: 0x77000000;
				case FrameState.invalid: 0x77000000;
				case FrameState.normal: 0x77000000;
				case FrameState.highlighted: 0x77000000;
				case FrameState.selected: 0xFF000000;
			}
			var _backgroundAlpha:UInt = switch (state) {
				case FrameState.editing: 0x55000000;
				case FrameState.invalid: 0x55000000;
				case FrameState.normal: 0x55000000;
				case FrameState.highlighted: 0x55000000;
				case FrameState.selected: 0x77000000;
			}
			var _color:UInt = switch (state) {
				case FrameState.editing: 0x00FF00;
				case FrameState.invalid: 0xFF0000;
				case FrameState.normal: 0x417DFF;
				case FrameState.highlighted: 0x999999;
				case FrameState.selected: 0x417DFF;
			}
			m_bitmapData = new BitmapData(Std.int(width), Std.int(height), true, _borderAlpha + _color);
			m_bitmapData.fillRect(new Rectangle(1, 1, width - 2, height - 2), _backgroundAlpha + _color);
		}
		return m_bitmapData;
	}
	
	public function getData () :FrameExport
	{
		return new FrameExport(name, uid, Std.int(x), Std.int(y), Std.int(width), Std.int(height));
	}
	
	public function destroy () :Void
	{
		if (m_bitmapData != null) {
			m_bitmapData.dispose();
			m_bitmapData = null;
		}
	}
	
}

class FrameExport
{
	public var name:String;
	public var uid:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	
	public function new (_name:String, _uid:String, _x:Int, _y:Int, _width:Int, _height:Int)
	{
		name = _name;
		uid = _uid;
		x = _x;
		y = _y;
		width = _width;
		height = _height;
	}
}










