﻿package ui {
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.ui.Keyboard;
   
   import ui.*
   import util.Utils;

   public class DialogBox extends Screen {
      private var options:Array = new Array();
      private var selector:TextField = new TextField();
      private var dialogText:TextField;
      private var selectedOption:int = 0;
      
      private var conversation:XML;
      private var npc:Party;
      private var currentPrompt:XML;
      private var actionCallback:Function;
      private var endCallback:Function;
      
      public function DialogBox(conversation:XML, npc:Party = null, actionCallback:Function = null, endCallback:Function = null) {
         this.conversation = conversation;
         this.npc = npc;
         this.actionCallback = actionCallback;
         this.endCallback = endCallback;
         var initialPrompt:XML = XML(conversation.prompt.(@type=="initial"));
         
         addBox(20, Global.game.stage.stageHeight - 200, Global.game.stage.stageWidth - 40, 125, "dialog", "vertical", 0, Screen.DEFAULT_BOX_COLOR, defaultChoice);
         displayPrompt({prompt: initialPrompt});
         switchBox("dialog"); 
         
         addEventListener(Event.ADDED, addKeyListener);
      }
      
      public function displayPrompt(params:Object):void {
         currentPrompt = XML(params.prompt);
         var choiceIds:Array = String(currentPrompt.@choiceIds).length > 0 ? String(currentPrompt.@choiceIds).split(",") : [];
         var actionType:String = currentPrompt.@action;
         var promptText:String = currentPrompt.random.length() ? currentPrompt.random[Utils.randRange(0, currentPrompt.random.length()-1)] : currentPrompt;

         clear("dialog");
         addBoxText("dialog", promptText);

         //if prompt has choices
         if(choiceIds.length) {
            for each(var choiceId:int in choiceIds) {
               var choice:XML = XML(conversation.choice.(@id==choiceId));
               var choiceText:String = choice.text();
               var choiceAction:String = choice.@action;

               addMenuText("dialog", choiceText, displayPrompt, { prompt: conversation.prompt.(@id == choice.@promptId) } );
            }
         } else if (actionType.length) {
trace(actionType);
            switch(actionType) {
               case "end":
                  break;
               case "encounter":
                  removeKeyListener();
                  Global.game.startEncounter(Test(parent).party, npc);
                  //Test(parent).endDialog();
                  break;
               case "dialog":
                  clear("dialog");
                  
                  break;
               case "prompt":
                  break;
               default: 
                  if(actionCallback != null) { actionCallback(actionType); }
                  break;
            }
         }
      }
      
      
      public function chooseSelectedOption():void 
      {
         if(options.length && options[selectedOption].callback) {
            if(options[selectedOption].callbackParams) {
               options[selectedOption].callback(options[selectedOption].callbackParams);
            } else {
               options[selectedOption].callback();
            }
         } else {
            npc.leader.setDosile();
            Test(parent).endDialog();
         }
      }
      
      public function defaultChoice():void
      {
trace('defaultChoice()');
         var actionType:String = currentPrompt.@action;
         switch(actionType) {
            case "prompt":
               var promptId:int = int(currentPrompt.@promptId);
trace('-------------------');
trace(conversation);
trace('-------------------');
trace(conversation.prompt);
trace('-------------------');
trace(conversation.prompt.(@id == promptId));
               displayPrompt( {prompt: conversation.prompt.(@id == promptId)} );
               break;
            default:
               if (npc) { npc.leader.setDosile(); }
               if (endCallback != null) { 
                  endCallback();
               } else {
                  Global.game.endDialog();
               }
              break;
         }
      }
   }
}