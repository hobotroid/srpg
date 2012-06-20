package com.lasko 
{
	import flash.events.KeyboardEvent;	
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	
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
		
		public function getId():String {
			return this.id;
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
			if(event.keyCode == 70) { //fullscreen - f key
				/*this.width = flash.system.Capabilities.screenResolutionX;
				this.height = flash.system.Capabilities.screenResolutionY;
				this.stage.align = flash.display.StageAlign.TOP_LEFT;
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
				this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE*/
				
				//if normal size, go to fullscreen, else go to normal size
				if (FlexGlobals.topLevelApplication.stage.displayState == StageDisplayState.NORMAL) {
					FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					FlexGlobals.topLevelApplication.stage.scaleMode = StageScaleMode.SHOW_ALL;
					
				} else {
					FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;
						//stage.displayState = "normal";
				}
			}
			
			GameInput.instances[GameInput.activeInstance].keyPressed(event.keyCode);
			
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		public static function getInstances():Array {
			return GameInput.instances;
		}
		
		public static function getActiveInstance():GameInput {
			return GameInput.instances[GameInput.activeInstance];
		}
		
		//override these
		protected function keyPressed(keyCode:int):void {}
	}

}