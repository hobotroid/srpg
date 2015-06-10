package com.lasko.input 
{
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	
	import mx.core.FlexGlobals;
	
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.Entity;
	
	import com.lasko.Global;
	import com.lasko.util.Utils;
	
	public class GameInput extends Entity
	{
		private var label:String;
		private var index:int;
		
		private static var instances:Array = new Array();
		private static var activeInstance:int = -1;
		private static var main:Object;

		private static var listening:Boolean = false;
		
		public function GameInput(label:String)
		{
			GameInput.instances.push(this);
			GameInput.activeInstance = GameInput.instances.length - 1;
			this.label = label;
			this.index = GameInput.instances.length - 1;
			
			super();
		}
		
		public function getIndex():int {
			return this.index;
		}
		
		public function getLabel():String {
			return this.label;
		}
		
		public function enable():void {
			for each(var instance:GameInput in GameInput.instances) {
				if (instance.getLabel() == this.label) {
					GameInput.activeInstance = instance.getIndex();
				}
			}
			
			GameInput.start();
		}
		
		public function disable():void {
			GameInput.stop();
		}
		
		public static function init(main:Object):void {
			GameInput.main = main;
			GameInput.start();
		}
		
		override public function update():void {
			if(GameInput.getActiveInstance() == this) {
				this.check();
			}
			
			if(Input.released(Key.F)) { //fullscreen toggle
				//this.width = flash.system.Capabilities.screenResolutionX;
				//this.height = flash.system.Capabilities.screenResolutionY;
				//this.stage.align = flash.display.StageAlign.TOP_LEFT;
				//this.stage.scaleMode = StageScaleMode.NO_SCALE;
				//this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE
				
				//if normal size, go to fullscreen, else go to normal size
				if (FlexGlobals.topLevelApplication.stage.displayState == StageDisplayState.NORMAL) {
					FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					FlexGlobals.topLevelApplication.stage.scaleMode = StageScaleMode.SHOW_ALL;
					//FlexGlobals.topLevelApplication.stage.scaleMode = StageScaleMode.EXACT_FIT;
					
				} else {
					FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;
				}
			}
			
			if (Input.released(Key.C)) {
				Global.showCollisionBoxes = !Global.showCollisionBoxes;
			}

			super.update();
		}
		
		//override these
		protected function check():void {}
		
		/**** static functions ****/
		public static function start():void
		{
			if (listening) { return; }
			listening = true;
		}
		
		public static function stop():void
		{
			listening = false;
			GameInput.activeInstance = -1;
		}
				
		public static function getInstances():Array {
			return GameInput.instances;
		}
		
		public static function getActiveInstance():GameInput {
			return GameInput.instances[GameInput.activeInstance];
		}
	}

}