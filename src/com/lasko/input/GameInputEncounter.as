package com.lasko.input 
{
	import flash.ui.Keyboard;
	
	import com.lasko.ui.Screen;	
	import com.lasko.input.GameInput;
	import com.lasko.encounter.Encounter;
	
	public class GameInputEncounter extends GameInput
	{		
		private var encounter:Encounter;
		private var menues:Screen;
		
		public function GameInputEncounter(encounter:Encounter) 
		{
			super("encounter");
			this.encounter = encounter;
			this.menues = encounter.getMenus();
		}
		
		/*protected override function keyPressed(keyCode:int):void {
			switch(this.encounter.getState()) {
				case Encounter.STATE_CHOOSING_TARGET:
					if (keyCode == Keyboard.UP) {
						encounter.selectPreviousTarget();
					} else if (keyCode == Keyboard.DOWN) {
						encounter.selectNextTarget();
					} else if (keyCode == Keyboard.RIGHT || keyCode == Keyboard.LEFT) {
						if (this.encounter.getSelectedTarget() > -1) {
							this.encounter.selectTarget('ally', 1);
						} else {
							this.encounter.selectTarget('enemy', 1);
						}
					}

					if (keyCode == 88) { //X
						encounter.targetSelected();
					} else if(keyCode == 90) { //Z
						encounter.selectTarget('enemy', 1);
					}
				break;
				default: break;
			}
		}*/
	}

}