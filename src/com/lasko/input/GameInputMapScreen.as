package com.lasko.input 
{
	import flash.ui.Keyboard;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	
	import mx.core.FlexGlobals;
	
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.flashpunk.FP;
	
	import com.lasko.Global;
	import com.lasko.Game;
	
	public class GameInputMapScreen extends GameInput
	{
		//game vars
		private var party:Party;
		
		public function GameInputMapScreen() 
		{
			super("map");
			this.party = Global.game.getParty();
		}
		
		override protected function check():void {
			if (Input.check(Key.DOWN)) {
				FP.camera.y++;
			}
			
			if (Input.check(Key.UP)) {
				FP.camera.y--;
			}
			
			if (Input.check(Key.RIGHT)) {
				FP.camera.x++;
			}
			
			if (Input.check(Key.LEFT)) {
				FP.camera.x--;
			}
		}
		
		public function update2():void {
			//if no keys pressed, make character stop 
			//if (!keysPressedCount) {
				//if (Global.game.getState() == Main.GAME_STATE_PLAYING) {
				//	this.party.leader.moveStop();
				//}
				//return;
			//}
			
			//directions
			/*if (keysPressed[Keyboard.UP])
			{
				Global.game.getActiveMap().camera.y--;
				//Global.game.moveUp();
			}
			else if (keysPressed[Keyboard.DOWN])
			{
				//Global.game.moveDown();
				Global.game.getActiveMap().camera.y++;
				trace('down');
				//Global.game.getMapRenderer().scrollDown();
			}
			else if (keysPressed[Keyboard.LEFT])
			{
				//Global.game.getMapRenderer().scrollLeft();
				//Global.game.moveLeft();
			}
			else if (keysPressed[Keyboard.RIGHT])
			{
				//Global.game.getMapRenderer().scrollRight();
				//Global.game.moveRight();
			}

			//manual scrolling
			if (keysPressed[Keyboard.NUMPAD_4]) {
				//Global.game.getMapRenderer().scrollLeft();
			}
			if (keysPressed[Keyboard.NUMPAD_6]) {
				//Global.game.getMapRenderer().scrollRight();
			}
			if (keysPressed[Keyboard.NUMPAD_8]) {
				//Global.game.getMapRenderer().scrollUp();
			}
			if (keysPressed[Keyboard.NUMPAD_5]) {
				//Global.game.getMapRenderer().scrollDown();
			}
			
			//misc
			if (keysPressed[Keyboard.SPACE]) {
				//if (Global.game.getState() == Main.GAME_STATE_DEBUG) {
					//drawNextTile();
				//}
			}*/
		}
	}

}