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
         addBox({x:10, y:10, width:WIDTH-20, height:40, label:"characters", layout:"horizontal"});
         addBox({x:10, y:60, width:WIDTH-20, height:150, label:"equip", layout:"columns", columns:2});
         addBox({x:10, y:220, width:WIDTH-20, height:250, label:"inventory", layout:"columns", columns:3});
      
         //characters
         this.party = party;
         for each(var char:Character in party.characters) {
            addMenuText("characters", {label:char.name, callback:characterSelected, callbackParams:char, exitCallback:exitAction});
         }

         //items
         for each(var item:Object in party.inventory.getItems()) {
            addMenuText("inventory", {label:item.item.name+(item.quantity>1?" x"+item.quantity:""), callback:itemSelected, callbackParams:item.item, exitCallback:itemExit});
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
            addMenuItem("equip", mc, {callback: slotSelected, exitCallback: equipmentExit});
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
