package com.m.animator;

import com.m.animator.objects.Frame;
import com.m.animator.ui.Label;
import com.m.animator.ui.UI;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

/**
 * ...
 * @author 01101101
 */

class FrameModule extends Sprite
{
	
	public var frame (getFrame, null):Frame;
	private var m_frame:Frame;
	public var isValid:Frame->Bool;
	
	private var m_titleLabel:Label;
	private var m_nameLabel:Label;
	private var m_nameInput:Label;
	private var m_xLabel:Label;
	private var m_xInput:Label;
	private var m_yLabel:Label;
	private var m_yInput:Label;
	private var m_widthLabel:Label;
	private var m_widthInput:Label;
	private var m_heightLabel:Label;
	private var m_heightInput:Label;
	
	private var m_background:Shape;
	
	public function new ()
	{
		super();
		
		var _labelWidth:Int = 55;
		var _inputWidth:Int = 65;
		
		m_titleLabel = new Label("Frame properties", UI.LEFT_COL_W);
		m_titleLabel.type = LabelType.title;
		
		var _fullHeight:Int = Std.int(m_titleLabel.height) * 3 + UI.GUTTER * 4;
		
		m_background = new Shape();
		m_background.graphics.beginFill(0x0F0F0F);
		m_background.graphics.drawRect(0, m_titleLabel.height, UI.LEFT_COL_W, _fullHeight);
		m_background.graphics.endFill();
		
		// ---- Name
		// Label
		m_nameLabel = new Label("Name:", _labelWidth);
		m_nameLabel.type = LabelType.info;
		m_nameLabel.x = UI.GUTTER;
		m_nameLabel.y = m_titleLabel.y + m_titleLabel.height + UI.GUTTER;
		// Input
		m_nameInput = new Label("", Std.int(UI.LEFT_COL_W - m_nameLabel.width - UI.GUTTER * 3));
		m_nameInput.type = LabelType.input;
		m_nameInput.textField.restrict = "a-zA-Z0-9_";
		m_nameInput.x = m_nameLabel.x + m_nameLabel.width + UI.GUTTER;
		m_nameInput.y = m_nameLabel.y;
		m_nameInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- X position
		// Label
		m_xLabel = new Label("X pos:", _labelWidth);
		m_xLabel.type = LabelType.info;
		m_xLabel.x = 8;
		m_xLabel.y = m_nameLabel.y + m_nameLabel.height + UI.GUTTER;
		// Input
		m_xInput = new Label("", _inputWidth);
		m_xInput.type = LabelType.stepper;
		m_xInput.x = m_xLabel.x + m_xLabel.width + UI.GUTTER;
		m_xInput.y = m_xLabel.y;
		m_xInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Y position
		// Label
		m_yLabel = new Label("Y pos:", _labelWidth);
		m_yLabel.type = LabelType.info;
		m_yLabel.x = m_xLabel.x;
		m_yLabel.y = m_xLabel.y + m_xLabel.height + UI.GUTTER;
		// Input
		m_yInput = new Label("", _inputWidth);
		m_yInput.type = LabelType.stepper;
		m_yInput.x = m_yLabel.x + m_yLabel.width + UI.GUTTER;
		m_yInput.y = m_yLabel.y;
		m_yInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Width
		// Label
		m_widthLabel = new Label("Width:", _labelWidth);
		m_widthLabel.type = LabelType.info;
		m_widthLabel.x = m_xInput.x + m_xInput.width + UI.GUTTER;
		m_widthLabel.y = m_xLabel.y;
		// Input
		m_widthInput = new Label("", _inputWidth);
		m_widthInput.type = LabelType.stepper;
		m_widthInput.x = m_widthLabel.x + m_widthLabel.width + UI.GUTTER;
		m_widthInput.y = m_widthLabel.y;
		m_widthInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Height
		// Label
		m_heightLabel = new Label("Height:", _labelWidth);
		m_heightLabel.type = LabelType.info;
		m_heightLabel.x = m_yInput.x + m_yInput.width + UI.GUTTER;
		m_heightLabel.y = m_yLabel.y;
		// Input
		m_heightInput = new Label("", _inputWidth);
		m_heightInput.type = LabelType.stepper;
		m_heightInput.x = m_heightLabel.x + m_heightLabel.width + UI.GUTTER;
		m_heightInput.y = m_heightLabel.y;
		m_heightInput.addEventListener(Event.CHANGE, changeHandler);
		
		addChild(m_background);
		addChild(m_titleLabel);
		addChild(m_nameLabel);
		addChild(m_nameInput);
		addChild(m_xLabel);
		addChild(m_xInput);
		addChild(m_yLabel);
		addChild(m_yInput);
		addChild(m_widthLabel);
		addChild(m_widthInput);
		addChild(m_heightLabel);
		addChild(m_heightInput);
	}
	
	private function changeHandler (_event:Event) :Void
	{
		var _oldValue:Int;
		switch (_event.currentTarget) {
			case m_nameInput:
				frame.name = m_nameInput.label;
			case m_xInput:
				_oldValue = Std.int(frame.x);
				frame.x = Std.parseInt(m_xInput.label);
				if (isValid != null && !isValid(frame)) {
					m_xInput.label = Std.string(_oldValue);
					frame.x = _oldValue;
				}
			case m_yInput:
				_oldValue = Std.int(frame.y);
				frame.y = Std.parseInt(m_yInput.label);
				if (isValid != null && !isValid(frame)) {
					m_yInput.label = Std.string(_oldValue);
					frame.y = _oldValue;
				}
			case m_widthInput:
				_oldValue = Std.int(frame.width);
				frame.width = Std.parseInt(m_widthInput.label);
				if (isValid != null && !isValid(frame)) {
					m_widthInput.label = Std.string(_oldValue);
					frame.width = _oldValue;
				}
			case m_heightInput:
				_oldValue = Std.int(frame.height);
				frame.height = Std.parseInt(m_heightInput.label);
				if (isValid != null && !isValid(frame)) {
					m_heightInput.label = Std.string(_oldValue);
					frame.height = _oldValue;
				}
		}
	}
	
	private function getFrame () :Frame { return m_frame; }
	
	public function setFrame (_frame:Frame, ?_new:Bool = false) :Void
	{
		if (m_frame != null) {
			m_frame.state = FrameState.normal;
		}
		m_frame = _frame;
		if (m_frame != null) {
			m_frame.state = FrameState.selected;
			m_nameInput.label = m_frame.name;
			if (_new)	m_nameInput.setFocus();
			m_xInput.label = Std.string(m_frame.x);
			m_yInput.label = Std.string(m_frame.y);
			m_widthInput.label = Std.string(m_frame.width);
			m_heightInput.label = Std.string(m_frame.height);
		}
	}
	
}










