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
	
	private var label:String;
	private var mWidth:Int;
	private var textField:TextField;
	private var textFormat:TextFormat;
	private var background:Shape;
	
	/**
	 * @param	l	label
	 * @param	?w	width
	 */
	public function new (l:String, ?w:Int = 120)
	{
		mWidth = w;
		
		textFormat = new TextFormat("Tempesta", 8, 0xFE0065);
		textField = new TextField();
		textField.embedFonts = true;
		textField.multiline = false;
		textField.selectable = false;
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.text = l;
		textField.x = 8;
		textField.y = 3;
		
		background = new Shape();
		
		addChild(background);
		addChild(textField);
		
		super();
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
	
	public function setWidth (w:Int) :Void
	{
		mWidth = w;
		update();
	}
	
}










