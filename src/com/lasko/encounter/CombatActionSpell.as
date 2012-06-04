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
		
		public override function execute(callback:Function):void {
			var targets:Array = this.getTargets();
			var source:EncounterEntity = this.getSource();
			var sourceCharacter:Character = source.getCharacter();
			
			for each(var targetCharacter:EncounterEntity in targets) {
				var results:Object = sourceCharacter.combat.sendSpell(this.spell, targetCharacter.getCharacter());
			}

			source.showSpellAnimation(callback);
		}
	}

}