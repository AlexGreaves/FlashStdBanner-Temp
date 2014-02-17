/**
* VER: 1.0
* DATE: 09 July 2013
* FLA: AS3

* This Banner template was developed to improve the production process of creating OLA Standard Banners.
* Achieved by reducing repetitive tasks that clog up resources and process standardisation.

* The 'Framework' class is the backbone of the banner campaign and should only contain functions and variables
* that are commonly found in most campaigns. These functions and/or variables can be turned off and on as needed in the 
* 'Main.as' file of your project. 'Framework' should be shared between all creatives in the campaign and should require
* minimum to zero editing.

* @author Alex Greaves, alex@wearesuburb.com
*/

package framework{
	// = = = = Class Imports = = = =
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*
	
	// = = = = Framework Class = = = =
	public class Framework extends Sprite {
		// = = = = Global variables = = = =
		// = = These variables are defined in 'Main.as'
		public static var frameName:String = 'frameHolder'; // = = Used to define the holder clip name for all frames
		public static var numberOfFrames:Number = 1; // = = Used to set the number of frames the banner has
		public static var doesTheBannerLoop:Boolean = false; // = = Used to dictate whether or not the banner should loop
		public static var requiredLoops:Number = 0; // = = Used to dictate how many loops the banner requires
		
		// = = These variables are referenced in 'Main.as'
		// = = The following 3 vars are set up in the 'buildStage' function
		public static var background:MovieClip; // = = Used to a hold a reference to the background MovieClip on the Timeline. 
		public static var extraClips:Object = new Object; // = = Used for adding stage references for any additional MovieClips. The classes for these should be passed into the 'buildStage' function as an array. eg. 'buildStage([newObjectClass])'. This does not include 'background' and '[frameName]' MovieClips
		public static var currentFrame:MovieClip = null; // = = Used to target the current frameHolderClip on the stage. This is set at the beginning of 'playBanner()'

		public static var frameCounter:Number = 1; // = = Used as reference in frameSwitch. Counts from 1 to 'numberOfFrames'
		public static var frameSwitch:String = '1-in'; //  = = Used by 'playBanner' in 'Main.as' to run a switch statement. Defines whether the frame is entering the stage or exiting through '-in' and 'out' respectively
		public static var loopCounter:Number = 1; // = = Used to display how many times the banner has looped. used in conjunction with 'requiredLoops' to stop the banner on the necessary count
		
		private var startTime:Number; // = = Used by 'endTimer' and 'adLengthTimer' functions to calculate banner length. Internal to 'Framework'

		// = = = = Framework Function = = = =
		public function Framework() {
		// = = Function initially loaded by 'Main.as' once the Framework Class has been found
			trace("@F: Framework has been loaded");
			getChildByName('whiteLoader').visible = false; // = = The 'whiteLoader' MovieClip should be placed at the top level of your Timeline. It is used to hide anything underneath until the .as files have loaded
			createStageMask();// = = Create a mask over the stage
			adLengthTimerFunction(); // = = Starts a timer to calculate the length of the banner. This is traced out once the banner completes
		}

		// = = = = Setup Functions - Use Once at start of creative = = = =
		public function createClickButton(manualClickTag:String = '') { 
			// = = Create a click button the size of the stage. A click tag version can be set as a string to be passed in from 'Main.as'. eg. clickTag, CLICKTAG, clicktag 
			var testUrl:String = 'http://www.wearesuburb.com' // = = Default page if in a testing environment
			var clickBtnShape:Shape = new Shape;
			var click_btn:MovieClip = new MovieClip;

			// = = Create a shape the size of the stage
			clickBtnShape.graphics.beginFill(0x000000);
			clickBtnShape.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			clickBtnShape.graphics.endFill();
			clickBtnShape.width = stage.stageWidth;
			clickBtnShape.height = stage.stageHeight;
			clickBtnShape.x = 0;
			clickBtnShape.y = 0;

			// = = The 'clickBtnShape' is added as a child of a new MovieClip and is given a button mode and a CLICK listener. This is then added at the top of the stage
			click_btn.alpha = 0;
			click_btn.buttonMode  = true;
			click_btn.addChild(clickBtnShape);
			stage.addChild(click_btn);
			click_btn.addEventListener(MouseEvent.CLICK, clickTagFunction);

			function clickTagFunction(e:Event):void {
			// = = Function checks for 2 variables. If a 'clickTag' is passed in as a flash var this will be given usage priority. A manual 'clickTag can be set and passed in 'Main.as' as a backup. If none are passed in then the banner will exit to the test site url
			if(checkClickTag() != ''){
				trace ('@F: clickTag has been set by the publisher');
				navigateToURL(new URLRequest(checkClickTag()), '_blank');
			}else if (manualClickTag != '') {
				trace('@F: manual ' + manualClickTag + ' passed in');
				navigateToURL(new URLRequest(root.loaderInfo.parameters[manualClickTag as String]), '_blank');
			} else if (testUrl != ''){
				trace ('@F: clickTag returns false');
				navigateToURL(new URLRequest(testUrl), '_blank');
			} else {
				trace('@F: --- LINK NOT SPECIFIED');
			}
		}

		function checkClickTag():String {
			// = = Checks passed in Strings for any version of 'clicktag' and returns the String. If no string is found checkClickTag returns nothing
		    for (var param:String in root.loaderInfo.parameters){
		    	if(param.toLowerCase() == 'clicktag'){
		            return root.loaderInfo.parameters[param];
				}
			}
			return '';
			}
		}

		public function createStageMask() {
		// = = Function creates a mask over the stage
			var stageMask:Shape = new Shape;
			var maskHolder:MovieClip = new MovieClip;
			stageMask.graphics.beginFill(0x000000);
			stageMask.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			stageMask.graphics.endFill();
			maskHolder.addChild(stageMask);
			stage.addChild(maskHolder);
			Sprite(root).mask = maskHolder;
		}
		
		public function createKeyline(keyLineWidth:Number = 1, keyLineColour:Number = 0x000) {
		// = = Function to create a keyline around the edge of the stage. Requires line width and colour from 'Main.as'
			var keyline:Shape = new Shape;
			var startPos:Number = keyLineWidth/2;
			keyline.graphics.lineStyle(keyLineWidth, keyLineColour, 1, false, LineScaleMode.NORMAL, null,JointStyle.MITER);
			keyline.graphics.moveTo(startPos, startPos); 
			keyline.graphics.drawRect(startPos, startPos, stage.stageWidth-keyLineWidth, stage.stageHeight-keyLineWidth);
			stage.addChild(keyline);
		}

		// = = = = Frame Navigation functions = = = =
		public function frameForward():String {
		// = = Progresses the timeline forward, stops the playlist or restarts based on which frame 'playBanner' is currently on
			if (frameSwitch == numberOfFrames.toString() + '-in') {
				// = = Checks to see whether 'playBanner' is entering the last frame 
				if (doesTheBannerLoop == true && loopCounter<requiredLoops ) {
					// = = Checks to see whether the banner is looping and whether the banner has reached the required amount of loops
					frameSwitch = frameCounter.toString() + '-out';
				} else {
					// = = Send 'playBanner' to its 'endFrame'
					frameSwitch = 'endFrame';
				}
			} else {
				// = = if 'playBanner' is not on its last frame
				if(frameSwitch == frameCounter.toString() + '-in') {
					// = = Check 'frameSwitch' state. If '-in' then change to '-out'
					frameSwitch = frameCounter.toString() + '-out';
				} else {
					// = = if 'out' then check 
					if(frameSwitch == numberOfFrames.toString() + '-out') {
						// = = if 'playBanner' is on the '-out' state of the final frame then reset the 'frameCounter', increase the loopCounter and reset 'frameSwitch' based on the new 'frameCounter'
						frameCounter = 1;
						loopCounter++;
						frameSwitch = frameCounter.toString() + '-in';
					} else {
						// = = if 'out' on any other frame increase the 'frameCounter' and change 'frameSwitch' to '-in'
						frameCounter++;
						frameSwitch = frameCounter.toString() + '-in';
					}
				}
			}
			// = = return the String 'frameSwitch'
			return frameSwitch;
		}

		public function buildStage(additionalChildren:Array = null) {
			// = = This function adds all items to the stage based on a number of checks. The function can also be passed an array of extra MovieClips to add to the stage by 'Main.as'
			var aName:String;
			var aClass:Class;
			var a:MovieClip;
			var bgClass:Class;
			var bg:MovieClip;

			// = = Adds the 'background_' class to the main timeline at the lowest level
			bgClass = getDefinitionByName('background_') as Class;
			bg = new bgClass;
			bg.name = 'background'
			bg.alpha = 1;
			addChildAt(bg, 0);

			background = getChildByName('background') as MovieClip;

			for(var i:Number = 1;i<=numberOfFrames;i++) {
				// = = Check how many frames are in the banner and add to the main timeline. Change alpha to 0 and then add to the main timeline at it's given number. (hierarchy must begin with 1)
				aName = frameName + '_' + i as String;
				aClass = getDefinitionByName(aName) as Class;
				a = new aClass;
				a.name =  frameName + i as String;
				a.alpha = 0;
				addChildAt(a, i);
			}

			if (additionalChildren != null) {
				// = = Check if any classes have been passed into the 'additionalChildren' array by 'Main.as'
				var bonusName:String;
				var bonusClass:Class;
				var bonus:MovieClip;
				for(var b:Number = 0;b<=additionalChildren.length-1;b++) {
					// = = Add each additional child to the stage
					bonusClass = additionalChildren[b];
					bonus = new bonusClass;
					bonus.name = bonus.toString().substr(8,bonus.toString().length-10); // = = rename the MovieClip by stripping the name from '[object name]' to 'name'
					addChild(bonus); // = = add the item onto the  main Timeline
					var bonusRef:MovieClip = getChildByName(bonus.name) as MovieClip; // = = Get the Timeline reference of the new MovieClip
					extraClips[bonus.name] = bonusRef; // = = Add the new MovieClip to the 'extraClips' public object var. This makes it accessible through referencing 'extraClips.objectName'
				}				
			}		
		}
		
		public function loopBanner(playBanner, whichFrame) {
		// = = Function replaces all MovieClips on the stage requires the 'playBanner' function and 'whichFrame' String from 'main.as'
			var a:MovieClip; 
			var mcName:String;
			var mcClass:Class;
			var mc:MovieClip;
			var frameNumber;
			var newFrameArray:Array = new Array;
			var oldFrameArray:Array = new Array;

			for (var i:Number = 0; i<=this.numChildren-1; i++) {
				a = getChildAt(i) as MovieClip;
				if (a.name.indexOf('frame') >= 0) {
				// = = Check for MovieClips with 'frame' in the name and then add to old and new arrays
					frameNumber = getNumbersFromString(a.name);
					mcName = frameName + '_' + frameNumber as String;
					mcClass = getDefinitionByName(mcName) as Class;
					mc = new mcClass;
					mc.name = frameName + frameNumber as String;
					mc.alpha = 0;

					newFrameArray.push(mc);
					oldFrameArray.push(a);
				} else if (a.name.indexOf('frame') == -1 && a.name != 'whiteLoader') {
					// = = Check for anything on the stage that is not a frame or the 'whiteLoader' MovieClip and then add to old and new arrays
					mcName = a.name + '_';
					mcClass = getDefinitionByName(mcName) as Class;
					mc = new mcClass;
					mc.name = a.name;
				
					newFrameArray.push(mc);
					oldFrameArray.push(a);
				}
			}
			for (var n:Number = 0; n<=newFrameArray.length-1;n++) {
				//re-add each MovieClip at same z-index position that it was removed
				removeChild(oldFrameArray[n]);
				addChildAt(newFrameArray[n], newFrameArray.indexOf(newFrameArray[n]));
			}
			// = = restart the 'playBanner' function in 'Main.as'
			playBanner(whichFrame);
		}

		// = = = = additional functions = = = =
		public function clearFrameHoldersFromStageExcept(mc) {
			for (var i:Number = 0; i < this.numChildren-1; i++) {
				if (getChildAt(i).name.indexOf('frame') >= 0) {
					if(getChildAt(i).name != mc.name) {
						getChildAt(i).alpha=0;
						trace(getChildAt(i).name +  ', alpha: ' + getChildAt(i).alpha)
					} else {
						mc.alpha = 1;
						trace('currentClip.alpha is ' + mc.alpha);
					}
				}
			}
		}
		function randomNum(minNum:Number, maxNum:Number):Number {
		// = = Function generates a random number based on a minimum and maximum value. Both requires as Numbers
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);  
		}

		function getNumbersFromString (str:String):Array {
		    return str.replace(/[^0-9]/g, "").split("");
		}

		// = = = = testing functions = = = =
		public function testing_jumpToFrame(frameNumber:Number) {
		// = = Function called to change the frame for testing on a frame by frame basis
			frameCounter = frameNumber; // = = Change for testing purposes
			frameSwitch = frameCounter.toString() + '-in';
		}

		public function adLengthTimerFunction() {
		// = = Function used for testing. Adds a timer
			startTime = new Date().getTime();
		}

		public function endTimer() {
		// = = Function used for testing. Traces the run time of the ad
			var totalAdLength:Number = new Date().getTime() - startTime;
			trace ('@F: ad length ran for '+totalAdLength/1000 + ' seconds');
		}
	}
}
