package com.lasko.entity.map 
{	
	import flash.utils.getDefinitionByName;
	import flash.system.ApplicationDomain;
	
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author Matt Finnegan
	 */
	public class MapObjectFactory 
	{
		
		public function MapObjectFactory() 
		{
			
		}
		
		public function makeMapObject(className:String, index:int):GenericMapObject
		{
			var mapObject:GenericMapObject;
			
			switch(className) {
				case "DoorMapObject":
					mapObject = new DoorMapObject(index, 48, 48);
					break;
				default:
					mapObject = new GenericMapObject(index);
			}
			
			return mapObject;
		}
		
	}

}