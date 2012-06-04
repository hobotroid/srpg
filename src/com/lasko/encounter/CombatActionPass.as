package com.lasko.encounter 
{
	import flash.events.Event;
	import com.lasko.entity.Character;
	
	public class CombatActionPass extends CombatActionBase
	{
		public function CombatActionPass():void
		{

		}
		
		public override function getName():String {
			return "pass";
		}
				
		public override function execute(callback:Function):void {
			callback();
		}
	}

}