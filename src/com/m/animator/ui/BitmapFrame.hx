package com.m.animator.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

class BitmapFrame extends Sprite
{
	
	public var frame (default, setFrame):Int;
	private var size:Rectangle;
	private var sourceData:BitmapData;
	private var bitmapData:BitmapData;
	private var bitmap:Bitmap;
	
	public function new (sd:BitmapData, s:Rectangle)
	{
		super();
		
		sourceData = sd;
		size = s;
		
		bitmapData = new BitmapData(Std.int(s.width), Std.int(s.height), true, 0x00FF00FF);
		bitmap = new Bitmap(bitmapData);
		addChild(bitmap);
		
		frame = 0;
	}
	
	private function update () :Void
	{
		var r:Rectangle = new Rectangle(size.x, size.y + frame * size.height, size.width, size.height);
		bitmapData.copyPixels(sourceData, r, new Point());
	}
	
	private function setFrame (f:Int) :Int
	{
		frame = f;
		update();
		return frame;
	}
	
}
