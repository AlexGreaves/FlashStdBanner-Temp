FlashStdBanner-Temp  // Created by Alex Greaves
===================
Flash Standard banner template created to help improve banner production process. Special thanks to Greensock for the Tweenlite package (http://www.greensock.com/tweenlite/).

Further detailed instructions are available in all AS3 Classes.

When creating a banner for the first time follow these basic instructions:

	1. Duplicate source folder

	2. Rename relevant files

	3. Open '300x250_rename.fla' and 'Main.as'
		'Main.as' works as your timeline, achieved through a switch statement based on the 'numberOfFrames' variable.

	4. Set number of frames and looping functionality.

	5. In your Fla file create a frameholder Movieclip equivalent to the number of frames defined in the 'numberOfFrames' variable. AS names should be the same as the 'frameName' variable.

	6. Any extra classes (example is exampleClass.AS) should be added in the same way as exampleClass.as. These can be used for specific animation or functionality.

	7. If Applicable - Add any extra MovieClips to the stage and define them as an array in the 'buildStage()' function.

	8. Create extra cases as needed and animate banner as given in the example!


Enjoy
