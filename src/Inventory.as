package  
{
	import com.lasko.entity.Party;
	
   public class Inventory
   {
      private var items:Object = new Object();
      private var party:Party;
      private var count:int = 0;
      
      public function Inventory(party:Party) 
      {
         this.party = party;
      }
      
      public function addItem(item:Item, quantity:int=1):void
      {
trace('adding item ' + quantity + 'x' + item.name + ' to party ' + party.name);
         if(!items[item.name]) {
            items[item.name] = { "quantity": quantity, "item":item };
            count++;
         } else {
            items[item.name].quantity++;
         }
      }
      
      public function getItems():Object
      {
         return(items);
      }
      
      public function getCombatItems():Object
      {
         return(items);
      }
      
      public function hasCombatItem():Boolean {
         for each(var item:Object in items) {
            if(item.isCombatUsable)  { return(true); }
         }
         
         return(false);
      }
   }

}