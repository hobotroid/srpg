package
{
    import com.greensock.motionPaths.RectanglePath2D;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
    
    import util.Utils;
	
	public class Character
	{
		private var parentMap:Map;
		public var parentParty:Party;
		
		public var x:int, y:int;
        public var mapX:int, mapY:int;
		public var width:int;
		public var height:int;
		public var rect:Rectangle;
		public var head_cutoff_y:int = 0;
		
		private var frames:Array = new Array();
		private var currentFrame:int = 0;
        private var frameDelayCount:int = 0;
		private var state:Object = {"type": Global.STATE_DOWNSTILL};
		public var animState:int;
		//private var frameTimer:Timer = new Timer(100, 0);
		private var pathNodeTimer:Timer;
		private var canAcceptInput:Boolean = true;
		
		private var speed:int = 5;
		public var id:String;
		public var name:String;
		public var type:String;
		private var xp:int, hp:int, mp:int, str:int, dex:int, intl:int, level:int;
		private var maxHp:int, maxMp:int;
		public var collisionRectIndex:int;
		private var checkCollisions:Boolean = false;
        private var charCollisionRect:Rectangle;
		public var collidingWith:Object;
		
		public var conditions:Array = new Array();
		private var spells:Array = new Array();
		private var weapons:Array = new Array();
		public var inventory:Inventory;
		private var slots:Object = {"L. Hand": null, "R. Hand": null, "Arms": null, "Torso": null, "Legs": null, "Head": null, "Neck": null};
		
		public var inCombat:Boolean = false;
		public var isDosile:Boolean = false;
		private var dosileTimer:Timer;
		public var chaseRange:int = 0;
		
		//for pre-set path - set in map
		private var pathNodes:Array = new Array();
		private var currentPathNode:int = -1;
		
		private var dialog:XML;
		private var portrait:XMLList;
		
		//for joshua - what items is he selling?
		private var shopItems:Array = new Array();
		
		//for wandering logic
		private var wanderParams:Object = {radius: 5, start_x: 0, start_y: 0, x: 0, y: 0, states: {}, statesSum: 0};
		
		//for blinking and other alternate frames
		private var replaceTimer:int = 0;
		
		public function Character(parentMap:Map, dataXML:XMLList, x:int, y:int)
		{
			var framesInfo:Array = new Array();
			this.parentMap = parentMap;
			this.x = x;
			this.y = y;
            //this.mapX = parentMap.tileWidth / this.x;
            //this.mapY = parentMap.tileHeight / this.y;
            this.mapX = (x + this.width * .1) / parentMap.tileWidth;
            this.mapY = y / parentMap.tileHeight;
			this.inventory = new Inventory(this.parentParty);
			//frameTimer.addEventListener(TimerEvent.TIMER, changeFrameEvent);
			
			//character type
			type = dataXML.type.text();
			
			//frames
			var enumMap:Object = { 
				'leftwalk': Global.STATE_LEFTWALK, 'rightwalk': Global.STATE_RIGHTWALK, 'upwalk': Global.STATE_UPWALK, 
				'downwalk': Global.STATE_DOWNWALK, 'leftstill': Global.STATE_LEFTSTILL, 'rightstill': Global.STATE_RIGHTSTILL, 
				'upstill': Global.STATE_UPSTILL, 'downstill': Global.STATE_DOWNSTILL , 'combat' : Global.STATE_COMBAT, 
				'dead': Global.STATE_DEAD, 'standard': Global.STATE_STANDARD, 'leftblink': Global.STATE_LEFTBLINK, 
				'rightblink': Global.STATE_RIGHTBLINK, 'downblink': Global.STATE_DOWNBLINK, 'invulnerable': Global.STATE_INVULNERABLE};
			for each (var frameXML:XML in dataXML.frames.children())
			{
				var label:String = String(frameXML.@label.toXMLString());
				if (enumMap[label]) { label = enumMap[label]; }
				framesInfo.push({"num": frameXML.@index.toXMLString(), "label": Number(label), "default": frameXML.@default.toXMLString(), "speed": frameXML.@speed.toXMLString()});
				
				if (frameXML.@replace.length())
				{
					for (var i:int = 0; i < framesInfo.length; i++)
					{
						if (framesInfo[i].label == frameXML.@replace.toXMLString())
						{
							framesInfo[i].alternate = Number(label);
						}
					}
				}
			}
			
			//stats
			hp = maxHp = dataXML.hp.text();
			mp = maxMp = dataXML.mp.text();
			dex = dataXML.dex.text();
			str = dataXML.str.text();
			name = dataXML.full_name.text();
			id = dataXML.@id;
			level = dataXML.level.text();
			speed = dataXML.speed.text();
			xp = 0;
			
			//spells
			for each (var spellsXML:XML in dataXML.spells.children())
			{
				spells.push(new Spell(spellsXML.@name.toXMLString()));
			}
			
			//dialog?
			if (dataXML.dialog.children().length())
			{
				dialog = XML(dataXML.dialog);
			}
			
			//portrait?
			if (int(dataXML.portrait.@index))
			{
				portrait = dataXML.portrait;
			}
            
            //collision rect from characters.xml
            if (dataXML.collision.children().length()) {
                charCollisionRect = new Rectangle(dataXML.collision.x, dataXML.collision.y, dataXML.collision.width, dataXML.collision.height);
            }
			
			//combat conditions
			for each (var conditionXML:XML in dataXML.conditions.children())
			{
				conditions.push(new Condition(conditionXML, this));
			}
			
			//create the frame array
			for each (var frameInfo:Object in framesInfo)
			{
				if (!frames[frameInfo.label])
				{
					frames[frameInfo.label] = [];
				}
				frames[frameInfo.label].push({"num": frameInfo.num, "default": frameInfo.default, "speed": frameInfo.speed, "alternate": frameInfo.alternate});
			}
			
			//set initial frame
			animState = frames[Global.STATE_DOWNSTILL] ? Global.STATE_DOWNSTILL : Global.STATE_STANDARD;
			
			//dimensions
			width = dataXML.width.length() ? dataXML.width.text() : parentMap.tileWidth;
			height = dataXML.height.length() ? dataXML.height.text() : parentMap.tileHeight;
			rect = new Rectangle(x, y, width, height);
			head_cutoff_y = dataXML.head_y.length() ? dataXML.head_y.text() : 24;
			
			//misc
			if (id == "carl" || id == "phillip lasko" || id == "townsman")
			{
				checkCollisions = true;
			} //only check collisions for carl
		}
		
		public function setParty(party:Party):void
		{
			this.parentParty = party;
		}
		
		public function setMap(map:Map):void
		{
			parentMap = map;
		}
		
		public function moveUp():void
		{
			if (!canAcceptInput) { return; }
			canAcceptInput = false;
			if (state.type == Global.STATE_LEFTWALK || state.type == Global.STATE_RIGHTWALK) { return; }
			if (!canMove(Global.DIRECTION_UP)) { canAcceptInput = true; return; }
			setState(Global.STATE_UPWALK, {target: mapY - 1 });
		}
		
		public function moveDown():void
		{
			if (!canAcceptInput) { return; }
			canAcceptInput = false;
			if (state.type == Global.STATE_LEFTWALK || state.type == Global.STATE_RIGHTWALK) { return; }
			if (!canMove(Global.DIRECTION_DOWN)) { canAcceptInput = true;  trace('COLLIDED DOWN'); return; }
            setState(Global.STATE_DOWNWALK, { target: this.mapY + 1 } );
		}
		
		public function moveLeft():void
		{
			if (!canAcceptInput) { return; }
			canAcceptInput = false;
			if (state.type == Global.STATE_DOWNWALK || state.type == Global.STATE_UPWALK) { return; }
			if (!canMove(Global.DIRECTION_LEFT)) { canAcceptInput = true; return; }
			setState(Global.STATE_LEFTWALK, {target: mapX - 1 });
		}
		
		public function moveRight():void
		{
			if (!canAcceptInput) { return; }
			canAcceptInput = false;
			if (state.type == Global.STATE_DOWNWALK || state.type == Global.STATE_UPWALK) { return; }
			if (!canMove(Global.DIRECTION_RIGHT)) { canAcceptInput = true; return; }
			setState(Global.STATE_RIGHTWALK, { target: mapX + 1 });
		}
		
		public function moveStop():void
		{
			if (state.type == Global.STATE_RIGHTWALK || state.type == Global.STATE_LEFTWALK || state.type == Global.STATE_UPWALK || state.type == Global.STATE_DOWNWALK) {
				setState(this.state.type, { target: this.state.target, stop: true, force: true } );
			}
		}
		
		private function canMove(direction:int):Boolean {
			switch(direction) {
				case Global.DIRECTION_DOWN:
					return !checkCollision(x, y + parentMap.tileHeight, direction);
				break;
				case Global.DIRECTION_UP:
					return !checkCollision(x, y - parentMap.tileHeight, direction);
				break;
				case Global.DIRECTION_LEFT:
					return !checkCollision(x - parentMap.tileWidth, y, direction);
				break;
				case Global.DIRECTION_RIGHT:
					return !checkCollision(x + parentMap.tileWidth, y, direction);
				break;
				default: break;
			}
			return true;
		}
		
		private function checkCollision(newx:int, newy:int, dir:int):Boolean
		{
			if (!checkCollisions)
			{
				return (false);
			} //only check collisions for carl
			
			var mapX:int = newx / parentMap.tileWidth;
			var mapY:int = newy / parentMap.tileHeight;
			var x:int, y:int, l:int;
			//var tileX:int, tileY:int;
			var tile:Object;
			
			var charRect:Rectangle = new Rectangle(newx + charCollisionRect.x, newy + charCollisionRect.y, charCollisionRect.width, charCollisionRect.height); //only carl's feet
			var collisionRect:Object
			
			collidingWith = null;
			
			//loop through collision rects, find tiles associated with them and perform collision
			for (var i:int = 0; i < parentMap.collisionMap.length; i++)
			{
				collisionRect = parentMap.collisionMap[i];
				
				if (collisionRect && collisionRect.intersects(charRect))
				{
					if (parentMap.collisionMapIndexes[i])
					{
						if (performCollision(parentMap.collisionMapIndexes[i], dir))
						{
							return (true);
						}
					}
					else
					{
						return (true);
					}
				}
			}
			
			//if character is colliding with something, figure out what they're colliding with
			/*for each(collisionRect in parentMap.collisionMap) {
			   if (collisionRect && collisionRect.intersects(charRect)) {
			
			   for(l=0; l<parentMap.tiles.length; l++) {
			   for(x = mapX - 2; x < mapX + 2; x++) {
			   for (y = mapY - 2; y < mapY + 2; y++) {
			   tile = parentMap.getTileAt(l, x, y);
			   if(tile && tile.type == Global.TILE_TYPE_PORTAL) {
			   parentMap.collisionMapColliding.push(collisionRect);
			   trace(tile);
			   //trace(collisionRect);
			   //trace(parentMap.collisionMap[tile.collideIndex]);
			   trace(collisionRect);
			   trace(parentMap.collisionMap[tile.collideIndex]);
			   }
			   if (tile && tile.collisionType && collisionRect == parentMap.collisionMap[tile.collideIndex]) {
			   if(performCollision(tile, dir)) { return(true); }
			   }
			   }
			   }
			   }
			
			
			
			   return(true);
			   } else {
			   parentMap.collisionMapColliding.splice(parentMap.collisionMapColliding.indexOf(collisionRect), 1);
			   }
			
			 }*/
			
			return false;
		}
		
		private function performCollision(tile:Object, direction:int):Boolean
		{
			switch (tile.collisionType)
			{
				case Global.COLLISION_TYPE_NORMAL: //regular collidable tile/object
					collidingWith = tile;
					return (true);
				case Global.COLLISION_TYPE_PORTAL: //portal
					if (parentMap.getTilesAbove(tile).length == 0)
					{
						Global.game.changeMap(tile.params.destination);
						return (true);
					}
					break;
				case Global.COLLISION_TYPE_MOVABLE: //movable object
					var destX:int, destY:int;
					switch (direction)
				{
					case Global.DIRECTION_UP : //up
						destX = tile.x;
						destY = tile.y - parentMap.tileHeight;
						break;
					case Global.DIRECTION_DOWN: //down
						destX = tile.x;
						destY = tile.y + parentMap.tileHeight;
						break;
					case Global.DIRECTION_LEFT: //left
						destX = tile.x - parentMap.tileWidth;
						destY = tile.y;
						break;
					case Global.DIRECTION_RIGHT: //right
						destX = tile.x + parentMap.tileWidth;
						destY = tile.y;
						break;
					default: 
						break;
				}
					
					if (!parentMap.isCollidableAt(destX, destY))
					{
						tile.startMove(destX, destY);
					}
					return (true);
				case Global.COLLISION_TYPE_AIRSHIP: //airship!
					collidingWith = tile;
					//Global.game.startMode7();
					return (true);
				
				case Global.COLLISION_TYPE_NPC: 
					collidingWith = tile;
					return (true);
				
				default: 
					break;
			}
			
			return (false);
		}
		
		public function addShopItems(itemsString:String):void
		{
			for each (var itemId:String in itemsString.split(","))
			{
				var itemXML:XML = XML(Global.itemsXML.item.(@id == itemId));
				var item:Item = new Item(itemXML.@name);
				item.setIcons(itemXML.icons.small, itemXML.icons.big);
				
				shopItems.push(item);
			}
		}
		
		public function getShopItems():Array
		{
			return (shopItems);
		}
		
		public function setState(type:int, params:Object = null):void
		{
			if (params && !params.force && 
				(type == Global.STATE_LEFTWALK && state.type == Global.STATE_LEFTWALK || type == Global.STATE_RIGHTWALK && state.type == Global.STATE_RIGHTWALK || 
				type == Global.STATE_UPWALK && state.type == Global.STATE_UPWALK || type == Global.STATE_DOWNWALK && state.type == Global.STATE_DOWNWALK)) { return; }
			//not sure if this should set the state only if it's already that state or not
            //if(this.state.type != type) { 
                var obj:Object = {"type": type};
                for (var param:Object in params)
                {
					obj[param] = params[param];
                }
                this.state = obj;
                setAnimState(type);
            //}
		}
		
		public function getState():Object
		{
			return (state);
		}
		
		public function getStateName():String
		{
			return (state.type);
		}
		
		public function getCurrentFrame():int
		{
			if (frames[animState][currentFrame].alternate)
			{
				if (this.replaceTimer++)
				{
					if (this.replaceTimer < frames[frames[animState][currentFrame].alternate][0].speed)
					{
						return (frames[frames[animState][currentFrame].alternate][0].num);
					}
					else
					{
						this.replaceTimer = 0;
					}
				}
				else if (Utils.randRange(1, 30) == 30)
				{
					trace('returning ' + frames[frames[animState][currentFrame].alternate][0].num);
					return (frames[frames[animState][currentFrame].alternate][0].num);
				}
			}
			
			return (frames[animState][currentFrame].num);
		}
		
		public function setAnimState(animState:int):void
		{
			if (!frames[animState])
			{
				animState = frames[Global.STATE_DOWNSTILL] ? Global.STATE_DOWNSTILL : Global.STATE_STANDARD;
			}
			if (this.animState != animState)
			{
				this.animState = animState;
				currentFrame = 0;
				/*if (frames[animState].length > 1)
				{
					frameTimer.start();
				}
				else
                
				{
					frameTimer.stop();
				}*/
				
				switch (animState)
				{
					case "downstill":
						
						break;
					case "downwalk1":
						
						break;
					case "downwalk2":
						
						break;
					default: 
						break;
				}
			}
		}
		
		public function setDefaultState():void
		{
			this.animState = frames[animState][currentFrame].default;
			if (frames[animState].length > 1)
			{
				//frameTimer.start();
			}
			else
			{
				//frameTimer.stop();
			}
		}
		
		private function changeFrameEvent(e:TimerEvent=null):void
		{
			if (currentFrame < frames[animState].length - 1)
			{
				currentFrame++;
			}
			else
			{
				currentFrame = 0;
			}
		}
		
        public function tick():void
        {
            if (state.type) {
                switch(Number(state.type)) {
                    case Global.STATE_UPWALK:
						
						//update y coordinate
						y -= speed;
						if (y <= state.target * parentMap.tileHeight) { 
							changeFrameEvent();
							if (this.state.stop) { 
								setState(Global.STATE_UPSTILL);
								canAcceptInput = true;
							} else { 
								setState(Global.STATE_UPWALK, { target: state.target - 1, force:true } );
							}
						}
						
						//collision rectangle
						if (collisionRectIndex) {
                            parentMap.collisionMap[collisionRectIndex].y -= speed;
                        }
						
                    break;
                    case Global.STATE_DOWNWALK:
                    
						//update y coordinate
						y += speed;
						if (y >= state.target * parentMap.tileHeight) { 
							changeFrameEvent();
							if (this.state.stop) { 
								setState(Global.STATE_DOWNSTILL);
								canAcceptInput = true;
							} else { 
								setState(Global.STATE_DOWNWALK, { target: state.target + 1, force:true } );
							}
						}
						
						//collision rectangle
						if (collisionRectIndex) {
                            parentMap.collisionMap[collisionRectIndex].y += speed;
                        }
						
                    break;                    
                    case Global.STATE_LEFTWALK:

						//update x coordinate
						x -= speed;
						if (x <= state.target * parentMap.tileWidth) { 
							changeFrameEvent();
							if (this.state.stop) { 
								setState(Global.STATE_LEFTSTILL);
								canAcceptInput = true;
							} else { 
								setState(Global.STATE_LEFTWALK, { target: state.target - 1, force:true } );
							}
						}
						
						//collision rectangle
						if (collisionRectIndex) {
                            parentMap.collisionMap[collisionRectIndex].x -= speed;
                        }
						
                    break;
					case Global.STATE_RIGHTWALK:

						//update x coordinate
						x += speed;
						if (x >= state.target * parentMap.tileWidth) { 
							changeFrameEvent();
							if (this.state.stop) { 
								setState(Global.STATE_RIGHTSTILL);
								canAcceptInput = true;
							} else { 
								setState(Global.STATE_RIGHTWALK, { target: state.target + 1, force:true } );
							}
						}
						
						//collision rectangle
						if (collisionRectIndex) {
                            parentMap.collisionMap[collisionRectIndex].x += speed;
                        }

                    break;
                }
				
				//update map coordinates
				mapX = x / parentMap.tileWidth;
				mapY = y / parentMap.tileHeight;
				
				//update character rectangle
				rect.x = x;
				rect.y = y;
				
            }
        }
        
		public function updateFrame():void
		{
		
		}
		
		public function updatePosition():void
		{
			if (pathNodes.length && !pathNodeTimer)
			{
				//not currently in path -- go to first node
				if (currentPathNode == -1)
				{
					currentPathNode = 0;
				}
				
				var node:Object = pathNodes[currentPathNode];
				if (x > node.x)
				{ //right of
					moveLeft();
					if (x < node.x)
					{
						x = node.x;
					}
				}
				else if (x < node.x)
				{ //left of
					moveRight();
					if (x > node.x)
					{
						x = node.x;
					}
				}
				if (y > node.y)
				{ //below
					moveUp();
					if (y < node.y)
					{
						y = node.y;
					}
				}
				else if (y < node.y)
				{ //above
					moveDown();
					if (y > node.y)
					{
						y = node.y;
					}
				}
				
				if (x == node.x && y == node.y)
				{
					if (currentPathNode++ >= pathNodes.length - 1)
					{
						currentPathNode = 0;
					}
					
					//if node has delay, set up timer
					if (node.delay)
					{
						setDefaultState();
						pathNodeTimer = new Timer(node.delay, 1);
						pathNodeTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
							{
								pathNodeTimer.stop();
								pathNodeTimer = null;
							});
						pathNodeTimer.start();
					}
				}
			}
			else if (state.type == 'following')
			{
				switch (state.target.animState)
				{
					case "rightwalk": 
						if (x < state.target.x - width)
						{
							moveRight();
						}
						if (y < state.target.y)
						{
							moveDown();
						}
						else if (y > state.target.y)
						{
							moveUp();
						}
						break;
					case "leftwalk": 
						if (x > state.target.x + state.target.width)
						{
							moveLeft();
						}
						if (y < state.target.y)
						{
							moveDown();
						}
						else if (y > state.target.y)
						{
							moveUp();
						}
						break;
					case "downwalk": 
						if (y < state.target.y - height)
						{
							moveDown();
						}
						if (x < state.target.x)
						{
							moveRight();
						}
						else if (x > state.target.x)
						{
							moveLeft();
						}
						break;
					case "upwalk": 
						if (y > state.target.y + height)
						{
							moveUp();
						}
						if (x < state.target.x)
						{
							moveRight();
						}
						else if (x > state.target.x)
						{
							moveLeft();
						}
						break;
					default: 
						setDefaultState();
						break;
				}
			}
			else if (state.type == 'wandering')
			{
				if (Utils.randRange(0, 75) == 1)
				{
					var rand:int = Utils.randRange(0, wanderParams.statesSum);
					var sum:int = 0;
					for (var s:String in wanderParams.states)
					{
						sum += wanderParams.states[s];
						if (sum >= rand)
						{
							trace('setting to ' + s);
							setAnimState(Number(s));
							break;
						}
					}
					
				}
				
				switch (animState)
				{
					case "rightwalk": 
						moveRight();
						break;
					case "leftwalk": 
						moveLeft();
						break;
					case Global.STATE_DOWNWALK: 
						moveDown();
						break;
					case "upwalk": 
						moveUp();
						break;
					case 'downblink': 
					case 'leftblink': 
					case 'rightblink':
						
						break;
					default: 
						//setDefaultState();
						break;
				}
			}
		}
		
		public function setMovementType(type:String, params:Object = null):void
		{
			switch (type)
			{
				case 'wander': 
					wanderParams.x = wanderParams.start_x = x;
					wanderParams.y = wanderParams.start_y = y;
					wanderParams.radius = params && params.radius ? params.radius : 5;
					wanderParams.states = [];
					wanderParams.states[Global.STATE_RIGHTWALK] = 50;// Global.STATE_LEFTWALK: 50, Global.STATE_UPWALK: 50, Global.STATE_DOWNWALK: 50, Global.STATE_UPSTILL: 50, Global.STATE_DOWNSTILL: 100, Global.STATE_RIGHTSTILL: 60, Global.STATE_LEFTSTILL: 60 }
					
					wanderParams.statesSum = 0;
					for each (var num:int in wanderParams.states)
					{
						wanderParams.statesSum += num;
					}
					
					setState(Global.STATE_WANDERING);
					break;
			}
		}
		
		public function getSlots():Object
		{
			return (slots);
		}
		
		public function setSlot(slot:String, item:Item):void
		{
			slots[slot] = item;
			trace('set slot ' + slot + ' to ' + item.name + ' for character ' + name);
		}
		
		public function getSpells():Array
		{
			return (spells);
		}
		
		public function getDialog():XML
		{
			return (dialog);
		}
		
		public function hasDialog():Boolean
		{
			return (dialog != null);
		}
		
		public function getPortrait():XMLList
		{
			return (portrait);
		}
		
		public function hasSpell():Boolean
		{
			return (spells.length > 0);
		}
		
		public function addPathNode(xPos:int, yPos:int, pathIndex:int, pathDelay:int, pathSpeed:int):void
		{
			pathNodes[pathIndex - 1] = {x: xPos, y: yPos, index: pathIndex, speed: pathSpeed, delay: pathDelay};
		}
		
		public function addChaseRange(value:int):void
		{
			chaseRange = value;
		}
		
		public function setDosile():void
		{
			isDosile = true;
			dosileTimer = new Timer(100, 0);
			dosileTimer.addEventListener(TimerEvent.TIMER, dosileTimerHandler);
			dosileTimer.start();
		}
		
		private function dosileTimerHandler(e:TimerEvent):void
		{
			if (!rect.intersects(Global.game.party.leader.rect))
			{
				e.target.stop();
				dosileTimer = null;
				isDosile = false;
			}
		}
		
		/************************ COMBAT STUFF ***********************************/
		private const FISTS_BONUS:int = 0;
		
		private var combatTarget:Object;
		private var combatAction:Object;
		private var combatTimer:Timer;
		private var combatCallback:Function;
		private var spellTarget:Object;
		private var spellAction:Object;
		private var spellTimer:Timer;
		private var spellCallback:Function;
		
		public function getWeaponBonus():int
		{
			return (10);
		/*if(equippedWeapon > -1) {
		   return(weapons[equippedWeapon].bonus);
		   } else {
		   return(FISTS_BONUS);
		 }*/
		}
		
		public function receiveAttack(damage:int):void
		{
			hp -= damage;
			trace("Attack received - " + name + "'s hp is now " + hp);
			if (hp <= 0)
			{
				hp = 0;
				die();
			}
		}
		
		public function sendAttack(dest:Character):Object
		{
			//hit?
			var hit:Boolean = false;
			var hitCalc:int = (dex + getWeaponBonus()) - (dest.dex + dest.getWeaponBonus()) + 10;
			hit = (Utils.randRange(1, 20) < hitCalc);
			
			//apply damage if hit
			if (hit)
			{
				var damageCalc:int = str + getWeaponBonus();
				var damage:int = Utils.randRange(damageCalc, 2 * damageCalc);
				trace(name + ' sent attack to ' + dest.name + ' and hit for ' + damage);
				dest.receiveAttack(damage);
				
				return ({message: "Hit for " + damage + "!", value: damage});
			}
			else
			{
				trace(name + ' sent attack to ' + dest.name + ' but missed.');
			}
			
			return ({message: "Missed!", value: null});
		}
		
		public function getEquippedWeapon():Item
		{
			return (slots["L. Hand"]);
		}
		
		public function sendSpell(spell:Spell, dest:Character):Object
		{
			var results:Object = spell.cast(dest);
			return ({message: "Spell!", value: 100});
		}
		
		private function die():void
		{
			setAnimState(Global.STATE_DEAD);
			setState(Global.STATE_DEAD);
		}
		
		public function setHP(value:int):void
		{
			hp = value;
			trace(name + "'s hp is now " + hp);
		}
		
		public function getHP():int
		{
			return (hp);
		}
		
		public function getMaxHP():int
		{
			return (maxHp);
		}
		
		public function getMP():int
		{
			return (mp);
		}
		
		public function getMaxMP():int
		{
			return (maxMp);
		}
		
		public function findCombatTarget(choices:Array):void
		{
			var rand:int = Utils.randRange(0, choices.length - 1);
			combatTarget = {"character": choices[rand], "index": rand}
		}
		
		public function getCombatTarget():Object
		{
			return (combatTarget);
		}
		
		public function getCombatAction():Object
		{
			return (combatAction);
		}
		
		public function getSpellTarget():Object
		{
			return (spellTarget);
		}
		
		public function getSpellAction():Object
		{
			return (spellAction);
		}
		
		public function clearCombatAction():void
		{
			combatTarget = null;
			combatAction = null;
			inCombat = false;
		}
		
		public function clearSpellAction():void
		{
			spellTarget = null;
			spellAction = null;
			inCombat = false;
		}
		
		public function setCombatAction(type:String, subtype:String, callback:Function):void
		{
			combatAction = {"type": type, "subtype": subtype};
			
			combatCallback = callback;
		}
		
		public function setSpellAction(spellIndex:int, callback:Function):void
		{
			spellAction = {"spellIndex": spellIndex};
			
			spellCallback = callback;
		}
		
		public function setCombatTarget(target:Character, index:int):void
		{
			combatTarget = {"character": target, "index": index};
		}
		
		public function setSpellTarget(target:Character, index:int):void
		{
			spellTarget = {"character": target, "index": index};
		}
		
		private function combatActionDone(e:TimerEvent):void
		{
			combatCallback(this, sendAttack(combatTarget.character));
			clearCombatAction();
		}
		
		private function spellActionDone(e:TimerEvent):void
		{
			//spellCallback(this, sendSpell(spellTarget.character));
			clearSpellAction();
		}
		
		public function performCombatActions():void
		{
			inCombat = true;
			combatTimer = new MyTimer(1000, 1);
			combatTimer.addEventListener(TimerEvent.TIMER, combatActionDone);
			combatTimer.start();
		}
		
		public function performSpellActions():void
		{
			inCombat = true;
			combatTimer = new MyTimer(1000, 1);
			combatTimer.addEventListener(TimerEvent.TIMER, spellActionDone);
			combatTimer.start();
		}
		
		private function clearTimers():void
		{
			combatTimer.stop();
			combatTimer = null;
			inCombat = false;
			combatCallback = null;
		}
	}
}