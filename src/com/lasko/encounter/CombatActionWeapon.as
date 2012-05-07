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
		
		public override function execute():void {
			var targets:Array = this.getTargets();
			var source:Character = this.getSource();
			
			for each(var targetCharacter:Character in targets) {
				var result:Object = source.combat.sendAttack(targetCharacter, this.weaponItem);
				trace(result.message);
			}

			/*showCombatAnimation(party[index], function(e:Event):void {
				doMemberAction(index + 1);
			});*/
		}
	}

}