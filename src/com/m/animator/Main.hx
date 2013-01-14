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
	
	private var m_sheetData:BitmapData;
	private var m_jsonData:Dynamic;
	private var m_sheetFile:FileReference;
	private var m_jsonFile:FileReference;
	
	private var m_sheetButton:Button;
	private var m_sheetLabel:Label;
	private var m_jsonButton:Button;
	private var m_jsonLabel:Label;
	private var m_startButton:Button;
	private var m_startLabel:Label;
	private var m_viewer:Viewer;
	
	static function main ()
	{
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.addChild(new Main());
	}
	
	public function new ()
	{
		super();
		
		m_sheetButton = new Button("Choose PNG file");
		m_sheetButton.x = UI.GUTTER;
		m_sheetButton.y = UI.GUTTER;
		m_sheetButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		m_sheetLabel = new Label("...", 200);
		m_sheetLabel.x = m_sheetButton.x + m_sheetButton.width;
		m_sheetLabel.y = m_sheetButton.y;
		
		m_jsonButton = new Button("Choose JSON file");
		m_jsonButton.x = m_sheetButton.x;
		m_jsonButton.y = m_sheetButton.y + m_sheetButton.height + UI.GUTTER;
		m_jsonButton.addEventListener(MouseEvent.CLICK, clickHandler);
		
		m_jsonLabel = new Label("...", 200);
		m_jsonLabel.x = m_jsonButton.x + m_jsonButton.width;
		m_jsonLabel.y = m_jsonButton.y;
		
		m_startButton = new Button("Start");
		m_startButton.x = m_sheetButton.x;
		m_startButton.y = m_jsonButton.y + m_jsonButton.height + UI.GUTTER;
		m_startButton.state = ButtonState.disabled;
		
		m_startLabel = new Label("Choose a PNG file to work with", 200);
		m_startLabel.x = m_startButton.x + m_startButton.width;
		m_startLabel.y = m_startButton.y;
		
		addChild(m_sheetLabel);
		addChild(m_jsonLabel);
		addChild(m_startLabel);
		
		addChild(m_sheetButton);
		addChild(m_jsonButton);
		addChild(m_startButton);
	}
	
	private function clickHandler (_event:MouseEvent) :Void
	{
		var _pngFilter:FileFilter = new FileFilter("PNG", "*.png");
		var _jsonFilter:FileFilter = new FileFilter("JSON", "*.json");
		if (_event.currentTarget == m_sheetButton) {
			m_sheetFile = new FileReference();
			m_sheetFile.addEventListener(Event.CANCEL, fileEventHandler);
			m_sheetFile.addEventListener(Event.SELECT, fileEventHandler);
			m_sheetFile.browse([_pngFilter]);
		}
		else if (_event.currentTarget == m_jsonButton) {
			m_jsonFile = new FileReference();
			m_jsonFile.addEventListener(Event.CANCEL, fileEventHandler);
			m_jsonFile.addEventListener(Event.SELECT, fileEventHandler);
			m_jsonFile.browse([_jsonFilter]);
		}
		else if (_event.currentTarget == m_startButton && m_sheetData != null) {
			m_viewer = new Viewer(m_sheetData, m_jsonData);
			m_viewer.x = UI.OUTER_SPACE;
			m_viewer.y = UI.OUTER_SPACE;
			m_viewer.addEventListener(ViewerEvent.SAVE, viewerEventHandler);
			addChild(m_viewer);
		}
	}
	
	private function fileEventHandler (_event:Event) :Void
	{
		if (_event.type == Event.SELECT) {
			if (_event.currentTarget == m_sheetFile) {
				m_sheetLabel.label = "Loading \"" + m_sheetFile.name + "\"...";
				m_sheetFile.addEventListener(Event.COMPLETE, fileEventHandler);
				m_sheetFile.load();
			}
			else if (_event.currentTarget == m_jsonFile) {
				m_jsonFile.addEventListener(Event.COMPLETE, fileEventHandler);
				m_jsonFile.load();
			}
		}
		else if (_event.type == Event.CANCEL) {
			if (_event.currentTarget == m_sheetFile) {
				m_sheetFile = null;
			} else if (_event.currentTarget == m_jsonFile) {
				m_jsonFile = null;
			}
		}
		else if (_event.type == Event.COMPLETE) {
			if (_event.currentTarget == m_sheetFile) {
				var _loader:Loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, sheetEventHandler);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, sheetEventHandler);
				_loader.loadBytes(_event.currentTarget.data);
			}
			else if (_event.currentTarget == m_jsonFile) {
				m_jsonData = Json.parse(_event.currentTarget.data);
				m_jsonLabel.label = "\"" + m_jsonFile.name + "\" loaded";
			}
		}
	}
	
	private function sheetEventHandler (_event:Event) :Void
	{
		if (_event.type == Event.COMPLETE) {
			m_sheetLabel.label = "\"" + m_sheetFile.name + "\" loaded";
			m_startLabel.label = "Ready to start";
			m_sheetData = cast(cast(_event.currentTarget, LoaderInfo).content, Bitmap).bitmapData;
			m_startButton.state = ButtonState.up;
			m_startButton.addEventListener(MouseEvent.CLICK, clickHandler);
		}
	}
	
	private function viewerEventHandler (_event:ViewerEvent) :Void
	{
		if (_event.type == ViewerEvent.SAVE) {
			var _name:String;
			if (m_jsonFile != null) {
				_name = m_jsonFile.name;
				m_jsonFile = null;
			}
			else {
				_name = m_sheetFile.name + ".json";
				_name = _name.split(".png").join("");
			}
			m_jsonFile = new FileReference();
			m_jsonFile.addEventListener(Event.CANCEL, fileEventHandler);
			m_jsonFile.save(_event.data, _name);
		}
	}
	
}










