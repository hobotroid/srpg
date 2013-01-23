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
	import com.lasko.entity.Party;
	
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
			if (Input.released(Key.X)) {
				Global.game.getParty().getLeader().useFront();
			}
			
			if (Input.check(Key.DOWN)) {
				Global.game.getParty().getLeader().walkDown();
				return;
			}
			
			if (Input.check(Key.UP)) {
				Global.game.getParty().getLeader().walkUp();
				return;
			}
			
			if (Input.check(Key.RIGHT)) {
				Global.game.getParty().getLeader().walkRight();
				return;
			}
			
			if (Input.check(Key.LEFT)) {
				Global.game.getParty().getLeader().walkLeft();
				return;
			}
			
			Global.game.getParty().getLeader().walkStop();
		}
	}

}