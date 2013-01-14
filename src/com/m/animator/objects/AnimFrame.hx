package com.m.animator.objects;

/**
 * ...
 * @author 01101101
 */

class AnimFrame
{
	
	private var m_frameUID:String;
	//public var duration:Int;
	public var x:Int;
	public var y:Int;
	public var flipped:Bool;
	
	public function new (_frameUID:String, ?_x:Int = 0, ?_y:Int = 0, ?_flipped:Bool = false)
	{
		m_frameUID = _frameUID;
		x = _x;
		y = _y;
		flipped = _flipped;
	}
	
}