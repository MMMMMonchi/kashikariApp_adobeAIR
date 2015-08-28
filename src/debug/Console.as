/////////////////////////////////////////////////////////////////////////////
//コンソール出力部分を生成するクラス
/////////////////////////////////////////////////////////////////////////////
package debug {
	import flash.utils.getTimer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.system.Capabilities;
	import common.CommonConstant;
	public class Console extends Sprite{
		public function Console() {
			makeField();
		}
		private var _consoleField:TextField;
		private var _background:Shape;
		private var _displayButton:Sprite;
		private function makeField():void {
			
			//コンソール用のテキストフィールドを生成
			_consoleField = new TextField();
			_consoleField.multiline = true;
			_consoleField.width = CommonConstant.IPHONE4_DISPLAY_WIDTH / 2;
			_consoleField.height = CommonConstant.IPHONE4_DISPLAY_HEIGHT;
			_consoleField.visible = false;
			
			//白い背景を生成
			_background = new Shape();
			_background.graphics.beginFill(0xffffff, 0.8);
			_background.graphics.lineStyle(2, 0x999999, 1, true);
			_background.graphics.drawRect(0, 0, _consoleField.width, _consoleField.height + 20);
			_background.visible = false;
			addChild(_background);
			addChild(_consoleField);
			
			//コンソール部の表示、非表示を切り替えるボタン
			_displayButton = new Sprite();
			_displayButton.graphics.beginFill(0x0066ff, 0.5);
			_displayButton.graphics.drawRect(0, 0, 80, 60);
			_displayButton.x = _consoleField.width - _displayButton.width;
			_displayButton.addEventListener(MouseEvent.MOUSE_DOWN, onMDownDisplayButton);
			addChild(_displayButton);
			
			x = CommonConstant.IPHONE4_DISPLAY_WIDTH - _consoleField.width;
		}
		
		/////////////////////////////////////////////////////////////////////////////
		//コンソールの表示非表示を切り替えるマウスイベント
		/////////////////////////////////////////////////////////////////////////////
		
		private var _displayFlag:Boolean = false;
		private function onMDownDisplayButton(e:MouseEvent):void {
			if (_displayFlag == true) {
				_consoleField.visible = false;
				_background.visible = false;
				_displayFlag = false;
			}else {
				_consoleField.visible = true;
				_background.visible = true;
				_displayFlag = true;
			}
		}
		
		/////////////////////////////////////////////////////////////////////////////
		//コンソールを表示する（ランタイムエラー時等に実行）
		/////////////////////////////////////////////////////////////////////////////
		
		public function display():void {
			_consoleField.visible = true;
			_background.visible = true;
			_displayFlag = true;
		}
		
		/////////////////////////////////////////////////////////////////////////////
		//コンソール文を追加する
		/////////////////////////////////////////////////////////////////////////////
		
		public function add(text:String, fileName:String = "", methodName:String = "", lineNumber:int = 0):void {
			
			if (CommonConstant.DEVICE_ERROR_CONSOLE_DISPLAY_FLAG == false && CommonConstant.SPECIAL_DEBUG_MODE == false) {
				//本番では出力を行わずに処理を停止する
				return;
			}
			if (fileName == "") {
				fileName = "省略されました。";
			}
			if (methodName == "") {
				methodName = "省略されました。";
			}
			var lineNumberString:String = lineNumber.toString();
			if (lineNumber == 0) {
				lineNumberString = "省略されました。";
			}
			
			//通常のデバッグの設定の場合
			if (CommonConstant.SPECIAL_DEBUG_MODE == false) {
				trace("---------------------------------------------------------------\n出力内容:" + text, "\nファイル名:" + fileName + "\nメソッド名:" + methodName + "\n" + lineNumberString + "行目" + "\n---------------------------------------------------------------");
				_consoleField.text = text + "\n" + "ファイル名：" + fileName +"\n" + "メソッド名：" + methodName +"\n" +   "行数：" + lineNumberString + "行目" + "\n------------------------------------------------------\n" + _consoleField.text;
				//コンソールの上限文字数を設定
				if (_consoleField.text.length > 10000) {
					_consoleField.text = _consoleField.text.substr(0, 7000);
				}
				return;
			}
			
			//実機上での本番環境などでのデバッグ用の設定の場合
			if (CommonConstant.SPECIAL_DEBUG_MODE == true) {
				trace("---------------------------------------------------------------\n出力内容:" + text, "\nファイル名:" + fileName + "\nメソッド名:" + methodName + "\n" + lineNumberString + "行目" + "\n---------------------------------------------------------------");
				_consoleField.text = text + "\ntime is " + getTimer().toString() + "\nファイル名：" + fileName +"\n" + "メソッド名：" + methodName +"\n" +   "行数：" + lineNumberString + "行目" + "\n------------------------------------------------------\n" + _consoleField.text;
				return;
			}
		}
		
		/**
		 * （読み取り専用）現在のコンソール出力中のテキスト－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
		 */
		public function get _currentConsoleText():String {
			return _consoleField.text;
		}
	}
}