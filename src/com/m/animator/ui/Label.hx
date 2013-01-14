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
	private var m_width:Int;
	public var textField (default, null):TextField;
	private var m_textFormat:TextFormat;
	private var m_background:Shape;

	public function new (?_label:String = "", ?_width:Int = 120)
	{
		super();
		
		smallInc = 1;
		bigInc = 10;
		
		m_width = _width;
		
		m_textFormat = new TextFormat("Tempesta", 8, 0x666666);
		textField = new TextField();
		textField.embedFonts = true;
		textField.multiline = false;
		textField.height = 22;
		textField.x = 8;
		textField.y = 3;
		
		m_background = new Shape();
		
		addChild(m_background);
		addChild(textField);
		
		type = LabelType.hint;
		label = _label;
	}
	
	private function update () :Void
	{
		var _backgroundColor:UInt = switch (type) {
			case LabelType.hint: 0x212121;
			case LabelType.info: 0x212121;
			case LabelType.title: 0x000000;
			case LabelType.warning: 0x212121;
			case LabelType.input: 0xCCCCCC;
			case LabelType.stepper: 0xCCCCCC;
		}
		m_textFormat.color = switch (type) {
			case LabelType.hint: 0x666666;
			case LabelType.info: 0xDDDDDD;
			case LabelType.title: 0xFE0065;
			case LabelType.warning: 0xFF0000;
			case LabelType.input: 0x000000;
			case LabelType.stepper: 0x000000;
		}
		
		m_background.graphics.clear();
		m_background.graphics.beginFill(_backgroundColor);
		m_background.graphics.drawRect(0, 0, m_width, 25);
		m_background.graphics.endFill();
		
		if (label != null) {
			textField.text = label;
			textField.setTextFormat(m_textFormat);
		}
		
		if (type == LabelType.input || type == LabelType.stepper) {
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.width = m_width - textField.x * 2;
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
	
	private function relayEvent (_event:Event) :Void
	{
		label = textField.text;
		trace("relayEvent " + label);
		dispatchEvent(_event);
	}
	
	private function mouseWheelHandler (_event:MouseEvent) :Void
	{
		var _val:Int = Std.parseInt(cast(_event.currentTarget, TextField).text);
		var _inc:Int = smallInc;
		if (_event.shiftKey)	_inc = bigInc;
		if (_event.delta > 0)	_val += _inc;
		else					_val -= _inc;
		cast(_event.currentTarget, TextField).text = Std.string(_val);
		relayEvent(new Event(Event.CHANGE));
	}
	
	private function keyboardEventHandler (_event:KeyboardEvent) :Void
	{
		// Let the Escape key pass through, block the rest
		if (_event.keyCode != Keyboard.ESCAPE)
			_event.stopImmediatePropagation();
	}
	
	private function setLabel (_label:String) :String
	{
		label = _label;
		update();
		return label;
	}
	
	private function setType (_type:LabelType) :LabelType
	{
		type = _type;
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
