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
         addBox( { x:10, y:10, width:410, height:440, label:"items"});
		 addBox({x:390, y:30, width:100, height:100, label:"type"});

         //menu options
         addMenuText("type", { label:"BUY", callback:switchType, callbackParams:"buy" } );
		addMenuText("type", {label: "SELL", callback:switchType, callbackParams:"sell"});
         addMenuText("type", {label: "EXIT", callback:exitAction});
         
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
