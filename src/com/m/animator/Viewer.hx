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
	
	private var sheetData:BitmapData;
	
	private var displayData:BitmapData;
	private var gridData:BitmapData;
	private var canvas:Bitmap;
	private var reactiveArea:Sprite;
	
	private var infosLabel:Label;
	
	private var toolsModule:ToolsModule;
	private var frameModule:FrameModule;
	//private var framesList:List;
	
	private var bgColor:UInt;
	private var mScale:Int;
	private var window:Rectangle;
	private var center:Point;
	
	private var selection:Frame;
	private var mousePos:Point;
	private var mousePosPrecise:Point;
	private var mouseDownPos:Point;
	private var spaceDownPos:Point;
	private var mouseDown:Bool;
	private var spaceDown:Bool;
	private var shiftDown:Bool;
	
	private var showSheet:Bool;
	private var showFrames:Bool;
	
	private var frames:Array<Frame>;
	
	/**
	 * @param	sd	sheetData
	 * @param	?jd	jsonData
	 */
	public function new (sd:BitmapData, ?jd:Dynamic)
	{
		super();
		
		sheetData = sd;
		
		frames = new Array<Frame>();
		if (jd != null) {
			parseJson(jd);
		}
		
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init (e:Event) :Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		// Settings
		mScale = 1;
		bgColor = 0x0000FF00;
		
		showSheet = true;
		showFrames = true;
		
		mouseDown = false;
		spaceDown = false;
		
		mousePos = new Point();
		mousePosPrecise = new Point();
		
		// Window and display data
		window = new Rectangle(0, 0, stage.stageWidth - x * 2 - UI.LEFT_COL_W - UI.GUTTER, stage.stageHeight - y * 2);
		window.x = (window.width - sheetData.width) / 2;
		window.y = (window.height - sheetData.height) / 2;
		displayData = new BitmapData(Std.int(window.width), Std.int(window.height), true, bgColor);
		canvas = new Bitmap(displayData);
		center = new Point(canvas.x + canvas.width / 2, canvas.y + canvas.height / 2);
		
		// Alpha grid pattern for transparent background
		gridData = new BitmapData(UI.GRID_SIZE * 2, UI.GRID_SIZE * 2, false, 0xFFFFFFFF);
		gridData.fillRect(new Rectangle(0, 0, UI.GRID_SIZE, UI.GRID_SIZE), 0xFFCCCCCC);
		gridData.fillRect(new Rectangle(UI.GRID_SIZE, UI.GRID_SIZE, UI.GRID_SIZE, UI.GRID_SIZE), 0xFFCCCCCC);
		
		// Background
		var matrix:Matrix = new Matrix();
		matrix.scale(mScale, mScale);
		matrix.translate(window.x, window.y);
		reactiveArea = new Sprite();
		reactiveArea.graphics.beginBitmapFill(gridData);
		reactiveArea.graphics.drawRect(0, 0, window.width, window.height);
		reactiveArea.graphics.endFill();
		
		// Tools module
		toolsModule = new ToolsModule();
		toolsModule.x = canvas.x + canvas.width + UI.GUTTER;
		toolsModule.addEventListener(ViewerEvent.OPEN_SETTINGS, toolEventHandler);
		toolsModule.addEventListener(ViewerEvent.SAVE, toolEventHandler);
		if (frames.length > 0) {
			toolsModule.tool = Tool.select;
		}
		
		// Infos label
		infosLabel = new Label("", UI.LEFT_COL_W);
		infosLabel.type = LabelType.info;
		infosLabel.x = toolsModule.x;
		infosLabel.y = toolsModule.y + toolsModule.height + UI.GUTTER;
		
		// Frames list
		/*framesList = new List("Frames");
		framesList.items = getFramesAsItems();
		framesList.x = toolsModule.x;
		framesList.y = infosLabel.y + infosLabel.height + UI.GUTTER;*/
		
		// Frame module
		frameModule = new FrameModule();
		frameModule.isValid = isValid;
		frameModule.x = toolsModule.x;
		//frameModule.y = framesList.y + framesList.height + UI.GUTTER;
		frameModule.y = infosLabel.y + infosLabel.height + UI.GUTTER;
		
		// Event listeners
		reactiveArea.buttonMode = true;
		reactiveArea.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		reactiveArea.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		reactiveArea.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		reactiveArea.addEventListener(MouseEvent.ROLL_OVER, mouseInOutHandler);
		reactiveArea.addEventListener(MouseEvent.ROLL_OUT, mouseInOutHandler);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(Event.ENTER_FRAME, update);
		stage.addEventListener(Event.RESIZE, resizeHandler);
		
		// Display
		addChild(reactiveArea);
		addChild(canvas);
		addChild(infosLabel);
		//addChild(framesList);
		addChild(toolsModule);
	}
	
	private function resizeHandler (?e:Event = null) :Void
	{
		window.width = stage.stageWidth - x * 2 - UI.LEFT_COL_W - UI.GUTTER;
		window.height = stage.stageHeight - y * 2;
		displayData = new BitmapData(Std.int(window.width), Std.int(window.height), true, bgColor);
		canvas.bitmapData = displayData;
		center.x = canvas.x + canvas.width / 2;
		center.y = canvas.y + canvas.height / 2;
		
		toolsModule.x = canvas.x + canvas.width + UI.GUTTER;
		infosLabel.x = toolsModule.x;
		frameModule.x = toolsModule.x;
	}
	
	private function parseJson (d:Dynamic) :Void
	{
		var a:Array<Dynamic> = cast(d._frames, Array<Dynamic>);
		if (a.length <= 0)	return;
		var f:Frame;
		for (g in a) {
			f = new Frame();
			f.fromObject(g);
			frames.push(f);
		}
	}
	
	private function mouseInOutHandler (e:MouseEvent) :Void
	{
		if (e.type == MouseEvent.ROLL_OVER) {
			Mouse.hide();
		} else if (e.type == MouseEvent.ROLL_OUT) {
			mousePos.x = -54321;
			mousePos.y = -54321;
			Mouse.show();
		}
	}
	
	private function mouseWheelHandler (e:MouseEvent) :Void
	{
		// Select target point
		var p:Point = center.clone();
		if (e.shiftKey) {
			p = new Point(e.localX, e.localY);
		}
		
		// Get the diff and scale it down
		var d:Point = new Point(window.x - p.x, window.y - p.y);
		d.x = d.x / mScale;
		d.y = d.y / mScale;
		
		// Change scale
		if (e.delta > 0)	mScale++;
		else					mScale--;
		mScale = Std.int(Math.max(1, Math.min(mScale, 16)));
		
		// Scale up the diff and apply
		d.x = d.x * mScale;
		d.y = d.y * mScale;
		window.x = p.x + d.x;
		window.y = p.y + d.y;
		
		// Adjust mouse position
		mousePos.x = Math.floor((e.localX - window.x) / mScale);
		mousePos.y = Math.floor((e.localY - window.y) / mScale);
	}
	
	private function mouseDownHandler (e:MouseEvent) :Void
	{
		if (spaceDown) {
			mouseDownPos = mousePos.clone();
			toolsModule.variant = ToolVariant.startPan;
		} else if (toolsModule.tool == Tool.frame) {
			selection = new Frame(Std.int(mousePos.x), Std.int(mousePos.y));
			selection.state = FrameState.editing;
		}
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		mouseDown = true;
	}
	
	private function mouseMoveHandler (?e:MouseEvent = null) :Void
	{
		// Refresh mouse position if _event is not null
		if (e != null) {
			mousePos.x = Math.floor((e.localX - window.x) / mScale);
			mousePos.y = Math.floor((e.localY - window.y) / mScale);
			mousePosPrecise.x = e.localX - window.x;
			mousePosPrecise.y = e.localY - window.y;
		}
		if (mouseDown) {
			if (selection != null) {
				if (spaceDown) {
					selection.x += Std.int(mousePos.x - spaceDownPos.x);
					selection.y += Std.int(mousePos.y - spaceDownPos.y);
					spaceDownPos = mousePos.clone();
				} else {
					selection.width = Std.int(mousePos.x - selection.x + 1);
					selection.height = Std.int(mousePos.y - selection.y + 1);
					if (shiftDown) {
						if (mousePos.x - selection.x < mousePos.y - selection.y) {
							selection.height = selection.width;
						} else {
							selection.width = selection.height;
						}
					}
				}
			}
			else if (spaceDown && mouseDownPos != null) {
				window.x += (mousePos.x - mouseDownPos.x) * mScale;
				window.y += (mousePos.y - mouseDownPos.y) * mScale;
			}
		}
	}
	
	private function mouseUpHandler (e:MouseEvent) :Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		if (selection != null) {
			if (isValid(selection)) {
				selection.state = FrameState.normal;
				frames.push(selection);
				// Show frame module
				addChild(frameModule);
				frameModule.setFrame(selection);
			}
			selection = null;
		} else if (toolsModule.tool == Tool.select && !spaceDown) {
			var f:Frame = getFrameAt();
			if (f != null) {
				frameModule.setFrame(f, e.shiftKey);
				addChild(frameModule);
			} else if (frameModule.frame != null) {
				frameModule.setFrame(null);
				removeChild(frameModule);
			}
		}
		if (spaceDown) {
			toolsModule.variant = ToolVariant.selectPan;
		}
		mouseDownPos = null;
		mouseDown = false;
	}
	
	private function isValid (f:Frame) :Bool
	{
		var minSize:Int = 1;
		return (f.width >= minSize &&
				f.height >= minSize &&
				f.x >= 0 &&
				f.x + f.width <= sheetData.width &&
				f.y >= 0 &&
				f.y + f.height <= sheetData.height);
	}
	
	private function keyDownHandler (e:KeyboardEvent) :Void
	{
		switch (e.keyCode) {
			case Keyboard.SPACE:
				if (!spaceDown) {
					spaceDownPos = mousePos.clone();
					spaceDown = true;
					if (selection != null)	toolsModule.variant = ToolVariant.move;
					else						toolsModule.variant = ToolVariant.selectPan;
					
				}
			case Keyboard.SHIFT:
				if (!shiftDown) {
					shiftDown = true;
					mouseMoveHandler();
				}
		}
	}
	
	private function keyUpHandler (e:KeyboardEvent) :Void
	{
		switch (e.keyCode) {
			case Keyboard.SPACE:
				if (spaceDown) {
					spaceDownPos = null;
					spaceDown = false;
					toolsModule.variant = ToolVariant.none;
				}
			case Keyboard.SHIFT:
				if (shiftDown) {
					shiftDown = false;
					mouseMoveHandler();
				}
			case Keyboard.ESCAPE:
				if (frameModule.frame != null) {
					frameModule.setFrame(null);
					removeChild(frameModule);
				}
			case Keyboard.DELETE, Keyboard.BACKSPACE:
				if (frameModule.frame != null) {
					deleteFrame(frameModule.frame);
					frameModule.setFrame(null);
					removeChild(frameModule);
				}
			case Keyboard.V:
				if (selection == null) {
					toolsModule.tool = Tool.select;
				}
			case Keyboard.F:
				toolsModule.tool = Tool.frame;
			case Keyboard.S:
				if (e.ctrlKey)	save();
		}
	}
	
	private function update (?e:Event) :Void
	{
		if (mousePos.x != -54321 && mousePos.y != -54321) {
			infosLabel.label = "x: " + mousePos.x + ", y: " + mousePos.y;
			if (selection != null)
				infosLabel.label += ", w: " + selection.width + ", h: " + selection.height;
		}
		
		var matrix:Matrix;
		var tempData:BitmapData = new BitmapData(1, 1);
		var p:Point = new Point(window.x, window.y);
		
		matrix = new Matrix();
		matrix.scale(mScale, mScale);
		matrix.translate(p.x, p.y);
		reactiveArea.graphics.clear();
		reactiveArea.graphics.beginBitmapFill(gridData, matrix);
		reactiveArea.graphics.drawRect(0, 0, window.width, window.height);
		reactiveArea.graphics.endFill();
		
		// Spritesheet
		displayData.fillRect(displayData.rect, bgColor);
		if (showSheet) {
			displayData.draw(sheetData, matrix);
		}
		// Frames
		if (showFrames && frames.length > 0) {
			var f:Frame;
			for (f in frames) {
				matrix = new Matrix();
				matrix.translate(f.x, f.y);
				matrix.scale(mScale, mScale);
				matrix.translate(p.x, p.y);
				displayData.draw(f.getBitmapData(), matrix);
			}
		}
		// Current selection
		if (selection != null) {
			if (selection.width < 1)	selection.width = 1;
			if (selection.height < 1)	selection.height = 1;
			if (isValid(selection))	selection.state = FrameState.editing;
			else						selection.state = FrameState.invalid;
			matrix = new Matrix();
			matrix.translate(selection.x, selection.y);
			matrix.scale(mScale, mScale);
			matrix.translate(p.x, p.y);
			displayData.draw(selection.getBitmapData(), matrix);
		}
		// Cursor
		if (mousePos.x != -54321 && mousePos.y != -54321) {
			if (toolsModule.tool == Tool.frame) {
				tempData = new BitmapData(Std.int(canvas.width), Std.int(canvas.height), true, 0x00FF00FF);
				tempData.fillRect(new Rectangle(mousePos.x * mScale + p.x, 0, mScale, canvas.height), 0x80808080);
				tempData.fillRect(new Rectangle(0, mousePos.y * mScale + p.y, canvas.width, mScale), 0x80808080);
				displayData.copyPixels(tempData, tempData.rect, new Point(), null, null, true);
			}
			matrix = new Matrix();
			if (mScale > 1)	matrix.scale(2, 2);
			if (toolsModule.tool == Tool.select) {
				matrix.translate(mousePosPrecise.x + p.x, mousePosPrecise.y + p.y);
			} else {
				matrix.translate(mousePos.x * mScale + p.x, mousePos.y * mScale + p.y);
			}
			displayData.draw(toolsModule.cursor, matrix);
		}
		// Clean
		tempData.dispose();
		tempData = null;
	}
	
	private function getFrameAt (?p:Point = null) :Frame
	{
		// If no target point, use mouse position
		if (p == null)	p = mousePos.clone();
		
		// If no frame, return null
		if (frames.length <= 0) {
			return null;
		}
		// Check every frame
		for (f in frames) {
			if (p.x >= f.x &&
				p.x < f.x + f.width &&
				p.y >= f.y &&
				p.y < f.y + f.height) {
				// If found, return frame
				return f;
			}
		}
		// If no match, return null
		return null;
	}
	
	private function deleteFrame (f:Frame) :Bool
	{
		for (i in 0...frames.length) {
			if (frames[i] == f) {
				frames.splice(i, 1);
				return true;
			}
		}
		return false;
	}
	
	private function toolEventHandler (e:ViewerEvent) :Void
	{
		switch (e.type)
		{
			case ViewerEvent.OPEN_SETTINGS:
				trace("open settings module");
			case ViewerEvent.SAVE:
				save();
		}
	}
	
	private function getFramesAsItems () :Array<ListItem>
	{
		var a:Array<ListItem> = new Array<ListItem>();
		var li:ListItem;
		for (f in frames) {
			li = new ListItem(f.uid, f.name);
			a.push(li);
		}
		return a;
	}
	
	private function save () :Void
	{
		if (frames.length <= 0) {
			trace("nothing to save");
			return;
		}
		var a:Array<FrameExport> = new Array<FrameExport>();
		for (f in frames) {
			a.push(f.getData());
		}
		var b = { _frames:a };
		dispatchEvent(new ViewerEvent(ViewerEvent.SAVE, Json.stringify(b)));
	}
	
}










