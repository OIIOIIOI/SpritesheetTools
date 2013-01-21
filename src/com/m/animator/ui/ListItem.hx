package com.m.animator.ui;

/**
 * ...
 * @author 01101101
 */

class ListItem extends Button
{
	
	public var data:Dynamic;
	
	/**
	 * @param	d	data
	 * @param	l	label
	 * @param	?w	width
	 */
	public function new (d:Dynamic, l:String, ?w:Int = 120)
	{
		data = d;
		super(l, w);
	}
	
	override private function update () :Void
	{
		var bgColor:UInt = switch (state) {
			case ButtonState.up: 0x0F0F0F;
			case ButtonState.over: 0x080808;
			case ButtonState.down: 0x000000;
			case ButtonState.disabled: 0x272727;
		}
		textFormat.color = switch (state) {
			case ButtonState.up: 0xFFFFFF;
			case ButtonState.over: 0xFE0065;
			case ButtonState.down: 0xFE0065;
			case ButtonState.disabled: 0x666666;
		}
		textField.setTextFormat(textFormat);
		
		background.graphics.clear();
		background.graphics.beginFill(bgColor);
		background.graphics.drawRect(0, 0, mWidth, 25);
		background.graphics.endFill();
		
		super.update();
	}
	
}
