package com.lasko.encounter 
{
	import flash.utils.*;
	
	import com.adobe.utils.*;
	import com.lasko.encounter.EncounterEntity
	
	public class CombatActionBase
	{
		private var source:EncounterEntity;
		private var targets:Array;
		private var targetCandidates:Array;
		
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
		
		public function setTargetCandidates(entities:Array):void {
			this.targetCandidates = entities;
		}
		
		public function getTargets():Array {
			return targets;
		}
		
		public function clearTargets():void {
			targets = [];
		}
		
		public function removeTarget(index:int):void {
			this.targets.splice(index, 1);
		}
		
		public function getSource():EncounterEntity {
			return source;
		}
		
		public function hasTargets():Boolean {
			return this.targets.length > 0;
		}
		
		//1. make sure action performer can perform the action still
		//2. if it's a single target, make sure the target is alive. if not, choose next viable target
		public function verify():Boolean {
			var sourceEntity:EncounterEntity = this.getSource();
			if (!sourceEntity.canPerformAction()) { return false; }
			
			if (this.targets.length == 1) {
				if(targets[0].getState() == EncounterEntity.STATE_DEAD) {
					for each(var entity:EncounterEntity in this.targetCandidates) {
						if (entity.getState() != EncounterEntity.STATE_DEAD) {
							targets[0] = entity;
							return true;
						}
					}
					clearTargets();
					return false;
				}
			} else {
				for (var i:int = 0; i < this.targets.length; i++) {
					if (this.targets[i].getState() == EncounterEntity.STATE_DEAD) {
						this.removeTarget(i);
					}
				}
			}
			
			return true;
		}
		
		public static function makeAction(name:String):Object {
			name[0] = name[0].toUpperCase();
			var classReference:Class = getDefinitionByName("CombatAction"+name) as Class;
			return new classReference();
		}
		
		public function execute(callback:Function):void {
			if (this.verify()) {
				this.getSource().moveToActionPosition(function():void {
					executeChild(callback);
				});
			} else {
				callback();
			}
		}
		
		//override these
		public function getName():String { return 'base';  }
		public function executeChild(callback:Function):void { }
	}

}