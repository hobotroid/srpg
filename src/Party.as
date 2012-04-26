package {

	import com.lasko.entity.Character;
	
   public class Party {
      public var characters:Array = new Array();
      public var leader:Character;
      public var name:String;
      public var id:int;
      private static var staticId:int = 0;

      public var inventory:Inventory;
      private var money:int = 0;
      
      public function Party(name:String, chars:Array=null)
      {
         this.name = name;
         this.id = Party.staticId++;
         this.inventory = new Inventory(this);
         if(chars) {
            characters = chars;
            leader = characters[0];
         }
      }
      
      public function addCharacter(char:Character):void
      {
         characters.push(char);
         if(characters.length == 1) { leader = characters[0]; }
         char.setParty(this);
      }

      public function getInventory():Inventory
      {
         //test inventory
         for(var i:int=0; i<50; i++) { 
            inventory.addItem(new Item('test item '+i));
         }

         return(inventory);
      }

      public function addMoney(value:int):void
      {
trace('adding $' + value + ' to party '+name);
         money += value;
      }
      
      public function removeMoney(value:int):void
      {
trace('removing $' + value + ' from party '+name);
         money -= value;
      }
      
      public function getMoney():int
      {
         return(money);
      }
      
      public function getFirstMember():Character
      {
         return(characters[0]);
      }
   }
}