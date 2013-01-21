package com.m.animator;

import com.m.animator.ui.Button;
import com.m.animator.ui.IButton;
import com.m.animator.ui.Label;
import com.m.animator.events.ViewerEvent;
import com.m.animator.ui.Button;
import com.m.animator.ui.UI;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.FileFilter;
import flash.net.FileReference;
import haxe.Json;

/**
 * ...
 * @author 01101101
 */

@:bitmap("bin/gui.png") class GUI extends flash.display.BitmapData { }

class Main extends Sprite
{
	
	private var sheetData:BitmapData;
	private var jsonData:Dynamic;
	private var sheetFile:FileReference;
	private var jsonFile:FileReference;
	
	private var sheetButton:Button;
	private var sheetLabel:Label;
	private var jsonButton:Button;
	private var jsonLabel:Label;
	private var startButton:Button;
	private var startLabel:Label;
	private var viewer:Viewer;
	
	static function main ()
	{
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.addChild(new Main());
	}
	
	public function new ()
	{
		super();
		
		sheetButton = new Button("Choose PNG file");
		sheetButton.x = UI.GUTTER;
		sheetButton.y = UI.GUTTER;
		sheetButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		sheetLabel = new Label("...", 200);
		sheetLabel.x = sheetButton.x + sheetButton.width;
		sheetLabel.y = sheetButton.y;
		
		jsonButton = new Button("Choose JSON file");
		jsonButton.x = sheetButton.x;
		jsonButton.y = sheetButton.y + sheetButton.height + UI.GUTTER;
		jsonButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		jsonLabel = new Label("...", 200);
		jsonLabel.x = jsonButton.x + jsonButton.width;
		jsonLabel.y = jsonButton.y;
		
		startButton = new Button("Start");
		startButton.x = sheetButton.x;
		startButton.y = jsonButton.y + jsonButton.height + UI.GUTTER;
		startButton.state = ButtonState.disabled;
		
		startLabel = new Label("Choose a PNG file to work with", 200);
		startLabel.x = startButton.x + startButton.width;
		startLabel.y = startButton.y;
		
		addChild(sheetLabel);
		addChild(jsonLabel);
		addChild(startLabel);
		
		addChild(sheetButton);
		addChild(jsonButton);
		addChild(startButton);
	}
	
	private function clickHandler (e:MouseEvent) :Void
	{
		var pngFilter:FileFilter = new FileFilter("PNG", "*.png");
		var jsonFilter:FileFilter = new FileFilter("JSON", "*.json");
		if (e.currentTarget == sheetButton) {
			sheetFile = new FileReference();
			sheetFile.addEventListener(Event.CANCEL, fileEventHandler);
			sheetFile.addEventListener(Event.SELECT, fileEventHandler);
			sheetFile.browse([pngFilter]);
		}
		else if (e.currentTarget == jsonButton) {
			jsonFile = new FileReference();
			jsonFile.addEventListener(Event.CANCEL, fileEventHandler);
			jsonFile.addEventListener(Event.SELECT, fileEventHandler);
			jsonFile.browse([jsonFilter]);
		}
		else if (e.currentTarget == startButton && sheetData != null) {
			viewer = new Viewer(sheetData, jsonData);
			viewer.x = UI.OUTER_SPACE;
			viewer.y = UI.OUTER_SPACE;
			viewer.addEventListener(ViewerEvent.SAVE, viewerEventHandler);
			addChild(viewer);
		}
	}
	
	private function fileEventHandler (e:Event) :Void
	{
		if (e.type == Event.SELECT) {
			if (e.currentTarget == sheetFile) {
				sheetLabel.label = "Loading \"" + sheetFile.name + "\"...";
				sheetFile.addEventListener(Event.COMPLETE, fileEventHandler);
				sheetFile.load();
			}
			else if (e.currentTarget == jsonFile) {
				jsonFile.addEventListener(Event.COMPLETE, fileEventHandler);
				jsonFile.load();
			}
		}
		else if (e.type == Event.CANCEL) {
			if (e.currentTarget == sheetFile) {
				sheetFile = null;
			} else if (e.currentTarget == jsonFile) {
				jsonFile = null;
			}
		}
		else if (e.type == Event.COMPLETE) {
			if (e.currentTarget == sheetFile) {
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, sheetEventHandler);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, sheetEventHandler);
				l.loadBytes(e.currentTarget.data);
			}
			else if (e.currentTarget == jsonFile) {
				jsonData = Json.parse(e.currentTarget.data);
				jsonLabel.label = "\"" + jsonFile.name + "\" loaded";
			}
		}
	}
	
	private function sheetEventHandler (e:Event) :Void
	{
		if (e.type == Event.COMPLETE) {
			sheetLabel.label = "\"" + sheetFile.name + "\" loaded";
			startLabel.label = "Ready to start";
			sheetData = cast(cast(e.currentTarget, LoaderInfo).content, Bitmap).bitmapData;
			startButton.state = ButtonState.up;
			startButton.addEventListener(MouseEvent.CLICK, clickHandler);
		}
	}
	
	private function viewerEventHandler (e:ViewerEvent) :Void
	{
		if (e.type == ViewerEvent.SAVE) {
			var name:String;
			if (jsonFile != null) {
				name = jsonFile.name;
				jsonFile = null;
			}
			else {
				name = sheetFile.name + ".json";
				name = name.split(".png").join("");
			}
			jsonFile = new FileReference();
			jsonFile.addEventListener(Event.CANCEL, fileEventHandler);
			jsonFile.save(e.data, name);
		}
	}
	
}










