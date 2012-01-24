package com {

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class UIBase extends Sprite {

		// ==================================================================================================================
		// STATIC MEMBERS                                                                                      STATIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PUBLIC MEMBERS                                                                                      PUBLIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PRIVATE MEMBERS                                                                                    PRIVATE MEMBERS
		// ==================================================================================================================

		protected var __classname:String;
		protected var __packagename:String;
		protected var size:Point;

		// ==================================================================================================================
		// CONSTRUCTOR / DESTRUCTOR                                                                  CONSTRUCTOR / DESTRUCTOR
		// ==================================================================================================================


		/**
		* Class Constructor.
		*/
		public function UIBase( ) {
			size = new Point( 0, 0 );
		}

		// ==================================================================================================================
		// PUBLIC FUNCTIONS                                                                                  PUBLIC FUNCTIONS
		// ==================================================================================================================

		public function setSize( newWidth:Number, newHeight:Number ):void {
			//size = new Point( newWidth, newHeight );
			size.x = newWidth || size.x;
			size.y = newHeight || size.y;
			// re-render
			render();
		}

		public function setPosition( newx:Number, newy:Number ):void {
			x = newx;
			y = newy;
		}

		public function setRect( newx:Number, newy:Number, newWidth:Number, newHeight:Number ):void {
			setPosition( newx, newy );
			setSize( newWidth, newHeight );
		}

		public function setTooltip( caption:String ):void {
			// register our tooltip
			//_tooltip = caption;
			// figure out how to manage the container or tooltip manager
		}

		public override function toString():String {
			var ret:String = ( __packagename != "" ) ? __packagename + "." + __classname : __classname;
			return ret;
		}

		// ==================================================================================================================
		// PRIVATE FUNCTIONS                                                                                PRIVATE FUNCTIONS
		// ==================================================================================================================

		protected function dispose( ):void {
			this.dispose();
		}

		protected function render( ):void {
			// this is where you would place your specific code for rendering
			// the state at the current size.
		}

		// ==================================================================================================================
		// PROPERTIES                                                                                              PROPERTIES
		// ==================================================================================================================


		// ==================================================================================================================
		// EVENTS AND CALLBACKS                                                                          EVENTS AND CALLBACKS
		// ==================================================================================================================

	}
}
