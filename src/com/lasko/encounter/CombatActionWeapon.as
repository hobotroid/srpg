package com.lasko.encounter 
{
	import com.lasko.entity.Character;
	
	public class CombatActionWeapon extends CombatAction
	{
		private var weaponItem:Item;
		
		public function CombatActionWeapon()
		{
			
		}
		
		public function getName():String {
			return "weapon";
		}
		
		public function setWeapon(item:Item):void {
			this.weaponItem = item;
		}
		
		public function execute():void {
			var targets:Array = this.getTargets();
			var source:Character = this.getSource();
			
			for each(var targetCharacter:Character in targets) {
				source.combat.sendAttack(targetCharacter, this.weaponItem);
			}

			showCombatAnimation(party[index], function(e:Event):void {
				doMemberAction(index + 1);
			});
			debugOut(results.message);
		}
	}

}