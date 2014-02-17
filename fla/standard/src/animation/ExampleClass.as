package animation {
	import flash.display.Stage;
	public class ExampleClass {
		private var stage:Stage; //  = = public variables should be placed here if required
		public function ExampleClass(stageRef:Stage) {
			stage = stageRef; // = = Imports the stage from 'Main.as'
			trace('@E: Example Class loaded');
		}
		public function testFunction() {
			trace('@E: YEE-HAW You found me partner');
		}
	}
}