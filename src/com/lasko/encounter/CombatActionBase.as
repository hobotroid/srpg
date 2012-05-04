package com.lasko.encounter 
{
	import com.adobe.utils.ArrayUtil;
	
	import com.lasko.entity.Character;
	
	public class CombatActionBase
	{
		private var source:Character;
		private var targets:Array;
		
		public function CombatAction() 
		{
			this.targets = new Array();
		}
		
		public function setSource(character:Character):void {
			this.source = character;
		}
		
		public function addTarget(character:Character):void {
			this.targets.push(character);
		}
		
		public function setTargets(characters:Array):void {
			this.targets = ArrayUtil.createUniqueCopy(this.targets.concat(characters));
		}
		
		public static function makeAction(name:String):Object {
			name[0] = name[0].toUpperCase();
			var classReference:Class = getDefinitionByName("CombatAction"+name) as Class;
			return new classReference();
		}
		
		//override this!
		public function getName():String { }
	}

}