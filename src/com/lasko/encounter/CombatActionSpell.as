package com.lasko.encounter 
{
	import flash.events.Event;
	import com.lasko.entity.Character;
	
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
		
		public override function execute():void {
			var targets:Array = this.getTargets();
			var source:Character = this.getSource();
			
			for each(var targetCharacter:Character in targets) {
				//var result:Object = source.combat.sendAttack(targetCharacter, this.weaponItem);
				//trace(result.message);
			}

			/*showCombatAnimation(party[index], function(e:Event):void {
				doMemberAction(index + 1);
			});*/
		}
	}

}