// Sandy Mode7 Test
// Arrow Keys + Page Up/Down
// For some reason it messes up if you look down...
package {
   import flash.display.*;
   import flash.events.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.filters.*
   import flash.text.*;
   import flash.geom.*
   import flash.media.*
   import flash.net.*
   //
   import sandy.core.*;
   import sandy.core.data.*;
   import sandy.core.scenegraph.*;
   import sandy.events.*
   import sandy.materials.*;
   import sandy.materials.attributes.*;
   import sandy.primitive.*;
   import sandy.view.*
   import sandy.core.scenegraph.mode7.*;

   public class Awesome extends TopLevel 
   {
      private var debugText:TextField = new TextField();
      //
      private var scene:Scene3D;
      private var camera:CameraMode7;
      private var ground:Mode7;
      private var root2:Group;

      private var lightA:LightAttributes = new LightAttributes (true, 0.5);
      private var lightB:GouraudAttributes = new GouraudAttributes (true, 0.25);

      private var rotateY:Number = 3*Math.PI/2;
      private var rotateZ:Number = 0;
      
      private var count:int = 0;
      private var time:Number = getTimer();
      private var keysDown:Object = new Object();// stores key codes of all keys pressed
      
      private var groundBmd:BitmapData;
      
      public function Awesome(groundBmd:BitmapData) {
         debugText = new TextField();
         debugText.width = 400;
         debugText.height = 300;
         debugText.multiline = true;
         debugText.wordWrap = true;
         debugText.textColor = 0x0000FF;
         debugText.selectable = false;
         addChild(debugText);
         
         this.groundBmd = groundBmd;
         Mouse.hide();

         addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
            initialize();
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
            addEventListener(Event.ENTER_FRAME, EveryFrame);
         });
      }
      
      private function initialize():void {
          
          camera = new CameraMode7( stage.stageWidth, stage.stageHeight );
          camera.x = 0;
          camera.y = 30;
          camera.z = 100;
          camera.lookAt(0,0,0);

          root2 = new Group();
          
          lightA.diffuse = 0.5;
          lightA.specular = 0.5;
          lightA.gloss = 1;
          lightA.ambient = 0.5;
          
          lightB.diffuse = 2.5;
          lightB.specular = 1.5;
          lightB.gloss = 1;
          lightB.ambient = 0.4;
          
          var box:Box = new Box("box", 20, 20, 20);
          box.y = 10;
          
          var materialAttr:MaterialAttributes = new MaterialAttributes(lightB);
           
          //var material:Material = new ColorMaterial( 0xAAAAAA, 1, materialAttr);
          //material.lightingEnable = true;
          //box.appearance = new Appearance(material)
          
          root2.addChild(box);
          
          
          var bmd:BitmapData = new BitmapData(400, 400, false, 0xCCCCCCCC);
          var channels:uint = BitmapDataChannel.RED | BitmapDataChannel.BLUE | BitmapDataChannel.GREEN;
          bmd.perlinNoise(100, 100, 6, int(Math.random() * 10), true, false, channels, false, null);
          
          ground = new Mode7();
          ground.setBitmap(groundBmd, 0.5, true, false);
          ground.setHorizon(false);
          //ground.setNearFar (true)
          root2.addChild(ground);
          
          scene = new Scene3D( "scene", this, camera, root2 );
          scene.light.color = 0xFFFFFF;
          scene.light.setDirection(0, -100, 0);
          scene.light.setPower(2.5);
      }

      private function EveryFrame(event:Event):void{
          count++;
          
          if(count%20==0){
              debugText.text = "FPS "+String(Math.round((1000/(getTimer()-time))*20*100)/100);
              time = getTimer();
          }
          
          if(isDown(Keyboard.UP)){
               camera.moveForward(5);
          }
          if(isDown(Keyboard.DOWN)){
               camera.moveForward(-5)
          }
          if(isDown(Keyboard.PAGE_UP)){
               camera.y += 5;
          }
          if(isDown(Keyboard.PAGE_DOWN)){
               camera.y -= 5;
          }
          if(isDown(Keyboard.RIGHT)){
              camera.x += Math.cos(rotateY+Math.PI/2)*-2;
              camera.z += Math.sin(rotateY+Math.PI/2)*-2;
          }
          if(isDown(Keyboard.LEFT)){
              camera.x += Math.cos(rotateY+Math.PI/2)*2;
              camera.z += Math.sin(rotateY+Math.PI/2)*2;
          }
          camera.y = Math.max(camera.y,50);
          rotateY -= (this.mouseX-465/2)/10000;
          rotateZ -= (this.mouseY-465/2)/10000;
          rotateZ = Math.min(rotateZ,Math.PI/2);
          rotateZ = Math.max(rotateZ,-Math.PI/2);
          
          camera.lookAt(
          camera.x+Math.cos(rotateY)*Math.cos(rotateZ), 
          camera.y+Math.sin(rotateZ), 
          camera.z+Math.sin(rotateY)*Math.cos(rotateZ)
          )
          
          scene.render();
      }
     
      private function isDown(keyCode:uint):Boolean {
          return Boolean(keyCode in keysDown);
      }
      private function keyPressed(event:KeyboardEvent):void {
                 keysDown[event.keyCode] = true;
      }
      private function keyReleased(event:KeyboardEvent):void {
          if (event.keyCode in keysDown) {
              delete keysDown[event.keyCode];
          }
      }
   }
}