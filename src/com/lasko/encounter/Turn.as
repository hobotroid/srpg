package com.lasko.encounter 
{
	import com.adobe.air.crypto.EncryptionKeyGenerator;
	import flash.automation.ActionGenerator;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.lasko.util.CustomEvent;
	import com.lasko.util.Utils;
	import com.lasko.entity.Character;
	import com.lasko.encounter.EncounterEntity;
	import com.lasko.Global;
	
	public class Turn extends EventDispatcher
	{
		public static const EVENT_TURN_DONE:String = "turn_done";
		
		private var goodEntities:Array;
		private var badEntities:Array;
		
		private var allEnemiesKilled:Boolean = false;
		
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
				var enemy:EncounterEntity = badEntities[i];
				//enemies[i].character.combat.determineCombatAction(goodParty);
				if(enemy.canPerformAction()) {
					var action:CombatActionWeapon = new CombatActionWeapon();
					action.setWeapon(enemy.getCharacter().combat.getEquippedWeapon());
					action.setSource(enemy);
					action.addTarget(goodEntities[0]);
					enemy.setAction(action);
					trace(enemy.getCharacter().name + ' : ACTION SET TO : ' + action.getName());
				}
			}
		}
      
		public function execute():void
		{
			Encounter.debugOut('startTurn() - actions chosen for all party members + enemies, initiating turn');
			var actionsToPerform:Array = [];
			var allEntities:Array = badEntities.concat(goodEntities);

			//prepare list of actions, then execute them sequentially
			for each(var entity:EncounterEntity in allEntities) {
				var action:CombatActionBase = entity.getAction();
				if (action) {
					actionsToPerform.push(action);
				}
			}
			
			//until initiative is implemented, just randomize actions
			actionsToPerform = Utils.randomizeArray(actionsToPerform);
			
			doAction(actionsToPerform);
		}
      
		public function doAction(actions:Array, index:int = 0):void {
			//all actions done
			if (index > actions.length - 1) {
				this.end();
				return;
			}

			var action:Object = actions[index];
			var results:Object;
			var entity:EncounterEntity = action.getSource();
			Encounter.debugOut(entity.getCharacter().name + "'s action is: " + action.getName());
			action.execute(function():void {
				doAction(actions, index + 1);
			});

			entity.update();
		}
		
		private function endCheck():void
		{
			Encounter.debugOut('turn.endCheck()');
			var shouldEndTurn:Boolean = true;
			for (var i:int = 0; i < this.badEntities.length; i++) {
				var entity:EncounterEntity = this.badEntities[i];
				var character:Character = entity.getCharacter();

				if(character.conditions[0] && character.conditions[0].isActive()) {
					character.conditions[0].applyActions();
				}
				entity.update();

				if (entity.getState() != EncounterEntity.STATE_DEAD) { 
					shouldEndTurn = false;
				}
			}
			
			if (shouldEndTurn) {
				this.end();
			}
		}
		
		private function end():void {
			Encounter.debugOut('turn.end()');
			var deadCount:int = 0;
			for (var i:int = 0; i < this.badEntities.length; i++) {
				var entity:EncounterEntity = this.badEntities[i];
				var character:Character = entity.getCharacter();

				if (character.getStateName() == Global.STATE_DEAD) {
					deadCount++;
				}
			}

			if (deadCount >= this.badEntities.length) {
				allEnemiesKilled = true;
			}
			dispatchEvent(new CustomEvent(Turn.EVENT_TURN_DONE));
		}
		
		public function getAllEnemiesKilled():Boolean {
			return this.allEnemiesKilled;
		}
	}
}