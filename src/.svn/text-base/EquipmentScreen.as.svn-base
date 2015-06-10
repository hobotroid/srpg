package {
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.*;
   import flash.ui.Keyboard;
   
   import ui.Screen;

   public class EquipmentScreen extends Screen
   {
      private var party:Party;
      private var char:Character;
      private var item:Item;
      private var slot:String;

      public function EquipmentScreen(party:Party)
      {
         addBox(10, 10, WIDTH-20, 40, "characters", "horizontal");
         addBox(10, 60, WIDTH-20, 150, "equip", "columns", 2);
         addBox(10, 220, WIDTH-20, 250, "inventory", "columns", 3);
      
         //characters
         this.party = party;
         for each(var char:Character in party.characters) {
            addMenuText("characters", char.name, characterSelected, char, exitAction);
         }

         //items
         for each(var item:Object in party.inventory.getItems()) {
            addMenuText("inventory", item.item.name+(item.quantity>1?" x"+item.quantity:""), itemSelected, item.item, itemExit);
         }
         
         //equipment slots
         var slots:Object = party.characters[0].getSlots();
         for(var slot:String in slots) {
            var mc:MovieClip = new MovieClip();
            var slotText:TextField = Global.makeText(slot+": ");
            var itemText:TextField = Global.makeText(slots[slot]?slots[slot].name:"Nothing", false);
            itemText.textColor = 0x888888;
            itemText.x = slotText.x + slotText.width;
            itemText.name = "itemText";
            mc.addChild(slotText);
            mc.addChild(itemText);
            addMenuItem("equip", mc, slotSelected, null, equipmentExit);
         }

         switchBox("characters");

         addEventListener(Event.ADDED, addKeyListener);
         //addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent) { trace('lost it'); stage.focus = this; });
      }

      private function characterSelected(c:Character):void
      {
trace('selected ' + c.name);
         char = c;
         switchBox("equip");
      }
      
      private function slotSelected(s:String):void
      {
trace('selected slot ' + s);
         slot = s;
         switchBox("inventory");
      }

      private function itemSelected(i:Item):void
      {
         item = i;
         char.setSlot(slot, item);
         getSelectedItem("equip").element.getChildByName("itemText").text = item.name;
         itemExit();
      }
      
      private function equipmentExit(params:Object=null):void
      {
         clearSelection("equip");
         switchBox("characters");
      }
      
      private function itemExit(params:Object=null):void
      {
         clearSelection("inventory");
         switchBox("equip");
      }
      
      private function exitAction(params:Object=null):void
      {
         Global.game.resumeGame();
         Global.game.removeChild(this);
      }
   }
}
