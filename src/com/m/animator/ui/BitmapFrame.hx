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
	private var m_size:Rectangle;
	private var m_sourceData:BitmapData;
	private var m_bitmapData:BitmapData;
	private var m_bitmap:Bitmap;
	
	public function new (_sourceData:BitmapData, _size:Rectangle)
	{
		super();
		
		m_sourceData = _sourceData;
		m_size = _size;
		
		m_bitmapData = new BitmapData(Std.int(_size.width), Std.int(_size.height), true, 0x00FF00FF);
		m_bitmap = new Bitmap(m_bitmapData);
		addChild(m_bitmap);
		
		frame = 0;
	}
	
	private function update () :Void
	{
		var _rect:Rectangle = new Rectangle(m_size.x, m_size.y + frame * m_size.height, m_size.width, m_size.height);
		m_bitmapData.copyPixels(m_sourceData, _rect, new Point());
	}
	
	private function setFrame (_frame:Int) :Int
	{
		frame = _frame;
		update();
		return frame;
	}
	
}
