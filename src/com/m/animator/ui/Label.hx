package com.m.animator.ui;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;

/**
 * ...
 * @author 01101101
 */

enum LabelType {
	hint;
	info;
	title;
	warning;
	input;
	stepper;
}

class Label extends Sprite
{
	
	public var label (default, setLabel):String;
	public var type (default, setType):LabelType;
	public var smallInc:Int;
	public var bigInc:Int;
	private var mWidth:Int;
	public var textField (default, null):TextField;
	private var textFormat:TextFormat;
	private var background:Shape;
	
	/**
	 * @param	?l	label
	 * @param	?w	width
	 */
	public function new (?l:String = "", ?w:Int = 120)
	{
		super();
		
		smallInc = 1;
		bigInc = 10;
		
		mWidth = w;
		
		textFormat = new TextFormat("Tempesta", 8, 0x666666);
		textField = new TextField();
		textField.embedFonts = true;
		textField.multiline = false;
		textField.height = 22;
		textField.x = 8;
		textField.y = 3;
		
		background = new Shape();
		
		addChild(background);
		addChild(textField);
		
		type = LabelType.hint;
		label = l;
	}
	
	private function update () :Void
	{
		var bgColor:UInt = switch (type) {
			case LabelType.hint: 0x212121;
			case LabelType.info: 0x212121;
			case LabelType.title: 0x000000;
			case LabelType.warning: 0x212121;
			case LabelType.input: 0xCCCCCC;
			case LabelType.stepper: 0xCCCCCC;
		}
		textFormat.color = switch (type) {
			case LabelType.hint: 0x666666;
			case LabelType.info: 0xDDDDDD;
			case LabelType.title: 0xFE0065;
			case LabelType.warning: 0xFF0000;
			case LabelType.input: 0x000000;
			case LabelType.stepper: 0x000000;
		}
		
		background.graphics.clear();
		background.graphics.beginFill(bgColor);
		background.graphics.drawRect(0, 0, mWidth, 25);
		background.graphics.endFill();
		
		if (label != null) {
			textField.text = label;
			textField.setTextFormat(textFormat);
		}
		
		if (type == LabelType.input || type == LabelType.stepper) {
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.width = mWidth - textField.x * 2;
			textField.type = TextFieldType.INPUT;
			if (type == LabelType.stepper)	textField.restrict = "0-9";
			textField.selectable = true;
			mouseChildren = true;
		} else {
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.type = TextFieldType.DYNAMIC;
			textField.restrict = null;
			textField.selectable = false;
			mouseChildren = false;
		}
		
		// Change event
		if ((type == LabelType.input || type == LabelType.stepper) && !textField.hasEventListener(Event.CHANGE)) {
			textField.addEventListener(Event.CHANGE, relayEvent);
			textField.addEventListener(KeyboardEvent.KEY_DOWN, keyboardEventHandler);
			textField.addEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
		}
		else if ((type != LabelType.input && type != LabelType.stepper) && textField.hasEventListener(Event.CHANGE)) {
			textField.removeEventListener(Event.CHANGE, relayEvent);
			textField.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardEventHandler);
			textField.removeEventListener(KeyboardEvent.KEY_UP, keyboardEventHandler);
		}
		// Mouse wheel event
		if (type == LabelType.stepper) {
			textField.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		else if (type != LabelType.stepper) {
			textField.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
	}
	
	private function relayEvent (e:Event) :Void
	{
		label = textField.text;
		//trace("relayEvent " + label);
		dispatchEvent(e);
	}
	
	private function mouseWheelHandler (e:MouseEvent) :Void
	{
		var v:Int = Std.parseInt(cast(e.currentTarget, TextField).text);
		var i:Int = smallInc;
		if (e.shiftKey)		i = bigInc;
		if (e.delta > 0)	v += i;
		else				v -= i;
		cast(e.currentTarget, TextField).text = Std.string(v);
		relayEvent(new Event(Event.CHANGE));
	}
	
	private function keyboardEventHandler (e:KeyboardEvent) :Void
	{
		// Let the Escape key pass through, block the rest
		if (e.keyCode != Keyboard.ESCAPE)
			e.stopImmediatePropagation();
	}
	
	private function setLabel (l:String) :String
	{
		label = l;
		update();
		return label;
	}
	
	private function setType (t:LabelType) :LabelType
	{
		type = t;
		update();
		return type;
	}
	
	public function setFocus () :Void
	{
		if ((type == LabelType.input || type == LabelType.stepper) && stage != null) {
			textField.setSelection(0, textField.length);
			stage.focus = textField;
		}
	}
	
}
