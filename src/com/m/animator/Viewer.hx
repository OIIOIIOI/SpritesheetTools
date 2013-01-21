package com.m.animator;

import com.m.animator.events.ViewerEvent;
import com.m.animator.objects.Frame;
import com.m.animator.ui.BitmapFrame;
import com.m.animator.ui.Button;
import com.m.animator.ui.Label;
import com.m.animator.ui.List;
import com.m.animator.ui.ListItem;
import com.m.animator.ui.UI;
import com.m.animator.Main;
import com.m.animator.ToolsModule;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import haxe.Json;

/**
 * ...
 * @author 01101101
 */

class Viewer extends Sprite
{
	
	private var m_sheetData:BitmapData;
	
	private var m_displayData:BitmapData;
	private var m_gridData:BitmapData;
	private var m_canvas:Bitmap;
	private var m_reactiveArea:Sprite;
	
	private var m_infosLabel:Label;
	
	private var m_toolsModule:ToolsModule;
	private var m_frameModule:FrameModule;
	//private var m_framesList:List;
	
	private var m_bgColor:UInt;
	private var m_scale:Int;
	private var m_window:Rectangle;
	private var m_center:Point;
	
	private var m_selection:Frame;
	private var m_mousePos:Point;
	private var m_mousePosPrecise:Point;
	private var m_mouseDownPos:Point;
	private var m_spaceDownPos:Point;
	private var m_mouseDown:Bool;
	private var m_spaceDown:Bool;
	private var m_shiftDown:Bool;
	
	private var m_showSheet:Bool;
	private var m_showFrames:Bool;
	
	private var m_frames:Array<Frame>;
	
	public function new (_sheetData:BitmapData, ?_jsonData:Dynamic)
	{
		super();
		
		m_sheetData = _sheetData;
		
		m_frames = new Array<Frame>();
		if (_jsonData != null) {
			parseJson(_jsonData);
		}
		
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init (_event:Event) :Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		// Settings
		m_scale = 1;
		m_bgColor = 0x0000FF00;
		
		m_showSheet = true;
		m_showFrames = true;
		
		m_mouseDown = false;
		m_spaceDown = false;
		
		m_mousePos = new Point();
		m_mousePosPrecise = new Point();
		
		// Window and display data
		m_window = new Rectangle(0, 0, stage.stageWidth - x * 2 - UI.LEFT_COL_W - UI.GUTTER, stage.stageHeight - y * 2);
		m_window.x = (m_window.width - m_sheetData.width) / 2;
		m_window.y = (m_window.height - m_sheetData.height) / 2;
		m_displayData = new BitmapData(Std.int(m_window.width), Std.int(m_window.height), true, m_bgColor);
		m_canvas = new Bitmap(m_displayData);
		m_center = new Point(m_canvas.x + m_canvas.width / 2, m_canvas.y + m_canvas.height / 2);
		
		// Alpha grid pattern for transparent background
		m_gridData = new BitmapData(UI.GRID_SIZE * 2, UI.GRID_SIZE * 2, false, 0xFFFFFFFF);
		m_gridData.fillRect(new Rectangle(0, 0, UI.GRID_SIZE, UI.GRID_SIZE), 0xFFCCCCCC);
		m_gridData.fillRect(new Rectangle(UI.GRID_SIZE, UI.GRID_SIZE, UI.GRID_SIZE, UI.GRID_SIZE), 0xFFCCCCCC);
		
		// Background
		var _matrix:Matrix = new Matrix();
		_matrix.scale(m_scale, m_scale);
		_matrix.translate(m_window.x, m_window.y);
		m_reactiveArea = new Sprite();
		m_reactiveArea.graphics.beginBitmapFill(m_gridData);
		m_reactiveArea.graphics.drawRect(0, 0, m_window.width, m_window.height);
		m_reactiveArea.graphics.endFill();
		
		// Tools module
		m_toolsModule = new ToolsModule();
		m_toolsModule.x = m_canvas.x + m_canvas.width + UI.GUTTER;
		m_toolsModule.addEventListener(ViewerEvent.OPEN_SETTINGS, toolEventHandler);
		m_toolsModule.addEventListener(ViewerEvent.SAVE, toolEventHandler);
		if (m_frames.length > 0) {
			m_toolsModule.tool = Tool.select;
		}
		
		// Infos label
		m_infosLabel = new Label("", UI.LEFT_COL_W);
		m_infosLabel.type = LabelType.info;
		m_infosLabel.x = m_toolsModule.x;
		m_infosLabel.y = m_toolsModule.y + m_toolsModule.height + UI.GUTTER;
		
		// Frames list
		/*m_framesList = new List("Frames");
		m_framesList.items = getFramesAsItems();
		m_framesList.x = m_toolsModule.x;
		m_framesList.y = m_infosLabel.y + m_infosLabel.height + UI.GUTTER;*/
		
		// Frame module
		m_frameModule = new FrameModule();
		m_frameModule.isValid = isValid;
		m_frameModule.x = m_toolsModule.x;
		//m_frameModule.y = m_framesList.y + m_framesList.height + UI.GUTTER;
		m_frameModule.y = m_infosLabel.y + m_infosLabel.height + UI.GUTTER;
		
		// Event listeners
		m_reactiveArea.buttonMode = true;
		m_reactiveArea.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		m_reactiveArea.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		m_reactiveArea.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		m_reactiveArea.addEventListener(MouseEvent.ROLL_OVER, mouseInOutHandler);
		m_reactiveArea.addEventListener(MouseEvent.ROLL_OUT, mouseInOutHandler);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(Event.RESIZE, resizeHandler);
		
		// Display
		addChild(m_reactiveArea);
		addChild(m_canvas);
		addChild(m_infosLabel);
		//addChild(m_framesList);
		addChild(m_toolsModule);
	}
	
