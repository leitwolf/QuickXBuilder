package app.win
{
	import AirLib.G;
	
	import app.Config;
	import app.data.FileData;
	import app.message.MessageCenter;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.TitleWindow;

	/**
	 * 删除文件确认
	 * @author lonewolf
	 * 
	 */	
	public class DeleteFileConfirmWin
	{		
		private var _ref:Object;
		
		public function DeleteFileConfirmWin(ref:Object)
		{
			_ref=ref;
			//center
			var width:Number=FlexGlobals.topLevelApplication.width;
			var height:Number=FlexGlobals.topLevelApplication.height;
			var win:TitleWindow=ref as TitleWindow;
			win.title="确认";
			win.x=(width-win.width)/2;
			win.y=(height-win.height)/2;
			win.addEventListener(CloseEvent.CLOSE,closeHandler);
						
			//events
			(_ref.ok as Button).addEventListener(MouseEvent.CLICK,okHandler);
			(_ref.cancel as Button).addEventListener(MouseEvent.CLICK,cancelHandler);
		}
		
		protected function cancelHandler(event:MouseEvent):void
		{
			this.closeHandler(null);
		}
		
		protected function okHandler(event:MouseEvent):void
		{
			Config.projectViewPart.deleteFile();
			this.closeHandler(null);
		}
		
		protected function closeHandler(event:CloseEvent):void
		{
			G.curScene.onStart();
			PopUpManager.removePopUp(_ref as TitleWindow);
		}
	}
}