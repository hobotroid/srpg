package com.lasko.encounter 
{
	import flash.utils.*;
	
	import com.adobe.utils.*;
	import com.lasko.entity.Character;
	
	public class CombatActionBase
	{
		private var source:Character;
		private var targets:Array;
		
		public function CombatActionBase():void
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
		
		public function getTargets():Array {
			return targets;
		}
		
		public function getSource():Character {
			return source;
		}
		
		public function hasTargets():Boolean {
			return this.targets.length > 0;
		}
		
		public static function makeAction(name:String):Object {
			name[0] = name[0].toUpperCase();
			var classReference:Class = getDefinitionByName("CombatAction"+name) as Class;
			return new classReference();
		}
		
		//override these
		public function getName():String { return 'base';  }
		public function execute():void {}
	}

}