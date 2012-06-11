package com.lasko.encounter 
{
	import flash.events.Event;
	
	import com.lasko.entity.Character;
	import com.lasko.Global;
	
	public class CombatActionSpell extends CombatActionBase
	{
		private var spell:Spell;
		
		public function CombatActionWeapon():void
		{

		}
		
		public override function getName():String {
			return "spell";
		}
		
		public function setSpell(spell:Spell):void {
			this.spell = spell;
		}
		
		public override function executeChild(callback:Function):void {
			var targets:Array = this.getTargets();
			var source:EncounterEntity = this.getSource();
			var sourceCharacter:Character = source.getCharacter();
			
			for each(var targetCharacter:EncounterEntity in targets) {
				var results:Object = sourceCharacter.combat.sendSpell(this.spell, targetCharacter.getCharacter());
			}
			
			source.setState(EncounterEntity.STATE_ATTACKING);
			this.executeAnimation(function():void {
				source.setState(EncounterEntity.STATE_WAITING);
				callback();
			});
		}
		
		private function executeAnimation(callback:Function):void {
			var sourceEntity:EncounterEntity = this.getSource();
			var hitsFinished:int = 0;
			var targets:Array = getTargets();
			
			for each(var targetEntity:EncounterEntity in targets) { 
				targetEntity.showCombatHit(function():void {
					if (hitsFinished++ >= targets.length - 1) {
						if (targetEntity.getCharacter().getStateName() == Global.STATE_DEAD && targetEntity.getState() != EncounterEntity.STATE_DEAD) {
							targetEntity.die();
							targetEntity.doEnemyDeathAnimation(function():void {
								sourceEntity.returnToPosition(callback);
							});
						} else {							
							sourceEntity.returnToPosition(callback);
						}
					}
				});
			}

		}
	}

}