package com.lasko.encounter 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
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
		private var animation:CombatAnimation;
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
	
		public function showCombatAnimation(callback:Function):void
		{
			showCombatAttack(function():void {
				for each(var targetEntity:EncounterEntity in action.getTargets()) { 
					targetEntity.showCombatHit(callback);
				}
			});
		}

		private function showSpellAnimation(character:Object, callback:Function):void
		{
			showSpellCast(character, function():void { 
				TweenMax.to(character.sprite, .5, { x:this.originalPosition.x, ease:Expo.easeInOut }); //move char back to original pos
				callback();
			});
		}
      
		//shows "pow" graphic on character that got hit by melee
		public function showCombatHit(callback:Function):void
		{
			TweenMax.to(bitmap,0.1,{repeat:2, y:1+Math.random()*4, x:1+Math.random()*4, delay:0.1, ease:Expo.easeInOut});
			TweenMax.to(bitmap, 0.1, { y:Math.random() * 4, x:Math.random() * 4, delay:0.3,/* onComplete:onFinishTween,*/ ease:Expo.easeInOut } );

			var hitBitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
			hitBitmap.bitmapData.copyPixels(
				Global.tileset48, 
				new Rectangle((340 % 17) * 48, (int(340/17)) * 48, bitmap.width, bitmap.height),
				new Point(0, 0)
			);
			hitBitmap.x = sprite.width / 2 - 48 / 2;
			hitBitmap.y = sprite.height / 2 - 48 / 2;
			sprite.addChild(hitBitmap);
			hitBitmap.name = "hitBitmap";

			var hitTimer:Timer = new MyTimer(300, 1);
			hitTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
				sprite.removeChild(sprite.getChildByName("hitBitmap"));
			});
			hitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				TweenMax.to(sprite, .5, { x:originalPosition.x, ease:Expo.easeInOut, onComplete: callback, onCompleteParams: []}); 
			});
			hitTimer.start();
		}
      
		//swings a weapon behind a character (or do whatever frames the weapon specifies)
		private function showCombatAttack(callback:Function):void
		{
			var weapon:Item = CombatActionWeapon(this.action).getWeapon(); 
			this.animation = new CombatAnimation(weapon.getAttackFrames());
			this.state = "attacking";

			TweenMax.to(sprite, .5, { 
				x:sprite.x - 50, ease:Expo.easeInOut, onComplete: function():void {
					var attackAnimTimer:MyTimer = new MyTimer(100, animation.getFrameCount()+1);
					attackAnimTimer.addEventListener(TimerEvent.TIMER, attackTimerFired);
					attackAnimTimer.addEventListener(TimerEvent.TIMER_COMPLETE, callback);
					attackAnimTimer.start();
				}
			});
		}
      
		//character casts a spell
		private function showSpellCast(character:Object, callback:Function):void
		{
			character.state = "casting";

			TweenMax.to(sprite, .5, { 
				x:sprite.x - 50, ease:Expo.easeInOut, onComplete: function():void {
					callback();
				}
			});
		}
      
      //called when weapon swing animation is updated
      private function attackTimerFired(e:Event):void
      {
         var frame:Object = animation.getFrameAt(e.target.currentCount - 1);
         
         if(frame) {
            var hitBitmap:Bitmap = sprite.getChildByName("hitBitmap") ? sprite.getChildByName("hitBitmap") as Bitmap: new Bitmap(new BitmapData(frame.width, frame.height));
            hitBitmap.name = "hitBitmap";
            hitBitmap.bitmapData.copyPixels(
               Global.tileset48, 
               new Rectangle((frame.index % 17) * 48, (int(frame.index/17)) * 48, frame.width, frame.height),
               new Point(0, 0)
            );
            hitBitmap.x = -frame.origin_x + frame.offset_x;
            hitBitmap.y = -frame.origin_y + frame.offset_y;
            if (!sprite.contains(hitBitmap)) { sprite.addChildAt(hitBitmap, 0); }
            if (frame.hide) { sprite.getChildAt(1).visible = false; }
         } else { //animation done
            sprite.getChildAt(1).visible = true;
            sprite.removeChild(sprite.getChildByName("hitBitmap"));
         }
      }
      
      private function doEnemyDeathAnimation(index:int):void
      {
		 Encounter.debugOut('doing enemy death for enemy ' + index);
         var bmd:BitmapData = bitmap.bitmapData;
         
         var pass1:Bitmap = new Bitmap(new BitmapData(bmd.width, bmd.height, true, 0x00000000));
         var pass2:Bitmap = new Bitmap(new BitmapData(bmd.width, bmd.height, true, 0x00000000));
			
         var mask:Sprite = new Sprite();
         
         //clear sprite
         sprite.removeChild(bitmap);
         
         //mask for clipping
         mask.graphics.beginFill(0, 1);  
         mask.graphics.drawRect(0, 0, bitmap.width, bitmap.height);  
         mask.graphics.endFill();  
         
         for (var i:int = 0; i < bmd.height; i++) {
            if (i % 2) {
               pass1.bitmapData.copyPixels(bmd, new Rectangle(0, i, bmd.width, 1), new Point(0, i));
            } else {
               pass2.bitmapData.copyPixels(bmd, new Rectangle(0, i, bmd.width, 1), new Point(0, i), null, null, true);
            }
         }
         
         sprite.addChild(mask);
         sprite.addChild(pass1);
         sprite.addChild(pass2);
         pass1.mask = mask;
         pass2.mask = mask;
         
         TweenMax.to(pass1, 8, { x: -bitmap.width });
         TweenMax.to(pass2, 8, { x: bitmap.width });
         TweenMax.to(pass1, 1, { alpha: 0 } );
         TweenMax.to(pass2, 1, { alpha: 0 } );
         
         //Ghost!
         var ghostTimer:MyTimer;
         var ghost:Sprite = new Sprite();
         var ghostFrames:Array = [];
         var ghostFrame:int = 0;
         ghostFrames[0] = new Bitmap(new BitmapData(48, 48 * 2, true));
         ghostFrames[1] = new Bitmap(new BitmapData(48, 48 * 2, true));
         ghostFrames[2] = new Bitmap(new BitmapData(48, 48*2, true));
         ghostFrames[0].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((330 % 17) * 48, (int(330/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[1].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((331 % 17) * 48, (int(331/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[2].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((332 % 17) * 48, (int(332/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[0].visible = true;
         ghostFrames[1].visible = false;
         ghostFrames[2].visible = false;
         ghost.addChild(ghostFrames[0]);
         ghost.addChild(ghostFrames[1]);
         ghost.addChild(ghostFrames[2]);
         ghost.x = sprite.parent.x + sprite.x + sprite.width / 2 - ghost.width / 2;
         ghost.y = sprite.parent.y + sprite.y + sprite.height / 2 - ghost.height / 2;
         //ghost.alpha = 0;
         sprite.parent.addChild(ghost);
         
         //ease:Back.easeOut, 
         //TweenMax.to(ghost, .3, { alpha: 1, onComplete:function():void {
         ghostTimer = new MyTimer(100, 20, {'ghostFrames':ghostFrames, 'frame':ghostFrame} );
         ghostTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
            e.target.params.ghostFrames[e.target.params.frame].visible = false;
            if (++e.target.params.frame > ghostFrames.length - 1) { e.target.params.frame = 0; }
            e.target.params.ghostFrames[e.target.params.frame].visible = true;
         });
         ghostTimer.start();
         //TweenMax.to(ghost, 1, { alpha: 1 } );
         TweenMax.to(ghost, 4, { y: -ghost.height } );
         TweenMax.to(ghost, 1, { delay: .5, alpha: 0 } );
         //}});
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