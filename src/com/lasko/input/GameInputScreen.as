package com.lasko.input 
{
	import flash.ui.Keyboard;
	
	import com.lasko.ui.Screen;
	import com.lasko.input.GameInput;
	
	public class GameInputScreen extends GameInput
	{		
		private var screen:Screen;
		
		public function GameInputScreen(screen:Screen) 
		{
			super("screen");
			this.screen = screen;
		}
		
		protected override function keyPressed(keyCode:int):void {
			var currentBox:Object = this.screen.getCurrentBox();
			
			switch(currentBox.layout) {
				case "columns":
					if(keyCode == Keyboard.UP) {
						this.screen.changeItem(-currentBox.columns);
					} else if(keyCode == Keyboard.DOWN) {
						this.screen.changeItem(currentBox.columns);
					} else if(keyCode == Keyboard.RIGHT) {
						this.screen.changeItem(1);
					} else if(keyCode == Keyboard.LEFT) {
						this.screen.changeItem(-1);
					}
					break;
				case "vertical":
					if(keyCode == Keyboard.UP) {
						this.screen.changeItem(-1);
					} else if(keyCode == Keyboard.DOWN) {
						this.screen.changeItem(1);
						trace('down');
					}
					break;
				case "horizontal":
					if(keyCode == Keyboard.LEFT) {
						this.screen.changeItem(-1);
					} else if(keyCode == Keyboard.RIGHT) {
						this.screen.changeItem(1);
					}
					break;
				case "free":
					if(keyCode == Keyboard.LEFT || keyCode == Keyboard.UP) {
						this.screen.changeItem(-1);
					} else if(keyCode == Keyboard.RIGHT || keyCode == Keyboard.DOWN) {
						this.screen.changeItem(1);
					}
					break;
				default: break;
			}

			var selectedIndex:Object = currentBox.menuItems[this.screen.getCurrentSelectedIndex()];
			if (keyCode == 88) { //X
				if (selectedIndex) { 
					selectedIndex.callback(selectedIndex.callbackParams);
				} else {
					currentBox.defaultCallback();
				}
			} else if(keyCode == 90) { //Z
				if(selectedIndex && selectedIndex.exitCallback) {
					selectedIndex.exitCallback(selectedIndex.exitCallbackParams);
				} else {
					currentBox.defaultExitCallback();
				}
			}
		}
	}

}