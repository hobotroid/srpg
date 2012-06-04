package com.lasko.encounter 
{
	import flash.events.Event;
	import com.lasko.entity.Character;
	
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
		
		public override function execute(callback:Function):void {			
			var targets:Array = this.getTargets();
			var source:EncounterEntity = this.getSource();
			
			for each(var targetEntity:EncounterEntity in targets) {
				var result:Object = source.getCharacter().combat.sendAttack(targetEntity.getCharacter(), this.weaponItem);
				trace(result.message);
			}

			source.showCombatAnimation(callback);
			/*showCombatAnimation(party[index], function(e:Event):void {
				doMemberAction(index + 1);
			});*/
		}
	}

}