	private function resizeHandler (?_event:Event = null) :Void
	{
		m_window.width = stage.stageWidth - x * 2 - UI.LEFT_COL_W - UI.GUTTER;
		m_window.height = stage.stageHeight - y * 2;
		m_displayData = new BitmapData(Std.int(m_window.width), Std.int(m_window.height), true, m_bgColor);
		m_canvas.bitmapData = m_displayData;
		m_center.x = m_canvas.x + m_canvas.width / 2;
		m_center.y = m_canvas.y + m_canvas.height / 2;
		
		m_toolsModule.x = m_canvas.x + m_canvas.width + UI.GUTTER;
		m_infosLabel.x = m_toolsModule.x;
		m_frameModule.x = m_toolsModule.x;
	}
	
	private function parseJson (_data:Dynamic) :Void
	{
		var _array:Array<Dynamic> = cast(_data._frames, Array<Dynamic>);
		if (_array.length <= 0)	return;
		var _frame:Frame;
		for (_f in _array) {
			_frame = new Frame();
			_frame.fromObject(_f);
			m_frames.push(_frame);
		}
	}
	
	private function mouseInOutHandler (_event:MouseEvent) :Void
	{
		if (_event.type == MouseEvent.ROLL_OVER) {
			Mouse.hide();
		} else if (_event.type == MouseEvent.ROLL_OUT) {
			m_mousePos.x = -54321;
			m_mousePos.y = -54321;
			Mouse.show();
		}
	}
	
	private function mouseWheelHandler (_event:MouseEvent) :Void
	{
		// Select target point
		var _target:Point = m_center.clone();
		if (_event.shiftKey) {
			_target = new Point(_event.localX, _event.localY);
			//_target.x += _event.localX - m_center.x;
			//_target.y += _event.localY - m_center.y;
		}
		
		// Get the diff and scale it down
		var _diff:Point = new Point(m_window.x - _target.x, m_window.y - _target.y);
		_diff.x = _diff.x / m_scale;
		_diff.y = _diff.y / m_scale;
		
		// Change scale
		if (_event.delta > 0)	m_scale++;
		else					m_scale--;
		m_scale = Std.int(Math.max(1, Math.min(m_scale, 16)));
		
		// Scale up the diff and apply
		_diff.x = _diff.x * m_scale;
		_diff.y = _diff.y * m_scale;
		m_window.x = _target.x + _diff.x;
		m_window.y = _target.y + _diff.y;
		
		// Adjust mouse position
		m_mousePos.x = Math.floor((_event.localX - m_window.x) / m_scale);
		m_mousePos.y = Math.floor((_event.localY - m_window.y) / m_scale);
	}
	
	private function mouseDownHandler (_event:MouseEvent) :Void
	{
		if (m_spaceDown) {
			m_mouseDownPos = m_mousePos.clone();
			m_toolsModule.variant = ToolVariant.startPan;
		} else if (m_toolsModule.tool == Tool.frame) {
			m_selection = new Frame(Std.int(m_mousePos.x), Std.int(m_mousePos.y));
			m_selection.state = FrameState.editing;
		}
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		m_mouseDown = true;
	}
	
