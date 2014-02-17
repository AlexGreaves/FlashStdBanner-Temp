/**
* VER: 1.0
* DATE: 09 July 2013
* FLA: AS3

* This Class contains parallax functionality for background items. This is based on a 'vanishingPoint' MovieClip
* placed inside the 'background' Movieclip on the stage. All speed is dependant on the 'vanishingPoint' position.

* It is optional to use simple perspective lines based on the 'bgFloor' MovieClip. This can be turned off by passing
* the boolean "false" to the 'animate' function.

* @author Alex Greaves, alex@wearesuburb.com
*/
package animation {
	// = = = = Imports = = = =
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.*

	// = = = = TweenLite Imports = = = =
	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	// = = = = Parallax Class = = = =
	public class Parallax {
		private var stage:Stage;
		private var lineHolder:MovieClip = new MovieClip;
		private var numLines:Number;

		// = = = = Parallax Function = = = =
		public function Parallax(stageRef:Stage) { // = =  Function called when Framework class is loaded
			stage = stageRef; // = = Imports the stage from 'Main.as'
			numLines = Math.floor(stage.stageWidth/8); // = = Calculates the number of lines according to the stage width
			trace('@P: Parallax Class loaded');
		}
		// = = = = Setup Functions = = = =
		public function lineSetup (mc:MovieClip) { // = = Function sets up the stage with a holder clip and a mask for the holder. Run once at the start of the banner
			var myShape:Shape = new Shape;
			var myMask:Shape = new Shape;
			var maskHolder:MovieClip = new MovieClip;

			myMask.graphics.beginFill(0xffffff);
			myMask.graphics.drawRect(0, mc.bgFloor.y, stage.stageWidth,stage.stageHeight);
			myMask.graphics.endFill();
			maskHolder.addChild(myMask);
			maskHolder.name = 'maskHolder';

			myShape.graphics.beginFill(0x000000,0);
			myShape.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			myShape.graphics.endFill();
			lineHolder.addChild(myShape);
			lineHolder.name ='lineHolder';

			mc.addChildAt(lineHolder,2); //  = = Set maskHolder as lineHolder's mask and add to stage
			mc.addChildAt(maskHolder,3);
			lineHolder.mask = maskHolder;
		}

		public function animate(movieclip, axis, time, distance, linesRequired = true) { // = = Function requires a movieclip, axis/direction, time, distance and whether to include lines. Creates the parallax
			var mc:MovieClip = movieclip;
			var bg:MovieClip = mc.bg;

			if (linesRequired == null) { // Default setting is to parallax floor lines
				linesRequired == true;
			}

			for(var i = 0; i < mc.numChildren; i++) {
				var a = mc.getChildAt(i); // = = Sets the current child as the MovieCLip to parallax

				if (a.name != 'vanishingPoint' && a.name != 'bgFloor' && a.name != 'bg' && a.name != 'lineHolder' && a.name != 'maskHolder') { // = = if loop determines that TweenLite only animates the required clips
					if (axis == 'horizontal') {	// = = Determines the direction of the parallax is horizontal			
						if (a.y > mc.vanishingPoint.y) { // = = Variable speed for clips below the vanishing point
							TweenLite.to(a, time, {x:a.x - ((distance/10) * (a.y - mc.vanishingPoint.y)), ease:Quad.easeOut, onUpdate:boundChecker, onUpdateParams:[a]});
						} else { // = = Clips above the vanishing point move at a contant speed
							TweenLite.to(a, time, {x:a.x - distance, ease:Quad.easeOut});
						}
					} else if (axis == 'vertical') { // = = Determines the direction of the parallax is vertical
						trace('@P: vertical hasnt been coded yet dummy');
					}
				} else if (a.name == 'vanishingPoint') { // = = If the vanishing point is selected calculate the floors movement
					if (linesRequired) {
						TweenLite.to(a, time, {x:a.x - distance, ease:Quad.easeOut, onUpdate:drawLine, onUpdateParams:[a]});	
					}
				}

				function boundChecker(a:MovieClip) { // = = Function to loop clips as they leave the stage area
					var a:MovieClip = a;
					if ((a.x+(a.width/2)) <= 0) {
						a.x = (a.x+a.width) + stage.stageWidth;
					}
				}

				function drawLine(a:MovieClip) { // = = Function creates multiple parallaxing lines from the vanishing point to the bottom of the stage
					var myLine:Shape = new Shape;
					myLine.graphics.lineStyle(2, 0x3E5D98, 0.1);

					removeChildrenOf(lineHolder);// Removes all current children of the lineHolder Clip
					
					for (var i:Number=1; i<=numLines;i++) { // = = Number of lines is set in the 'Parallax' function determined by the stage width
						var distFromVPoint = stage.stageHeight-a.y;// = = difference between start and end positions
						var startPos:Object = {x:((a.x - (20*i)) * (distFromVPoint/10))+(stage.stageWidth*4),y:stage.stageHeight}; // = = Calculates a new start Position based on the numer of predetermined lines 
						var endPos:Object = {x:a.x, y:a.y}; // = = end position is always the vanishing point
						
						myLine.graphics.moveTo(startPos.x, startPos.y); 
						myLine.graphics.lineTo(endPos.x, endPos.y);
					}

					lineHolder.addChild(myLine);

					function removeChildrenOf(mc:MovieClip) { // = = Function removes all children of given MovieClip
						if(mc.numChildren!=0){
							var k:int = mc.numChildren;
							while( k -- )
							{
								mc.removeChildAt( k );
							}
						}
					}
				}
			}
		}
	}
}