package com.m.animator.ui;

import com.m.animator.ui.IButton;
import com.m.animator.ui.Label;
import flash.display.Shape;
import flash.display.Sprite;

/**
 * ...
 * @author 01101101
 */

class List extends Sprite
{
	
	public var items (default, setItems):Array<ListItem>;
	private var m_container:Sprite;
	private var m_titleLabel:Label;
	private var m_empty:ListItem;
	private var m_background:Shape;
	
	public function new (_title:String)
	{
		super();
		
		m_titleLabel = new Label(_title, UI.LEFT_COL_W);
		m_titleLabel.type = LabelType.title;
		
		m_container = new Sprite();
		m_container.x = UI.GUTTER;
		m_container.y = m_titleLabel.y + m_titleLabel.height + UI.GUTTER;
		
		m_background = new Shape();
		
		addChild(m_background);
		addChild(m_titleLabel);
		addChild(m_container);
		
		items = null;
	}
	
	public function update () :Void
	{
		while (m_container.numChildren > 0) {
			m_container.removeChildAt(0);
		}
		
		if (items == null || items.length == 0) {
			m_empty = new ListItem( -1, "No frame found", Std.int(m_titleLabel.width - UI.GUTTER * 2));
			m_empty.locked = true;
			m_empty.state = ButtonState.disabled;
			m_container.addChild(m_empty);
		} else {
			for (i in 0...items.length) {
				items[i].setWidth(Std.int(m_titleLabel.width - UI.GUTTER * 2));
				items[i].y = i * (items[i].height + UI.GUTTER);
				m_container.addChild(items[i]);
			}
		}
		
		m_background.graphics.clear();
		m_background.graphics.beginFill(0x0F0F0F);
		m_background.graphics.drawRect(0, m_titleLabel.height, UI.LEFT_COL_W, m_container.height + UI.GUTTER * 2);
		m_background.graphics.endFill();
	}
	
	public function setItems (_items:Array<ListItem>) :Array<ListItem>
	{
		items = _items;
		update();
		return items;
	}
	
}










