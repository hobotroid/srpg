package com.lasko.encounter 
{
	import flash.events.Event;
	
	import com.lasko.entity.Character;
	
	public class Turn 
	{
		private var goodEntities:Array;
		private var badEntities:Array;
		
		public function Turn(goodEntities:Array, badEntities:Array) 
		{
			this.goodEntities = goodEntities;
			this.badEntities = badEntities;
			
			Encounter.debugOut("-------------- new turn --------------");
			var i:int = 0;
			for (i = 0; i < goodEntities.length; i++) {
				goodEntities[i].clearAction();
			}
			for (i = 0; i < badEntities.length; i++) {
				badEntities[i].clearAction();
			}
			
			//choosing enemy targets and actions
			for (i = 0; i < badEntities.length; i++) {
				//enemies[i].character.combat.determineCombatAction(goodParty);
				//badEntities[i] = null;
			}
		}
		
		private function doMemberAction(index:int):void
		{
			//all actions done, start new turn
			if (index > goodEntities.length - 1) { 
				//endTurn();
				return;
			}

			var results:Object;
			var combatAction:CombatActionBase = goodEntities[index].action;
			if (combatAction) {
				Encounter.debugOut(goodEntities[index].character.name + "'s action is: " + combatAction.getName());
				combatAction.execute();
/*				switch(party[index].action) {
					case 'spell':
						if(party[index].target > 0) { //targetting an enemy
							results = party[index].character.combat.sendSpell(party[index].spell, enemies[party[index].target - 1].character);
						} else {				 //targetting an ally
							results = party[index].character.combat.sendSpell(party[index].spell, party[Math.abs(party[index].target) - 1].character);
						}
						showSpellAnimation(party[index], function():void {
							doMemberAction(index + 1);
						});
						debugOut(results.message);
					break;
					case 'item':
						results = party[index].item.useItem( { target: enemies[party[index].target] } );
						debugOut(results.message);
					break;
					default: break;
				}*/
			}

			goodEntities[index].update();
		}
		
		private function doEnemyAction(index:int):void
		{
			var results:Object;
			var combatAction:CombatActionBase = badEntities[index].action;
			if (combatAction) {
					Encounter.debugOut(badEntities[index].getCharacter().name + "'s action is: " + badEntities[index].action);
					switch(badEntities[index].action) {
						case 'combat':
							if(badEntities[index].target > 0) { //targetting an enemy
								results = badEntities[index].character.combat.sendAttack(badEntities[badEntities[index].target - 1].character);
							} else {				 	  //targetting an ally
								results = badEntities[index].character.combat.sendAttack(goodEntities[Math.abs(badEntities[index].target) - 1].character);
							}
							//showCombatAnimation(goodEntities[index], function(e:Event):void {
							//	doEnemyAction(index + 1);
							//});
							Encounter.debugOut(results.message);
						break;
					default: break;
				}
			}
			
			badEntities[index].update();
		}
      
		private function start():void
		{
			Encounter.debugOut('startTurn() - actions chosen for all party members + enemies, initiating turn');

			doMemberAction(0);
			doEnemyAction(0);
		}
      
		//called after all actions & their animations are done
		/*private function endTurn():void
		{
			Encounter.debugOut('endTurn()');
			var deadCount:int = 0;
			for (var i:int = 0; i < enemies.length; i++) {
				var char:Character = enemies[i].character;

				if(char.conditions[0] && char.conditions[0].isActive()) {
					char.conditions[0].applyActions();
				}
				updateCharacter(enemies[i]);

				trace(char.name+'\'s STATE: '+char.getStateName());
				if (char.getStateName() == Global.STATE_DEAD) {
					if (enemies[i].state != "dead") { 
						doEnemyDeathAnimation(i);
						enemies[i].state = "dead"
					}
					deadCount++;
				}
			}

			if (deadCount >= enemies.length) {
				Encounter.debugOut('ALL ENEMIES KILLED - ending combat');
				//endCombat();
			} else {
				newTurn();
			}
		}*/
	}
}