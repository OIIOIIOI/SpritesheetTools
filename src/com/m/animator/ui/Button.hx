package com.m.animator.ui;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * ...
 * @author 01101101
 */


class Button extends IButton
{
	
	private var m_label:String;
	private var m_width:Int;
	private var m_textField:TextField;
	private var m_textFormat:TextFormat;
	private var m_background:Shape;
	
	public function new (_label:String, ?_width:Int = 120)
	{
		m_width = _width;
		
		m_textFormat = new TextFormat("Tempesta", 8, 0xFE0065);
		m_textField = new TextField();
		m_textField.embedFonts = true;
		m_textField.multiline = false;
		m_textField.selectable = false;
		m_textField.autoSize = TextFieldAutoSize.LEFT;
		m_textField.text = _label;
		m_textField.x = 8;
		m_textField.y = 3;
		
		m_background = new Shape();
		
		addChild(m_background);
		addChild(m_textField);
		
		super();
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
	
	public function setWidth (_width:Int) :Void
	{
		m_width = _width;
		update();
	}
	
}










