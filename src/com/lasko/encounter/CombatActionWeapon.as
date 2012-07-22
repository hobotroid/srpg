package com.lasko.encounter 
{
	import flash.events.Event;
	
	import com.lasko.entity.Character;
	import com.lasko.Global;
	
	public class CombatActionWeapon extends CombatActionBase
	{
		private var weaponItem:Item;
		
		public function CombatActionWeapon()
		{

		}
		
		public override function getName():String {
			return "weapon";
		}
		
		public function setWeapon(item:Item):void {
			this.weaponItem = item;
		}
		
		public function getWeapon():Item {
			return weaponItem;
		}
	
		public override function executeChild(callback:Function):void {			
			var targets:Array = this.getTargets();
			var source:EncounterEntity = this.getSource();
			
			for each(var targetEntity:EncounterEntity in targets) {
				var result:Object = source.getCharacter().combat.sendAttack(targetEntity.getCharacter(), this.weaponItem);
				targetEntity.statChanged();
				trace(result.message);
			}
			
			source.setState(EncounterEntity.STATE_ATTACKING);
			executeAnimation(function():void {
				source.setState(EncounterEntity.STATE_WAITING);
				callback();
			});
		}
		
		private function executeAnimation(callback:Function):void {
			var sourceEntity:EncounterEntity = this.getSource();
			
			sourceEntity.showCombatAttack(function():void {
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
			});
		}
	}

}