package com.lasko.encounter 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.lasko.entity.Character;
	
	public class EncounterEntity 
	{
		public static const STATE_WAITING:String = "waiting";
		public static const STATE_DEAD:String = "dead";
		public static const TYPE_GOOD:String = "good";
		public static const TYPE_BAD:String = "bad";
		
		public static var typeCounts:Object = { };

		private var state:String;
		private var character:Character;
		private var action:CombatActionBase;
		
		private var bitmap:Bitmap;
		private var sprite:Sprite;
		private var index:int;
		
		private var originalPosition:Point;
		
		public function EncounterEntity(character:Character, type:String) 
		{
			character.anim.setAnimState(Global.STATE_COMBAT);
			character.setState(Global.STATE_COMBAT);
			this.character = character;
			this.bitmap = new Bitmap(new BitmapData(character.width, character.height));
			this.sprite = new Sprite();
			this.state = STATE_WAITING;
			
			if (!EncounterEntity.typeCounts[type]) { EncounterEntity.typeCounts[type] = 0; }
			this.index = EncounterEntity.typeCounts[type]++;
			
			this.update();
			//index = count;
		}
		
		public function update():void
		{
			if (this.state == STATE_DEAD) { return; }

			var currentFrame:int = character.anim.getCurrentFrame();
			bitmap.bitmapData.copyPixels(
				Global.tileset48, 
				new Rectangle((currentFrame % 17) * 48, (int(currentFrame/17)) * 48, bitmap.width, bitmap.height),
				new Point(0, 0)
			);
			if (!sprite.contains(bitmap)) { sprite.addChild(bitmap); }
		}
		
		public function setPosition(x:int, y:int):void {
			if (!this.originalPosition) { 
				this.originalPosition = new Point();
				this.originalPosition.x = x;
				this.originalPosition.y = y;
			}
			
			this.sprite.x = x;
			this.sprite.y = y;
		}
		
		public function setAction(action:CombatActionBase):void {
			this.action = action;
		}
		
		public function clearAction():void {
			this.action = null;
		}
		
		public function getAction():CombatActionBase {
			return action;
		}
		
		public function setScale(xs:Number, ys:Number):void {
			this.sprite.scaleX = xs;
			this.sprite.scaleY = ys;
		}
		
		public function getState():String {
			return this.state;
		}
		
		public function getIndex():int {
			return this.index;
		}
		
		public function getCharacter():Character {
			return this.character;
		}
		
		public function getBitmap():Bitmap {
			return this.bitmap;
		}
		
		public function getSprite():Sprite {
			return this.sprite;
		}
		
	}

}