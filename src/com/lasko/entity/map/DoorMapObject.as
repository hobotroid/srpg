package com.lasko.entity.map 
{
	import flash.geom.Rectangle;
	
	import com.lasko.entity.map.GenericMapObject;
	import com.lasko.Global;	
	
	/**
	 * ...
	 * @author Matt Finnegan
	 */
	public class DoorMapObject extends GenericMapObject 
	{
		public const STATE_CLOSED:int = 1;
		public const STATE_OPEN:int = 2;
		
		private var state:int = STATE_CLOSED;
		
		public function DoorMapObject(index:int, width:int, height:int) 
		{
			super(index);
			
			this.collisionRect = new Rectangle(0, height - 24, width, 24);
			this.collidable = true;
			type = Global.COLLISION_MAP_OBJECT_COLLIDABLE;
			this.setHitboxTo(collisionRect);
		}
		
		override public function performCollision():void 
		{
			if (state == STATE_CLOSED) {	//open the door
				this.setGraphic(this.spriteIndex + 1);
				state = STATE_OPEN;
				type = Global.COLLISION_MAP_OBJECT;
			} else {						//close the door
				this.setGraphic(this.spriteIndex);
				state = STATE_CLOSED;
				type = Global.COLLISION_MAP_OBJECT_COLLIDABLE;
			}
		}
		
	}

}