package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	public class kashikariApp extends Sprite
	{
		public function kashikariApp()
		{
			super();
			
			//プロジェクト生成時のデフォルトコード ここから--------------------------------
			
			//この設定を外すと画像がスケールされてぴったりになった？
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			//プロジェクト生成時のデフォルトコード ここまで--------------------------------
			
			
			var mainContainer:MainContainer = new MainContainer();
			addChild(mainContainer);
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
	}
}