	private function mouseMoveHandler (?_event:MouseEvent = null) :Void
	{
		// Refresh mouse position if _event is not null
		if (_event != null) {
			m_mousePos.x = Math.floor((_event.localX - m_window.x) / m_scale);
			m_mousePos.y = Math.floor((_event.localY - m_window.y) / m_scale);
			m_mousePosPrecise.x = _event.localX - m_window.x;
			m_mousePosPrecise.y = _event.localY - m_window.y;
		}
		if (m_mouseDown) {
			if (m_selection != null) {
				if (m_spaceDown) {
					m_selection.x += Std.int(m_mousePos.x - m_spaceDownPos.x);
					m_selection.y += Std.int(m_mousePos.y - m_spaceDownPos.y);
					m_spaceDownPos = m_mousePos.clone();
				} else {
					m_selection.width = Std.int(m_mousePos.x - m_selection.x + 1);
					m_selection.height = Std.int(m_mousePos.y - m_selection.y + 1);
					if (m_shiftDown) {
						if (m_mousePos.x - m_selection.x < m_mousePos.y - m_selection.y) {
							m_selection.height = m_selection.width;
						} else {
							m_selection.width = m_selection.height;
						}
					}
				}
			}
			else if (m_spaceDown && m_mouseDownPos != null) {
				m_window.x += (m_mousePos.x - m_mouseDownPos.x) * m_scale;
				m_window.y += (m_mousePos.y - m_mouseDownPos.y) * m_scale;
			}
		}
	}
	
