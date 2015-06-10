package com.lasko.entity 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import com.lasko.util.Utils;
	
	public class CharacterCombat
	{
		private const FISTS_BONUS:int = 0;
		
		private var combatTarget:Object;
		private var combatAction:Object;
		private var combatTimer:Timer;
		private var combatCallback:Function;
		private var spellTarget:Object;
		private var spellAction:Object;
		private var spellTimer:Timer;
		private var spellCallback:Function;
		
		public var inCombat:Boolean = false;
		private var character:Character;
		
		public function CharacterCombat(character:Character) {
			this.character = character;
		}
		
		public function getWeaponBonus():int
		{
			return (10);
		/*if(equippedWeapon > -1) {
		   return(weapons[equippedWeapon].bonus);
		   } else {
		   return(FISTS_BONUS);
		 }*/
		}
		
		public function receiveAttack(damage:int):void
		{
			character.setHP(character.getHP() - damage);
		}
		
		public function sendAttack(dest:Character, item:Item):Object
		{
			//hit?
			var hit:Boolean = false;
			var hitCalc:int = (character.dex + getWeaponBonus()) - (dest.dex + dest.combat.getWeaponBonus()) + 10;
			hit = (Utils.randRange(1, 20) < hitCalc);
			
			//apply damage if hit
			if (hit)
			{
				var damageCalc:int = character.str + getWeaponBonus();
				var damage:int = Utils.randRange(damageCalc, 2 * damageCalc);
				dest.combat.receiveAttack(damage);
				
				return ({message: "Hit for " + damage + "!", value: damage});
			}
			else
			{
			}
			
			return ({message: "Missed!", value: null});
		}
		
		public function getEquippedWeapon():Item
		{
			return (character.getSlot("L. Hand"));
		}
		
		public function sendSpell(spell:Spell, dest:Character):Object
		{
			var results:Object = spell.cast(dest);
			character.addMP(-spell.getMpCost());
			return ({message: "Spell!", value: 100});
		}
		
		public function findCombatTarget(choices:Array):void
		{
			var rand:int = Utils.randRange(0, choices.length - 1);
			combatTarget = {"character": choices[rand], "index": rand}
		}
		
		public function getCombatTarget():Object
		{
			return (combatTarget);
		}
		
		public function getCombatAction():Object
		{
			return (combatAction);
		}
		
		public function getSpellTarget():Object
		{
			return (spellTarget);
		}
		
		public function getSpellAction():Object
		{
			return (spellAction);
		}
		
		public function clearCombatAction():void
		{
			combatTarget = null;
			combatAction = null;
			inCombat = false;
		}
		
		public function clearSpellAction():void
		{
			spellTarget = null;
			spellAction = null;
			inCombat = false;
		}
		
		public function setCombatAction(type:String, subtype:String, callback:Function):void
		{
			combatAction = {"type": type, "subtype": subtype};
			
			combatCallback = callback;
		}
		
		public function setSpellAction(spellIndex:int, callback:Function):void
		{
			spellAction = {"spellIndex": spellIndex};
			
			spellCallback = callback;
		}
		
		public function setCombatTarget(target:Character, index:int):void
		{
			combatTarget = {"character": target, "index": index};
		}
		
		public function setSpellTarget(target:Character, index:int):void
		{
			spellTarget = {"character": target, "index": index};
		}
		
		private function combatActionDone(e:TimerEvent):void
		{
			combatCallback(this, sendAttack(combatTarget.character, null));
			clearCombatAction();
		}
		
		private function spellActionDone(e:TimerEvent):void
		{
			//spellCallback(this, sendSpell(spellTarget.character));
			clearSpellAction();
		}
		
		public function performCombatActions():void
		{
			inCombat = true;
			combatTimer = new MyTimer(1000, 1);
			combatTimer.addEventListener(TimerEvent.TIMER, combatActionDone);
			combatTimer.start();
		}
		
		public function performSpellActions():void
		{
			inCombat = true;
			combatTimer = new MyTimer(1000, 1);
			combatTimer.addEventListener(TimerEvent.TIMER, spellActionDone);
			combatTimer.start();
		}
		
		private function clearTimers():void
		{
			combatTimer.stop();
			combatTimer = null;
			inCombat = false;
			combatCallback = null;
		}
		
	}

}