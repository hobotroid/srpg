package com.lasko.entity.map 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	
	import com.lasko.GameGraphics;	
	import com.lasko.Global;
	
	/**
	 * ...
	 * @author Matt Finnegan
	 */
	public class GenericMapObject extends Entity
	{
		protected var spriteIndex:int;
		protected var collisionRect:Rectangle = null;
		
		//debug
		private var showCollisionBox:Boolean = false;
		
		public function GenericMapObject(index:int) 
		{
			super();
	
			this.spriteIndex = index;
			this.setGraphic(index);
		}
		
		public function setGraphic(index:int):void
		{
			this.graphic = GameGraphics.makeImage(index);
		}
		
		override public function update():void
		{
			this.layer = -y;
			
			if (this.collisionRect != null && Global.showCollisionBoxes != this.showCollisionBox) {
				this.showCollisionBox = Global.showCollisionBoxes;
				
				if(this.showCollisionBox) {
					var bmd:BitmapData = new BitmapData(collisionRect.width, collisionRect.height, false, 0xff0000);
					var img:Image = new Image(bmd);
					img.x = collisionRect.x;
					img.y = collisionRect.y;
					this.addGraphic(img);
				}
			}
			
			super.update();
		}
		
		public function performCollision():void {}
		
	}

}