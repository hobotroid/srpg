package ui {
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.*;
   import flash.geom.Rectangle;
   import flash.geom.Point;

   public class ShopScreen extends Screen {
      private var party:Party;

      public function ShopScreen(items:Array):void
      {
         addBox(10, 10, 410, 440, "items");
         addBox(390, 30, 100, 100, "type");

         //menu options
         addMenuText("type", "BUY", switchType, "buy")
         addMenuText("type", "SELL", switchType, "sell");
         addMenuText("type", "EXIT", exitAction);
         
         //items
         for each(var item:Item in items) {
            var mc:MovieClip = new MovieClip();
            var tf:TextField = Global.makeText(item.name.toUpperCase());
            var icon:Bitmap = Global.makeSprite(item.getIcon("small"));
            tf.x = icon.x + icon.width;
            tf.y = icon.y + icon.height / 2 - tf.height / 2;
            mc.addChild(tf);
            mc.addChild(icon);
            addMenuItem("items", mc, null);
         }

         switchBox("type"); 
         
         addEventListener(Event.ADDED, addKeyListener);
      }
      
      private function switchType(type:String):void
      {
         if (type == "buy") {
            switchBox("items");
         }
      }

      private function exitAction(params:Object):void
      {
         Global.game.resumeGame();
         Global.game.removeChild(this);
      }
   }
}
