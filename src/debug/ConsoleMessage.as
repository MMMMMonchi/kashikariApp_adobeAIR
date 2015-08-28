/////////////////////////////////////////////////////////////////////////////
//コンソール時に使用する情報を取得するクラス
//デバッグモードでの書き出し時のみしか値を取得できないようなので注意。
/////////////////////////////////////////////////////////////////////////////

package debug {
	import flash.system.Capabilities;
	public class ConsoleMessage {
		public function ConsoleMessage() {
		}
		// ファイル名を取得
		public static function getFileName(): String {
			if (Capabilities.isDebugger == false) {
				return "デバッグモードではないため値を取得できませんでした。出力するにはデバッグモードを使用してください";
			}
			return new Error().getStackTrace().split("\n")[2].match( /at .+\[(.+?[\.|\\]as)\:\d+\]/)[1].replace(/([\.|\\]as$)/, ".as");
		}
		// 短い(パスを含まない)ファイル名を取得
		public static function getShortfileName(): String {
			if (Capabilities.isDebugger == false) {
				return "デバッグモードではないため値を取得できませんでした。出力するにはデバッグモードを使用してください";
			}
			var val:String = new Error().getStackTrace();
			var list1:Array = val.split("\n");
			var list2:Array = list1[2].match( /at .+\[(?:.+\\)(.+?[\.|\\]as)\:\d+\]/);
			if(list2 == null && _global.androidDeviceFlag != null && _global.androidDeviceFlag){
				list2 = list1[3].match( /at .+\[(?:.+\\)(.+?[\.|\\]as)\:\d+\]/);
			}
			var rtn:String = list2[1].replace(/([\.|\\]as$)/, ".as");
			return rtn;
			//return new Error().getStackTrace().split("\n")[2].match( /at .+\[(?:.+\\)(.+?[\.|\\]as)\:\d+\]/)[1].replace(/([\.|\\]as$)/, ".as");
		}
		// メソッド名を取得
		public static function getMethodName(): String {
			if (Capabilities.isDebugger == false) {
				return "デバッグモードではないため値を取得できませんでした。出力するにはデバッグモードを使用してください";
			}
			//return String(new Error().getStackTrace().split("\n")[2].match( /at (.+)\[.+[\.|\\]as\:\d+\]/)[1]).replace("/", ".");
			var val:String = new Error().getStackTrace();
			var list1:Array = val.split("\n");
			var list2:Array = list1[2].match( /at (.+)\[.+[\.|\\]as\:\d+\]/);
			if(list2 == null && _global.androidDeviceFlag != null && _global.androidDeviceFlag){
				list2 = list1[3].match( /at (.+)\[.+[\.|\\]as\:\d+\]/);
			}
			var rtn:String = list2[1].replace("/", ".");
			return rtn;
		}
		// 行番号を取得
		public static function getLineNumber(): int {
			if (Capabilities.isDebugger == false) {
				return -1;
			}
			//return int(new Error().getStackTrace().split("\n")[2].match( /at .+\[.+[\.|\\]as\:(\d+)\]/)[1]);
			var val:String = new Error().getStackTrace();
			var list1:Array = val.split("\n");
			var list2:Array = list1[2].match( /at .+\[.+[\.|\\]as\:(\d+)\]/);
			if(list2 == null && _global.androidDeviceFlag != null && _global.androidDeviceFlag){
				list2 = list1[3].match( /at .+\[.+[\.|\\]as\:(\d+)\]/);
			}
			var rtn:int = int(list2[1]);
			return rtn;
		}
	}
}