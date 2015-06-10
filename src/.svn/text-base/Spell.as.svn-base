package {
   public class Spell {
      public var name:String;
      
      public function Spell(name:String)
      {
         this.name = name;
      }
      
      public function cast(target:Character):Boolean
      {
trace("casting spell " + name + " on " + target.name);
         switch(name.toLowerCase()) {
            case 'millions and millions!':
trace("spell did "+50+" damage");
               target.receiveAttack(50);
            break;
            case 'full heal':
trace("spell fully healed "+target.name);
               target.setHP(target.getMaxHP());
            break;
         }

         return(false);
      }
   }
}