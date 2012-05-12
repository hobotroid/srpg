package com.lasko.encounter 
{
	import flash.utils.*;
	
	import com.adobe.utils.*;
	import com.lasko.encounter.EncounterEntity
	
	public class CombatActionBase
	{
		private var source:EncounterEntity;
		private var targets:Array;
		
		public function CombatActionBase():void
		{
			this.targets = new Array();
		}
		
		public function setSource(entity:EncounterEntity):void {
			this.source = entity;
		}
		
		public function addTarget(entity:EncounterEntity):void {
			this.targets.push(entity);
		}
		
		public function setTargets(entities:Array):void {
			this.targets = ArrayUtil.createUniqueCopy(this.targets.concat(entities));
		}
		
		public function getTargets():Array {
			return targets;
		}
		
		public function getSource():EncounterEntity {
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
		public function execute(callback:Function):void {}
	}

}