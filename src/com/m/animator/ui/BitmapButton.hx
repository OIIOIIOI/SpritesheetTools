package com.m.animator.ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

class BitmapButton extends IButton
{
	
	private var m_bitmapFrame:BitmapFrame;
	
	public function new (_bitmapFrame:BitmapFrame)
	{
		m_bitmapFrame = _bitmapFrame;
		addChild(m_bitmapFrame);
		
		super();
	}
	
	override private function update () :Void
	{
		m_bitmapFrame.frame = switch (state) {
			case ButtonState.up: 0;
			case ButtonState.over: 1;
			case ButtonState.down: 2;
			case ButtonState.disabled: 3;
		}
		
		super.update();
	}
	
}