package com.lasko.input 
{
	import flash.ui.Keyboard;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	
	import mx.core.FlexGlobals;
	
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
		
		protected override function keyPressed(keyCode:int):void {
			switch (keyCode)
			{
				case 88: //use (X key)
					trace(this.party.leader.collidingWith);
					if (this.party.leader.collidingWith)
					{
						this.party.leader.collidingWith.useItem();
					}
					break;
				case 32: //space
					
					break;
				case 82: //random encounter (capital R)
					Global.game.checkRandomEncounter(true);
					break;
				case 80: //pause
					Global.game.setState(Game.GAME_STATE_CHARACTER_SCREEN);
					break;
				case 67: //c key - toggle collision view
					Global.game.debugShowCollision = !Global.game.debugShowCollision;
					Global.game.debugHighlightedTiles = [];
					break;
				case 68: //d key - turn on debugging
					Global.game.toggleDebugging();
					break;
				case 84: //t key
					break;
				case 48: //0
					for each (var l:int in Global.game.maps[Global.game.activeMap].visibleLayers)
					{
						Global.game.maps[Global.game.activeMap].visibleLayers[l] = 1;
					}
					break;
				case 49: //1
				case 50: //2
				case 51: //3
				case 52: //4
				case 53: //5
				case 54: //6
				case 55: //7
				case 56: //8
				case 57: //9
					Global.game.maps[Global.game.activeMap].visibleLayers[keyCode - 49] = !Global.game.maps[Global.game.activeMap].visibleLayers[keyCode - 49];
					break;
				default: 
					break;
			}
		}
		
		public function update():void {
			//if no keys pressed, make character stop 
			if (!keysPressedCount) {
				if (Global.game.getState() == Game.GAME_STATE_PLAYING) {
					this.party.leader.moveStop();
				}
				return;
			}
			
			//directions
			if (keysPressed[Keyboard.UP])
			{
				Global.game.moveUp();
			}
			else if (keysPressed[Keyboard.DOWN])
			{
				Global.game.moveDown();
			}
			else if (keysPressed[Keyboard.LEFT])
			{
				Global.game.moveLeft();
			}
			else if (keysPressed[Keyboard.RIGHT])
			{
				Global.game.moveRight();
			}

			//manual scrolling
			if (keysPressed[Keyboard.NUMPAD_4]) {
				Global.game.scrollLeft();
			}
			if (keysPressed[Keyboard.NUMPAD_6]) {
				Global.game.scrollRight();
			}
			if (keysPressed[Keyboard.NUMPAD_8]) {
				Global.game.scrollUp();
			}
			if (keysPressed[Keyboard.NUMPAD_5]) {
				Global.game.scrollDown();
			}
			
			//misc
			if (keysPressed[Keyboard.SPACE]) {
				if (Global.game.getState() == Game.GAME_STATE_DEBUG) {
					//drawNextTile();
				}
			}
		}
	}

}