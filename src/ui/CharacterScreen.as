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

   public class CharacterScreen extends Screen {
      private var party:Party;

      public function CharacterScreen(party:Party)
      {
         addBox(10, 10, 410, 440, "characters");
         addBox(390, 30, 200, 215, "menu");

         //characters
         this.party = party;
         for each(var char:Character in party.characters) {
            var charBox:MovieClip = new MovieClip;
            var portrait:XMLList = char.getPortrait();
            if(portrait) { 
               var portraitImage:Bitmap = new Bitmap(new BitmapData(portrait.@width, portrait.@height));
               portraitImage.bitmapData.copyPixels(
                  Global.tileset48, 
                  new Rectangle((portrait.@index % 17) * 48, (int(portrait.@index/17)) * 48, portrait.@width, portrait.@height),
                  new Point(0, 0)
               );
               charBox.addChild(portraitImage);
            } else {
               var rectangle:Shape = new Shape;
               rectangle.graphics.beginFill(0xFF0000);
               rectangle.graphics.drawRect(0, 0, 125,125);
               rectangle.graphics.endFill();
               charBox.addChild(rectangle);
            }
            
            //Stat bars
            var hpBar:UIBar = new UIBar(0xff0000, char.getMaxHP(), 'hp');
            var mpBar:UIBar = new UIBar(0x0000fff, char.getMaxMP(), 'sp');
            hpBar.x = charBox.x + charBox.width + 10;
            hpBar.y = charBox.y;
            hpBar.setValue(char.getHP());
            mpBar.x = charBox.x + charBox.width + 10;
            mpBar.y = hpBar.y + hpBar.height + 2;
            charBox.addChild(hpBar);
            charBox.addChild(mpBar);
            
            addMenuItem("characters", charBox, characterSelected, null, switchBox, "menu");
         }
         
         //menu options
         addMenuText("menu", "EQUIPMENT", switchBox, "characters", exitAction)
         addMenuText("menu", "SCIENCE", switchBox, "characters", exitAction);
         addMenuText("menu", "ITEM", switchBox, "characters", exitAction);
         addMenuText("menu", "EXIT", exitAction);

         switchBox("menu"); 
         
         addEventListener(Event.ADDED, addKeyListener);
         //addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent) { trace('lost it'); stage.focus = this; });
      }

      private function exitAction(params:Object):void
      {
         Global.game.resumeGame();
         Global.game.removeChild(this);
      }
      
      private function characterSelected(c:Character):void
      {
         switch(getSelectedIndex("menu")) {
            case 0:
               var equipmentScreen:EquipmentScreen = new EquipmentScreen(party);
               parent.addChild(equipmentScreen);
               parent.removeChild(this);
               break;
            case 1:
               break;
            case 2:
               break;
            default: break;
         }
      }
   }
}
