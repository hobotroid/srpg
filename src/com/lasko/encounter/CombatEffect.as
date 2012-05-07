package {
   import flash.display.MovieClip;	
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.utils.Timer;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.geom.Point;

   public class CombatEffect  {
      private var frameBitmap:Bitmap;
      private var frames:Array = new Array();
      private var frameTimer:Timer = new Timer(100, 0);
      private var currentFrame:int = 0;
      private var state:String;
      private var tileSet:BitmapData;
      private var parentClip:MovieClip;
      
      public function CombatEffect(ts:BitmapData, mc:MovieClip, target:Object, type:String) {
         var framesInfo:Array = new Array();
         frameTimer.addEventListener(TimerEvent.TIMER, changeFrameEvent);
         tileSet = ts;
         parentClip = mc;
         
         switch(type) {
            case "fists":
               frameBitmap = new Bitmap(new BitmapData(48, 48));
               framesInfo.push({"num": 51, "label": "pow", "x": target.x + target.width/4 - frameBitmap.width/2, "y": target.y + target.height/4 - frameBitmap.height/2, "w": 48, "h": 48});
               framesInfo.push({"num": 52, "label": "pow", "x": target.x + target.width/4 - frameBitmap.width/2, "y": target.y + target.height/4 - frameBitmap.height/2, "w": 48, "h": 48});
               framesInfo.push({"num": 53, "label": "pow", "x": target.x + target.width/4 - frameBitmap.width/2, "y": target.y + target.height/4 - frameBitmap.height/2, "w": 48, "h": 48});
               framesInfo.push({"num": 51, "label": "pow", "x": target.x + target.width*.75 - frameBitmap.width/2, "y": target.y + target.height*.75 - frameBitmap.height/2, "w": 48, "h": 48});
               framesInfo.push({"num": 52, "label": "pow", "x": target.x + target.width*.75 - frameBitmap.width/2, "y": target.y + target.height*.75 - frameBitmap.height/2, "w": 48, "h": 48});
               framesInfo.push({"num": 53, "label": "pow", "x": target.x + target.width*.75 - frameBitmap.width/2, "y": target.y + target.height*.75 - frameBitmap.height/2, "w": 48, "h": 48});
               state = "pow";
               break;
            case "fire":
               frameBitmap = new Bitmap(new BitmapData(48, 96));
               framesInfo.push({"num": 69, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 70, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 71, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 72, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 73, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 74, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 75, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 76, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 77, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               framesInfo.push({"num": 78, "label": "fire", "x": target.x+target.width/2-frameBitmap.width/2, "y": target.y + target.height - frameBitmap.height, "w": 48, "h": 96});
               state = "fire";
               break;
            default:
               break;
         }
         
         //create the frame bitmaps based on above 
         for each (var frameInfo:Array in framesInfo) {
            if (!frames[frameInfo.label]) {
               frames[frameInfo.label] = [{"num": frameInfo.num, "x": frameInfo.x, "y": frameInfo.y, "w": frameInfo.w, "h": frameInfo.h}];
            } else {
               frames[frameInfo.label].push({"num": frameInfo.num, "x": frameInfo.x, "y": frameInfo.y, "w": frameInfo.w, "h": frameInfo.h});
            }
         }
         
         frameBitmap.visible = false;
         mc.addChild(frameBitmap);
         frameTimer.start();
      }
      
      private function changeFrameEvent(e:TimerEvent):void {
         if (currentFrame < frames[state].length-1) {
            currentFrame++;
         } else {
            frameTimer.stop();
            parentClip.removeChild(frameBitmap);
            return;
         }
         
         drawCurrentFrame();
      }
      
      private function drawCurrentFrame():void {
         var spriteNum:int = frames[state][currentFrame].num;
         
         frameBitmap.x = frames[state][currentFrame].x;
         frameBitmap.y = frames[state][currentFrame].y;
         frameBitmap.bitmapData.copyPixels(
            tileSet, 
            new Rectangle((spriteNum % 17) * 48, (int(spriteNum/17)) * 48, frames[state][currentFrame].w, frames[state][currentFrame].h),
            new Point(0, 0)
         );
         frameBitmap.visible = true;
      }
   }
}
