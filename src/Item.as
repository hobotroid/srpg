package {
	
	import com.lasko.Global;
	
	public class Item {
		public var name:String;
		public var isCombatUsable:Boolean = false;
		private var icons:Object = { "small": 0, "big": 0 };

		public function Item(name:String) {
			this.name = name;

			switch(name) {
				case "Bomb":
					isCombatUsable = true;
				break;
				case "Fists":
					isCombatUsable = true;
				break;
				case "Spoon":
				break;
				default:break;
			}
		}
      
		public function setIcons(small:int, big:int):void
		{
			icons.small = small;
			icons.big = big;
		}

		public function getIcon(type:String):int
		{
			return(icons[type]);
		}
      
		public function useItem(params:Object=null):Object
		{
			trace("using item: " + name);
			switch(name) {
				case "Bomb": //bomb effects everyone in target's party
					for each(var char:Object in params.target.party) {
						trace("sending 100 damage to " + char.name);
						char.receiveAttack(100);
					}
					return({message:"bomb exploded!"});
				break;
				default:break;
			}

			return( { } );
		}

      public function getAttackFrames():Array
      {
         var frames:Array;
         
         switch(name) {
            case "Fists":
               frames = [
                  
               ];
               break;
            case "Nunchucks":
			   var map:Map = Global.game.getActiveMap();
               frames = [
                  { index: 341, width: 96, height: 96, origin_x: 30, origin_y: 85, offset_x: map.tileWidth/4, offset_y: map.tileHeight/2 },
                  { index: 343, width: 96, height: 96, origin_x: 30, origin_y: 85, offset_x: map.tileWidth/4, offset_y: map.tileHeight/2 },
                  { index: 345, width: 96, height: 96, origin_x: 30, origin_y: 85, offset_x: map.tileWidth/4, offset_y: map.tileHeight/2 }
               ];
               break;
            case "Pistol":
               frames = [
                  { index: 273, width: 48, height: 48, origin_x: 0, origin_y: 0, offset_x: 0, offset_y: 0, hide: true }
               ];
               break;
            default:break;
         }
         
         return(frames);
      }
   }
}