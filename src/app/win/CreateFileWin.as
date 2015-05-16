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
	 * 建立场景 
	 * @author lonewolf
	 * 
	 */	
	public class CreateFileWin
	{		
		private var _ref:Object;
		private var _name:TextInput;
		
		public function CreateFileWin(ref:Object)
		{
			_ref=ref;
			_name=_ref.name1;
			//center
			var width:Number=FlexGlobals.topLevelApplication.width;
			var height:Number=FlexGlobals.topLevelApplication.height;
			var win:TitleWindow=ref as TitleWindow;
			win.title="新建场景";
			_name.text="GameScene";
			_name.selectAll();
			win.x=(width-win.width)/2;
			win.y=(height-win.height)/2;
			win.addEventListener(CloseEvent.CLOSE,closeHandler);
						
			//events
			(_ref.ok as Button).addEventListener(MouseEvent.CLICK,okHandler);
			_name.addEventListener(FlexEvent.ENTER,enterHandler);
		}
		/**
		 * 回车 
		 * @param event
		 * 
		 */
		protected function enterHandler(event:FlexEvent):void
		{
			this.okHandler(null);
		}
		
		protected function okHandler(event:MouseEvent):void
		{
			var name:String=_name.text;
			if(name=="")
			{
				Alert.show("请输入名称");
				return;
			}
			else if(FileData.checkExist(name))
			{
				var str:String="";
				str="该场景已存在";
				Alert.show(str);
				return;
			}
			var fileData:FileData=Config.newFile(name);
			if(Config.curFileData)
			{
				Config.curFileData.save();
				MessageCenter.sendMessage(null,MessageCenter.FILE_SAVED);
			}
			Config.curFileData=fileData;
			Config.fileDataList.push(fileData);
			MessageCenter.sendMessage(null,MessageCenter.NEW_FILE);
			this.closeHandler(null);
		}
		
		protected function closeHandler(event:CloseEvent):void
		{
			G.curScene.onStart();
			PopUpManager.removePopUp(_ref as TitleWindow);
		}
	}
}