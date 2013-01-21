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
	private var container:Sprite;
	private var titleLabel:Label;
	private var empty:ListItem;
	private var background:Shape;
	
	/**
	 * @param	t	title
	 */
	public function new (t:String)
	{
		super();
		
		titleLabel = new Label(t, UI.LEFT_COL_W);
		titleLabel.type = LabelType.title;
		
		container = new Sprite();
		container.x = UI.GUTTER;
		container.y = titleLabel.y + titleLabel.height + UI.GUTTER;
		
		background = new Shape();
		
		addChild(background);
		addChild(titleLabel);
		addChild(container);
		
		items = null;
	}
	
	public function update () :Void
	{
		while (container.numChildren > 0) {
			container.removeChildAt(0);
		}
		
		if (items == null || items.length == 0) {
			empty = new ListItem( -1, "No frame found", Std.int(titleLabel.width - UI.GUTTER * 2));
			empty.locked = true;
			empty.state = ButtonState.disabled;
			container.addChild(empty);
		} else {
			for (i in 0...items.length) {
				items[i].setWidth(Std.int(titleLabel.width - UI.GUTTER * 2));
				items[i].y = i * (items[i].height + UI.GUTTER);
				container.addChild(items[i]);
			}
		}
		
		background.graphics.clear();
		background.graphics.beginFill(0x0F0F0F);
		background.graphics.drawRect(0, titleLabel.height, UI.LEFT_COL_W, container.height + UI.GUTTER * 2);
		background.graphics.endFill();
	}
	
	public function setItems (a:Array<ListItem>) :Array<ListItem>
	{
		items = a;
		update();
		return items;
	}
	
}










