package com.m.animator.ui;

/**
 * ...
 * @author 01101101
 */

class ListItem extends Button
{
	
	public var data:Dynamic;
	
	public function new (_data:Dynamic, _label:String, ?_width:Int = 120)
	{
		data = _data;
		super(_label, _width);
	}
	
	override private function update () :Void
	{
		var _backgroundColor:UInt = switch (state) {
			case ButtonState.up: 0x0F0F0F;
			case ButtonState.over: 0x080808;
			case ButtonState.down: 0x000000;
			case ButtonState.disabled: 0x272727;
		}
		m_textFormat.color = switch (state) {
			case ButtonState.up: 0xFFFFFF;
			case ButtonState.over: 0xFE0065;
			case ButtonState.down: 0xFE0065;
			case ButtonState.disabled: 0x666666;
		}
		m_textField.setTextFormat(m_textFormat);
		
		m_background.graphics.clear();
		m_background.graphics.beginFill(_backgroundColor);
		m_background.graphics.drawRect(0, 0, m_width, 25);
		m_background.graphics.endFill();
		
		super.update();
	}
	
}
