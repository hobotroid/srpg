package com.lasko.encounter 
{
	import flash.events.Event;
	import com.lasko.entity.Character;
	
	public class CombatActionItem extends CombatActionBase
	{
		private var item:Item;
		
		public function CombatActionItem():void
		{

		}
		
		public override function getName():String {
			return "item";
		}
		
		public function setItem(item:Item):void {
			this.item = item;
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