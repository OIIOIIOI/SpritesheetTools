package com.m.animator;

import com.m.animator.events.ViewerEvent;
import com.m.animator.Main;
import com.m.animator.ui.BitmapButton;
import com.m.animator.ui.BitmapFrame;
import com.m.animator.ui.IButton;
import com.m.animator.ui.Label;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * ...
 * @author 01101101
 */

enum Tool {
	select;
	frame;
}

enum ToolVariant {
	selectPan;
	startPan;
	move;
	none;
}

class ToolsModule extends Sprite
{
	
	public var tool (default, setTool):Tool;
	public var variant (default, setVariant):ToolVariant;
	public var cursor (default, null):BitmapFrame;
	private var selectButton:BitmapButton;
	private var frameButton:BitmapButton;
	private var pencilButton:BitmapButton;
	private var settingsButton:BitmapButton;
	private var saveButton:BitmapButton;
	private var helpButton:BitmapButton;
	private var background:Shape;
	
	public function new ()
	{
		super();
		
		cursor = new BitmapFrame(new GUI(0, 0), new Rectangle(0, 0, 20, 20));
		
		var bf:BitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(20, 0, 20, 20));
		selectButton = new BitmapButton(bf);
		selectButton.x = selectButton.y = 6;
		
		bf = new BitmapFrame(new GUI(0, 0), new Rectangle(40, 0, 20, 20));
		frameButton = new BitmapButton(bf);
		frameButton.x = selectButton.x + selectButton.width + 6;
		frameButton.y = selectButton.y;
		
		bf = new BitmapFrame(new GUI(0, 0), new Rectangle(60, 0, 20, 20));
		pencilButton = new BitmapButton(bf);
		pencilButton.x = frameButton.x + frameButton.width + 6;
		pencilButton.y = selectButton.y;
		pencilButton.locked = true;
		pencilButton.state = ButtonState.disabled;
		
		bf = new BitmapFrame(new GUI(0, 0), new Rectangle(80, 0, 20, 20));
		settingsButton = new BitmapButton(bf);
		settingsButton.x = pencilButton.x + pencilButton.width + 6;
		settingsButton.y = selectButton.y;
		settingsButton.locked = true;
		settingsButton.state = ButtonState.disabled;
		//settingsButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		bf = new BitmapFrame(new GUI(0, 0), new Rectangle(100, 0, 20, 20));
		saveButton = new BitmapButton(bf);
		saveButton.x = settingsButton.x + settingsButton.width + 6;
		saveButton.y = selectButton.y;
		saveButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		bf = new BitmapFrame(new GUI(0, 0), new Rectangle(120, 0, 20, 20));
		helpButton = new BitmapButton(bf);
		helpButton.x = saveButton.x + saveButton.width + 6;
		helpButton.y = selectButton.y;
		helpButton.locked = true;
		helpButton.state = ButtonState.disabled;
		//helpButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		background = new Shape();
		background.graphics.beginFill(0x0F0F0F);
		background.graphics.drawRect(0, 0, helpButton.x + helpButton.width + 6, selectButton.height + 12);
		background.graphics.endFill();
		
		addChild(background);
		addChild(selectButton);
		addChild(frameButton);
		addChild(pencilButton);
		addChild(settingsButton);
		addChild(saveButton);
		addChild(helpButton);
		
		tool = Tool.frame;
	}
	
	private function update () :Void
	{
		selectButton.locked = false;
		selectButton.state = ButtonState.up;
		if (!selectButton.hasEventListener(MouseEvent.CLICK))
			selectButton.addEventListener(MouseEvent.CLICK, clickHandler);
		frameButton.locked = false;
		frameButton.state = ButtonState.up;
		if (!frameButton.hasEventListener(MouseEvent.CLICK))
			frameButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		switch (tool)
		{
			case Tool.select:
				selectButton.locked = true;
				selectButton.state = ButtonState.down;
				selectButton.removeEventListener(MouseEvent.CLICK, clickHandler);
				cursor.frame = 1;
			case Tool.frame:
				frameButton.locked = true;
				frameButton.state = ButtonState.down;
				frameButton.removeEventListener(MouseEvent.CLICK, clickHandler);
				cursor.frame = 0;
		}
	}
	
	private function clickHandler (e:MouseEvent) :Void
	{
		switch (e.currentTarget)
		{
			case selectButton:	tool = Tool.select;
			case frameButton:		tool = Tool.frame;
			case settingsButton:	dispatchEvent(new ViewerEvent(ViewerEvent.OPEN_SETTINGS));
			case saveButton:		dispatchEvent(new ViewerEvent(ViewerEvent.SAVE));
			case helpButton:		dispatchEvent(new ViewerEvent(ViewerEvent.OPEN_HELP));
		}
	}
	
	private function setVariant (v:ToolVariant) :ToolVariant
	{
		variant = v;
		switch (variant)
		{
			case ToolVariant.none: update();
			case ToolVariant.selectPan: cursor.frame = 2;
			case ToolVariant.startPan: cursor.frame = 3;
			case ToolVariant.move: cursor.frame = 4;
		}
		return variant;
	}
	
	private function setTool (t:Tool) :Tool
	{
		tool = t;
		update();
		return tool;
	}
	
}