package com.lasko.encounter
{
   import r1.deval.D;
   import com.lasko.entity.Character;
   
   public class CombatCondition
   {
      private var parent:Character;
      
      private var type:String;
      private var value:String;
      private var comparison:String;
      private var actions:Array = [];
      
      public function CombatCondition(conditionXML:XML, parentChar:Character) 
      {
         parent = parentChar;
         for each(var actionXML:XML in conditionXML.children()) {
            actions.push(actionXML);
         }
         
         //parse attributes
         type = conditionXML.@type;
         value = conditionXML.@value;
         comparison = conditionXML.@comparison;
         
         //parse comparison string
         switch(comparison) {
            case 'lte':
               comparison = ' <= '; break;
            case 'gte':
               comparison = ' >= '; break;
            case 'lt':
               comparison = ' < '; break;
            case 'gt':
               comparison = ' > '; break;
            case 'eq':
               comparison = ' == '; break;
            case 'neq':
               comparison = ' != '; break;
            default:break;
         }
      }
      
      public function isActive():Boolean
      {
         var valueNum:int = 0;
         
         switch(type) {
            case 'hp':
               if(value.indexOf('%') > -1) { 
                  valueNum = parseInt(value.replace('%', ''));
                  valueNum = parent.getMaxHP() * valueNum / 100;
               }
               return(D.eval(parent.getHP() + " " + comparison + " " + valueNum) as Boolean);
               break;
            default:break;
         }
         
         return(false);
      }
      
      public function applyActions():void
      {
         for each(var action:XML in actions) {
            switch(String(action.@type)) {
               case 'change_frame':
                  parent.anim.setAnimState(action.@value);
                  break;
               default: break;
            }
         }
      }
   }

}