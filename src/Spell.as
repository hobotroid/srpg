package {

	import com.lasko.entity.Character;

	public class Spell {
		public var name:String;

		public function Spell(name:String)
		{
			this.name = name;
		}
		
		public function getMpCost():int {
			return 10;
		}

		public function cast(target:Character):Boolean
		{
			trace("casting spell " + name + " on " + target.name);
			switch(name.toLowerCase()) {
				case 'millions and millions!':
					trace("spell did "+500+" damage");
				   target.combat.receiveAttack(500);
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