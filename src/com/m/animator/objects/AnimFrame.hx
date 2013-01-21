package com.m.animator.objects;

/**
 * ...
 * @author 01101101
 */

class AnimFrame
{
	
	private var frameUID:String;
	//public var duration:Int;
	public var x:Int;
	public var y:Int;
	public var flipped:Bool;
	
	/**
	 * @param	id		frame UID
	 * @param	?xPos	x
	 * @param	?yPos	y
	 * @param	?f		flipped
	 */
	public function new (id:String, ?xPos:Int = 0, ?yPos:Int = 0, ?f:Bool = false)
	{
		frameUID = id;
		x = xPos;
		y = yPos;
		flipped = f;
	}
	
}