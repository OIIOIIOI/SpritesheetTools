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
	
	/**
	 * @param	?xPos	x
	 * @param	?yPos	y
	 * @param	?w		width
	 * @param	?h		height
	 */
	public function new (?xPos:Int = 0, ?yPos:Int = 0, ?w:Int = 1, ?h:Int = 1)
	{
		uid = Std.string(Date.now().getTime() + "" + Std.random(1000));
		state = FrameState.normal;
		name = uid;
		x = xPos;
		y = yPos;
		width = w;
		height = h;
	}
	
	public function fromObject (d:Dynamic) :Void
	{
		name = d._name;
		uid = d._uid;
		x = d._x;
		y = d._y;
		width = d._width;
		height = d._height;
	}
	
	private function setWidth (w:Int) :Int
	{
		width = Std.int(Math.max(w, 1));
		if (bitmapData != null)	bitmapData = null;
		return width;
	}
	
	private function setHeight (h:Int) :Int
	{
		height = Std.int(Math.max(h, 1));
		if (bitmapData != null)	bitmapData = null;
		return height;
	}
	
	private function setState (s:FrameState) :FrameState
	{
		state = s;
		if (bitmapData != null)	bitmapData = null;
		return state;
	}
	
	public function getBitmapData () :BitmapData
	{
		if (bitmapData == null && width > 0 && height > 0) {
			var borderAlpha:UInt = switch (state) {
				case FrameState.editing: 0x77000000;
				case FrameState.invalid: 0x77000000;
				case FrameState.normal: 0x77000000;
				case FrameState.highlighted: 0x77000000;
				case FrameState.selected: 0xFF000000;
			}
			var backgroundAlpha:UInt = switch (state) {
				case FrameState.editing: 0x55000000;
				case FrameState.invalid: 0x55000000;
				case FrameState.normal: 0x55000000;
				case FrameState.highlighted: 0x55000000;
				case FrameState.selected: 0x77000000;
			}
			var color:UInt = switch (state) {
				case FrameState.editing: 0x00FF00;
				case FrameState.invalid: 0xFF0000;
				case FrameState.normal: 0x417DFF;
				case FrameState.highlighted: 0x999999;
				case FrameState.selected: 0x417DFF;
			}
			bitmapData = new BitmapData(Std.int(width), Std.int(height), true, borderAlpha + color);
			bitmapData.fillRect(new Rectangle(1, 1, width - 2, height - 2), backgroundAlpha + color);
		}
		return bitmapData;
	}
	
	public function getData () :FrameExport
	{
		return new FrameExport(name, uid, Std.int(x), Std.int(y), Std.int(width), Std.int(height));
	}
	
	public function destroy () :Void
	{
		if (bitmapData != null) {
			bitmapData.dispose();
			bitmapData = null;
		}
	}
	
}

class FrameExport
{
	public var _name:String;
	public var _uid:String;
	public var _x:Int;
	public var _y:Int;
	public var _width:Int;
	public var _height:Int;
	
	public function new (name:String, uid:String, x:Int, y:Int, width:Int, height:Int)
	{
		_name = name;
		_uid = uid;
		_x = x;
		_y = y;
		_width = width;
		_height = height;
	}
}










