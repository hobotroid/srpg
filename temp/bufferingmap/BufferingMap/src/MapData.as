package  {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class MapData extends EventDispatcher {

		// ==================================================================================================================
		// STATIC MEMBERS                                                                                      STATIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PUBLIC MEMBERS                                                                                      PUBLIC MEMBERS
		// ==================================================================================================================

		public var dataBase:Array;
		public var dataOver:Array;
		
		public var width:int;
		public var height:int;
		public var chipset:String;
		
		// ==================================================================================================================
		// PRIVATE MEMBERS                                                                                    PRIVATE MEMBERS
		// ==================================================================================================================

		protected var myloader:URLLoader;
		
		// ==================================================================================================================
		// CONSTRUCTOR / DESTRUCTOR                                                                  CONSTRUCTOR / DESTRUCTOR
		// ==================================================================================================================

		public function MapData( ) {
			init();
		}

		// ==================================================================================================================
		// PUBLIC FUNCTIONS                                                                                  PUBLIC FUNCTIONS
		// ==================================================================================================================
		
		/**
		 * Loads the passed map. Fires Event.COMPLETE when finished loading.
		 * @param	mapName
		 */
		public function loadMap( mapName:String ):void {
			myloader = new URLLoader();
            myloader.addEventListener( Event.COMPLETE, mapLoaded );
            var request:URLRequest = new URLRequest( "maps/" + mapName + ".xml" );
            try {
                myloader.load( request );
            }
			catch (error:Error) {
                //trace("Unable to load.");
            }
		}
		
		// ==================================================================================================================
		// PRIVATE FUNCTIONS                                                                                PRIVATE FUNCTIONS
		// ==================================================================================================================

		protected function init():void {
			
		}

		// ==================================================================================================================
		// PROPERTIES                                                                                              PROPERTIES
		// ==================================================================================================================


		// ==================================================================================================================
		// EVENTS AND CALLBACKS                                                                          EVENTS AND CALLBACKS
		// ==================================================================================================================
		
		private function mapLoaded( e:Event ):void {
			var mymap:XML = new XML( myloader.data );
			width = int( mymap.@w );
			height = int( mymap.@h );
			chipset = mymap.@chipset;
			//trace( "Map loaded : " + [ width, height ] );
			
			var tempData:Array;
			var i:int;
			
			tempData = mymap.base.split( "|" );
			dataBase = new Array();
			for ( i = 0; i < tempData.length; i++ ) {
				dataBase.push( tempData[ i ].split( "," ) );
			}
			
			tempData = mymap.overlay.split( "|" );
			dataOver = new Array();
			for ( i = 0; i < tempData.length; i++ ) {
				dataOver.push( tempData[ i ].split( "," ) );
			}
			
			// bubble the event up
			dispatchEvent( e.clone() );
		}

	}
}
