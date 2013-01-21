package com.m.animator.ui;

import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * ...
 * @author 01101101
 */

enum ButtonState {
	up;
	over;
	down;
	disabled;
}

class IButton extends Sprite
{
	
	public var state (default, setState):ButtonState;
	public var locked (default, setLocked):Bool;
	
	public function new ()
	{
		super();
		
		mouseChildren = false;
		locked = false;
		state = ButtonState.up;
	}
	
	private function update () :Void
	{
		buttonMode = switch (state) {
			case ButtonState.up: true;
			case ButtonState.over: true;
			case ButtonState.down: true;
			case ButtonState.disabled: false;
		}
		if (locked)	buttonMode = false;
		
		if (state != ButtonState.disabled && !locked && !hasEventListener(MouseEvent.ROLL_OVER)) {
			addEventListener(MouseEvent.ROLL_OVER, eventHandler);
			addEventListener(MouseEvent.ROLL_OUT, eventHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			addEventListener(MouseEvent.MOUSE_UP, eventHandler);
		}
		else if (locked || state == ButtonState.disabled && hasEventListener(MouseEvent.ROLL_OVER)) {
			removeEventListener(MouseEvent.ROLL_OVER, eventHandler);
			removeEventListener(MouseEvent.ROLL_OUT, eventHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			removeEventListener(MouseEvent.MOUSE_UP, eventHandler);
		}
	}
	
	private function eventHandler (e:MouseEvent) :Void
	{
		switch (e.type)
		{
			case MouseEvent.ROLL_OVER:	state = ButtonState.over;
			case MouseEvent.ROLL_OUT:	state = ButtonState.up;
			case MouseEvent.MOUSE_DOWN:	state = ButtonState.down;
			case MouseEvent.MOUSE_UP:	state = ButtonState.up;
		}
	}
	
	private function setState (bs:ButtonState) :ButtonState
	{
		state = bs;
		update();
		return state;
	}
	
	private function setLocked (b:Bool) :Bool
	{
		locked = b;
		if (state != null)	update();
		return locked;
	}
	
}










