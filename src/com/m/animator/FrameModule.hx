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
	
	public var frame (default, null):Frame;
	public var isValid:Frame->Bool;
	
	private var titleLabel:Label;
	private var nameLabel:Label;
	private var nameInput:Label;
	private var xLabel:Label;
	private var xInput:Label;
	private var yLabel:Label;
	private var yInput:Label;
	private var widthLabel:Label;
	private var widthInput:Label;
	private var heightLabel:Label;
	private var heightInput:Label;
	
	private var background:Shape;
	
	public function new ()
	{
		super();
		
		var lw:Int = 55;
		var iw:Int = 65;
		
		titleLabel = new Label("Frame properties", UI.LEFT_COL_W);
		titleLabel.type = LabelType.title;
		
		var fh:Int = Std.int(titleLabel.height) * 3 + UI.GUTTER * 4;
		
		background = new Shape();
		background.graphics.beginFill(0x0F0F0F);
		background.graphics.drawRect(0, titleLabel.height, UI.LEFT_COL_W, fh);
		background.graphics.endFill();
		
		// ---- Name
		// Label
		nameLabel = new Label("Name:", lw);
		nameLabel.type = LabelType.info;
		nameLabel.x = UI.GUTTER;
		nameLabel.y = titleLabel.y + titleLabel.height + UI.GUTTER;
		// Input
		nameInput = new Label("", Std.int(UI.LEFT_COL_W - nameLabel.width - UI.GUTTER * 3));
		nameInput.type = LabelType.input;
		nameInput.textField.restrict = "a-zA-Z0-9_";
		nameInput.x = nameLabel.x + nameLabel.width + UI.GUTTER;
		nameInput.y = nameLabel.y;
		nameInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- X position
		// Label
		xLabel = new Label("X pos:", lw);
		xLabel.type = LabelType.info;
		xLabel.x = 8;
		xLabel.y = nameLabel.y + nameLabel.height + UI.GUTTER;
		// Input
		xInput = new Label("", iw);
		xInput.type = LabelType.stepper;
		xInput.x = xLabel.x + xLabel.width + UI.GUTTER;
		xInput.y = xLabel.y;
		xInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Y position
		// Label
		yLabel = new Label("Y pos:", lw);
		yLabel.type = LabelType.info;
		yLabel.x = xLabel.x;
		yLabel.y = xLabel.y + xLabel.height + UI.GUTTER;
		// Input
		yInput = new Label("", iw);
		yInput.type = LabelType.stepper;
		yInput.x = yLabel.x + yLabel.width + UI.GUTTER;
		yInput.y = yLabel.y;
		yInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Width
		// Label
		widthLabel = new Label("Width:", lw);
		widthLabel.type = LabelType.info;
		widthLabel.x = xInput.x + xInput.width + UI.GUTTER;
		widthLabel.y = xLabel.y;
		// Input
		widthInput = new Label("", iw);
		widthInput.type = LabelType.stepper;
		widthInput.x = widthLabel.x + widthLabel.width + UI.GUTTER;
		widthInput.y = widthLabel.y;
		widthInput.addEventListener(Event.CHANGE, changeHandler);
		
		// ---- Height
		// Label
		heightLabel = new Label("Height:", lw);
		heightLabel.type = LabelType.info;
		heightLabel.x = yInput.x + yInput.width + UI.GUTTER;
		heightLabel.y = yLabel.y;
		// Input
		heightInput = new Label("", iw);
		heightInput.type = LabelType.stepper;
		heightInput.x = heightLabel.x + heightLabel.width + UI.GUTTER;
		heightInput.y = heightLabel.y;
		heightInput.addEventListener(Event.CHANGE, changeHandler);
		
		addChild(background);
		addChild(titleLabel);
		addChild(nameLabel);
		addChild(nameInput);
		addChild(xLabel);
		addChild(xInput);
		addChild(yLabel);
		addChild(yInput);
		addChild(widthLabel);
		addChild(widthInput);
		addChild(heightLabel);
		addChild(heightInput);
	}
	
	private function changeHandler (e:Event) :Void
	{
		var oldValue:Int;
		switch (e.currentTarget) {
			case nameInput:
				frame.name = nameInput.label;
			case xInput:
				oldValue = Std.int(frame.x);
				frame.x = Std.parseInt(xInput.label);
				if (isValid != null && !isValid(frame)) {
					xInput.label = Std.string(oldValue);
					frame.x = oldValue;
				}
			case yInput:
				oldValue = Std.int(frame.y);
				frame.y = Std.parseInt(yInput.label);
				if (isValid != null && !isValid(frame)) {
					yInput.label = Std.string(oldValue);
					frame.y = oldValue;
				}
			case widthInput:
				oldValue = Std.int(frame.width);
				frame.width = Std.parseInt(widthInput.label);
				if (isValid != null && !isValid(frame)) {
					widthInput.label = Std.string(oldValue);
					frame.width = oldValue;
				}
			case heightInput:
				oldValue = Std.int(frame.height);
				frame.height = Std.parseInt(heightInput.label);
				if (isValid != null && !isValid(frame)) {
					heightInput.label = Std.string(oldValue);
					frame.height = oldValue;
				}
		}
	}
	
	/**
	 * @param	f	frame
	 * @param	?n	new
	 */
	public function setFrame (f:Frame, ?n:Bool = false) :Void
	{
		if (frame != null) {
			frame.state = FrameState.normal;
		}
		frame = f;
		if (frame != null) {
			frame.state = FrameState.selected;
			nameInput.label = frame.name;
			if (n)	nameInput.setFocus();
			xInput.label = Std.string(frame.x);
			yInput.label = Std.string(frame.y);
			widthInput.label = Std.string(frame.width);
			heightInput.label = Std.string(frame.height);
		}
	}
	
}