	private function mouseUpHandler (_event:MouseEvent) :Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		if (m_selection != null) {
			if (isValid(m_selection)) {
				m_selection.state = FrameState.normal;
				m_frames.push(m_selection);
				// Show frame module
				addChild(m_frameModule);
				m_frameModule.setFrame(m_selection);
			}
			m_selection = null;
		} else if (m_toolsModule.tool == Tool.select && !m_spaceDown) {
			var _f:Frame = getFrameAt();
			if (_f != null) {
				m_frameModule.setFrame(_f, _event.shiftKey);
				addChild(m_frameModule);
			} else if (m_frameModule.frame != null) {
				m_frameModule.setFrame(null);
				removeChild(m_frameModule);
			}
		}
		if (m_spaceDown) {
			m_toolsModule.variant = ToolVariant.selectPan;
		}
		m_mouseDownPos = null;
		m_mouseDown = false;
	}
	
	private function isValid (_frame:Frame) :Bool
	{
		var _minSize:Int = 1;
		return (_frame.width >= _minSize &&
				_frame.height >= _minSize &&
				_frame.x >= 0 &&
				_frame.x + _frame.width <= m_sheetData.width &&
				_frame.y >= 0 &&
				_frame.y + _frame.height <= m_sheetData.height);
	}
	
	private function keyDownHandler (_event:KeyboardEvent) :Void
	{
		switch (_event.keyCode) {
			case Keyboard.SPACE:
				if (!m_spaceDown) {
					m_spaceDownPos = m_mousePos.clone();
					m_spaceDown = true;
					if (m_selection != null)	m_toolsModule.variant = ToolVariant.move;
					else						m_toolsModule.variant = ToolVariant.selectPan;
					
				}
			case Keyboard.SHIFT:
				if (!m_shiftDown) {
					m_shiftDown = true;
					mouseMoveHandler();
				}
		}
	}
	
	private function keyUpHandler (_event:KeyboardEvent) :Void
	{
		switch (_event.keyCode) {
			case Keyboard.SPACE:
				if (m_spaceDown) {
					m_spaceDownPos = null;
					m_spaceDown = false;
					m_toolsModule.variant = ToolVariant.none;
				}
			case Keyboard.SHIFT:
				if (m_shiftDown) {
					m_shiftDown = false;
					mouseMoveHandler();
				}
			case Keyboard.ESCAPE:
				if (m_frameModule.frame != null) {
					m_frameModule.setFrame(null);
					removeChild(m_frameModule);
				}
			case Keyboard.DELETE, Keyboard.BACKSPACE:
				if (m_frameModule.frame != null) {
					deleteFrame(m_frameModule.frame);
					m_frameModule.setFrame(null);
					removeChild(m_frameModule);
				}
			case Keyboard.V:
				if (m_selection == null) {
					m_toolsModule.tool = Tool.select;
				}
			case Keyboard.F:
				m_toolsModule.tool = Tool.frame;
			case Keyboard.S:
				if (_event.ctrlKey)	save();
		}
	}
	
	private function update (?_event:Event) :Void
	{
		if (m_mousePos.x != -54321 && m_mousePos.y != -54321) {
			m_infosLabel.label = "x: " + m_mousePos.x + ", y: " + m_mousePos.y;
			if (m_selection != null)
				m_infosLabel.label += ", w: " + m_selection.width + ", h: " + m_selection.height;
		}
		
		var _matrix:Matrix;
		var _tempData:BitmapData = new BitmapData(1, 1);
		var _t:Point = new Point(m_window.x, m_window.y);
		
		_matrix = new Matrix();
		_matrix.scale(m_scale, m_scale);
		_matrix.translate(_t.x, _t.y);
		m_reactiveArea.graphics.clear();
		m_reactiveArea.graphics.beginBitmapFill(m_gridData, _matrix);
		m_reactiveArea.graphics.drawRect(0, 0, m_window.width, m_window.height);
		m_reactiveArea.graphics.endFill();
		
		// Spritesheet
		m_displayData.fillRect(m_displayData.rect, m_bgColor);
		if (m_showSheet) {
			m_displayData.draw(m_sheetData, _matrix);
		}
		// Frames
		if (m_showFrames && m_frames.length > 0) {
			var _frame:Frame;
			for (_frame in m_frames) {
				_matrix = new Matrix();
				_matrix.translate(_frame.x, _frame.y);
				_matrix.scale(m_scale, m_scale);
				_matrix.translate(_t.x, _t.y);
				m_displayData.draw(_frame.getBitmapData(), _matrix);
			}
		}
		// Current selection
		if (m_selection != null) {
			if (m_selection.width < 1)	m_selection.width = 1;
			if (m_selection.height < 1)	m_selection.height = 1;
			if (isValid(m_selection))	m_selection.state = FrameState.editing;
			else						m_selection.state = FrameState.invalid;
			_matrix = new Matrix();
			_matrix.translate(m_selection.x, m_selection.y);
			_matrix.scale(m_scale, m_scale);
			_matrix.translate(_t.x, _t.y);
			m_displayData.draw(m_selection.getBitmapData(), _matrix);
		}
		// Cursor
		if (m_mousePos.x != -54321 && m_mousePos.y != -54321) {
			if (m_toolsModule.tool == Tool.frame) {
				_tempData = new BitmapData(Std.int(m_canvas.width), Std.int(m_canvas.height), true, 0x00FF00FF);
				_tempData.fillRect(new Rectangle(m_mousePos.x * m_scale + _t.x, 0, m_scale, m_canvas.height), 0x80808080);
				_tempData.fillRect(new Rectangle(0, m_mousePos.y * m_scale + _t.y, m_canvas.width, m_scale), 0x80808080);
				m_displayData.copyPixels(_tempData, _tempData.rect, new Point(), null, null, true);
			}
			_matrix = new Matrix();
			if (m_scale > 1)	_matrix.scale(2, 2);
			if (m_toolsModule.tool == Tool.select) {
				_matrix.translate(m_mousePosPrecise.x + _t.x, m_mousePosPrecise.y + _t.y);
			} else {
				_matrix.translate(m_mousePos.x * m_scale + _t.x, m_mousePos.y * m_scale + _t.y);
			}
			m_displayData.draw(m_toolsModule.cursor, _matrix);
		}
		// Clean
		_tempData.dispose();
		_tempData = null;
	}
	
	private function getFrameAt (?_point:Point = null) :Frame
	{
		// If no target point, use mouse position
		if (_point == null)	_point = m_mousePos.clone();
		
		// If no frame, return null
		if (m_frames.length <= 0) {
			return null;
		}
		// Check every frame
		for (_f in m_frames) {
			if (_point.x >= _f.x &&
				_point.x < _f.x + _f.width &&
				_point.y >= _f.y &&
				_point.y < _f.y + _f.height) {
				// If found, return frame
				return _f;
			}
		}
		// If no match, return null
		return null;
	}
	
	private function deleteFrame (_frame:Frame) :Bool
	{
		for (i in 0...m_frames.length) {
			if (m_frames[i] == _frame) {
				m_frames.splice(i, 1);
				return true;
			}
		}
		return false;
	}
	
	private function toolEventHandler (_event:ViewerEvent) :Void
	{
		switch (_event.type)
		{
			case ViewerEvent.OPEN_SETTINGS:
				trace("open settings module");
			case ViewerEvent.SAVE:
				save();
		}
	}
	
	private function getFramesAsItems () :Array<ListItem>
	{
		var _array:Array<ListItem> = new Array<ListItem>();
		var _item:ListItem;
		for (_f in m_frames) {
			_item = new ListItem(_f.uid, _f.name);
			_array.push(_item);
		}
		return _array;
	}
	
	private function save () :Void
	{
		if (m_frames.length <= 0) {
			trace("nothing to save");
			return;
		}
		var _export:Array<FrameExport> = new Array<FrameExport>();
		for (_f in m_frames) {
			_export.push(_f.getData());
		}
		var _final = { _frames:_export };
		dispatchEvent(new ViewerEvent(ViewerEvent.SAVE, Json.stringify(_final)));
	}
	
}










