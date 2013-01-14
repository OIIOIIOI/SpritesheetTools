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
	private var m_selectButton:BitmapButton;
	private var m_frameButton:BitmapButton;
	private var m_pencilButton:BitmapButton;
	private var m_settingsButton:BitmapButton;
	private var m_saveButton:BitmapButton;
	private var m_helpButton:BitmapButton;
	private var m_background:Shape;
	
	public function new ()
	{
		super();
		
		cursor = new BitmapFrame(new GUI(0, 0), new Rectangle(0, 0, 20, 20));
		
		var _bitmapFrame:BitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(20, 0, 20, 20));
		m_selectButton = new BitmapButton(_bitmapFrame);
		m_selectButton.x = m_selectButton.y = 6;
		
		_bitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(40, 0, 20, 20));
		m_frameButton = new BitmapButton(_bitmapFrame);
		m_frameButton.x = m_selectButton.x + m_selectButton.width + 6;
		m_frameButton.y = m_selectButton.y;
		
		_bitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(60, 0, 20, 20));
		m_pencilButton = new BitmapButton(_bitmapFrame);
		m_pencilButton.x = m_frameButton.x + m_frameButton.width + 6;
		m_pencilButton.y = m_selectButton.y;
		m_pencilButton.locked = true;
		m_pencilButton.state = ButtonState.disabled;
		
		_bitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(80, 0, 20, 20));
		m_settingsButton = new BitmapButton(_bitmapFrame);
		m_settingsButton.x = m_pencilButton.x + m_pencilButton.width + 6;
		m_settingsButton.y = m_selectButton.y;
		m_settingsButton.locked = true;
		m_settingsButton.state = ButtonState.disabled;
		//m_settingsButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		_bitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(100, 0, 20, 20));
		m_saveButton = new BitmapButton(_bitmapFrame);
		m_saveButton.x = m_settingsButton.x + m_settingsButton.width + 6;
		m_saveButton.y = m_selectButton.y;
		m_saveButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		_bitmapFrame = new BitmapFrame(new GUI(0, 0), new Rectangle(120, 0, 20, 20));
		m_helpButton = new BitmapButton(_bitmapFrame);
		m_helpButton.x = m_saveButton.x + m_saveButton.width + 6;
		m_helpButton.y = m_selectButton.y;
		m_helpButton.locked = true;
		m_helpButton.state = ButtonState.disabled;
		//m_helpButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		m_background = new Shape();
		m_background.graphics.beginFill(0x0F0F0F);
		m_background.graphics.drawRect(0, 0, m_helpButton.x + m_helpButton.width + 6, m_selectButton.height + 12);
		m_background.graphics.endFill();
		
		addChild(m_background);
		addChild(m_selectButton);
		addChild(m_frameButton);
		addChild(m_pencilButton);
		addChild(m_settingsButton);
		addChild(m_saveButton);
		addChild(m_helpButton);
		
		tool = Tool.frame;
	}
	
	private function update () :Void
	{
		m_selectButton.locked = false;
		m_selectButton.state = ButtonState.up;
		if (!m_selectButton.hasEventListener(MouseEvent.CLICK))
			m_selectButton.addEventListener(MouseEvent.CLICK, clickHandler);
		m_frameButton.locked = false;
		m_frameButton.state = ButtonState.up;
		if (!m_frameButton.hasEventListener(MouseEvent.CLICK))
			m_frameButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		switch (tool)
		{
			case Tool.select:
				m_selectButton.locked = true;
				m_selectButton.state = ButtonState.down;
				m_selectButton.removeEventListener(MouseEvent.CLICK, clickHandler);
				cursor.frame = 1;
			case Tool.frame:
				m_frameButton.locked = true;
				m_frameButton.state = ButtonState.down;
				m_frameButton.removeEventListener(MouseEvent.CLICK, clickHandler);
				cursor.frame = 0;
		}
	}
	
	private function clickHandler (_event:MouseEvent) :Void
	{
		switch (_event.currentTarget)
		{
			case m_selectButton:	tool = Tool.select;
			case m_frameButton:		tool = Tool.frame;
			case m_settingsButton:	dispatchEvent(new ViewerEvent(ViewerEvent.OPEN_SETTINGS));
			case m_saveButton:		dispatchEvent(new ViewerEvent(ViewerEvent.SAVE));
			case m_helpButton:		dispatchEvent(new ViewerEvent(ViewerEvent.OPEN_HELP));
		}
	}
	
	private function setVariant (_variant:ToolVariant) :ToolVariant
	{
		variant = _variant;
		switch (variant)
		{
			case ToolVariant.none: update();
			case ToolVariant.selectPan: cursor.frame = 2;
			case ToolVariant.startPan: cursor.frame = 3;
			case ToolVariant.move: cursor.frame = 4;
		}
		return variant;
	}
	
	private function setTool (_tool:Tool) :Tool
	{
		tool = _tool;
		update();
		return tool;
	}
	
}