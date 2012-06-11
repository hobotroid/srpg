package com.lasko 
{
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
	public class GameInput extends TopLevel
	{
		private var id:String;
		
		private static var instances:Array = new Array();
		private static var activeInstance:int = -1;
		private static var main:Object;
		
		protected static var keysPressed:Array = new Array();
		public static var keysPressedCount:int = 0;
		private static var listening:Boolean = false;
		
		public function GameInput(id:String)
		{
			this.id = id;
			GameInput.instances.push(this);
			GameInput.activeInstance = GameInput.instances.length - 1;
		}
		
		public static function init(main:Object):void {
			GameInput.main = main;
			GameInput.start();
		}
		
		private static function start():void
		{
			clearKeys();
			if (listening) { return; }
			listening = true;
			main.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			main.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		private static function stop():void
		{
			main.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			main.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			listening = false;
		}
		
		private static function clearKeys():void
		{
			keysPressed = new Array();
		}
		
		private static function keyDownHandler(event:KeyboardEvent):void
		{
			if (!keysPressed[event.keyCode]) { 
				keysPressedCount++;
				keysPressed[event.keyCode] = true;
			}
			
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		private static function keyUpHandler(event:KeyboardEvent):void
		{
			GameInput.keysPressed[event.keyCode] = false;
			GameInput.keysPressedCount--;
			GameInput.keyPressedEvent(event);
			
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		private static function keyPressedEvent(event:KeyboardEvent):void
		{
			GameInput.instances[GameInput.activeInstance].keyPressed(event.keyCode);
			
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		//override these
		protected function keyPressed(keyCode:int):void {}
	}

}