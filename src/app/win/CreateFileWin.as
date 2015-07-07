package app.win
{
	import AirLib.G;
	
	import app.Config;
	import app.data.FileData;
	import app.message.MessageCenter;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.components.TitleWindow;

	/**
	 * 建立场景或控件
	 * @author lonewolf
	 * 
	 */	
	public class CreateFileWin
	{
		// 类型 1新建 2修改
		public static var type:int;
		
		private var _ref:Object;
		private var _name:TextInput;
		private var _type:RadioButtonGroup;
		
		public function CreateFileWin(ref:Object)
		{
			_ref=ref;
			_name=_ref.name1;
			_type=_ref.radiogroup1;
			//center
			var width:Number=FlexGlobals.topLevelApplication.width;
			var height:Number=FlexGlobals.topLevelApplication.height;
			var win:TitleWindow=ref as TitleWindow;
			_name.text="";
			if(type==1)
			{
				win.title="新建";
			}
			else
			{
				win.title="修改";
				_name.text=Config.curFileData.name;
				if(Config.curFileData.type==Config.FILE_TYPE_SCENE)
				{
					_type.selectedValue=1;
				}
				else
				{
					_type.selectedValue=2;
				}
			}
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
			if(type==1)
			{
				// 新建
				if(FileData.checkExist(name))
				{
					var str:String="";
					str="该文件已存在";
					Alert.show(str);
					return;
				}
				var fileData:FileData=Config.newFile(name);
				if(_type.selectedValue==1)
				{
					fileData.type=Config.FILE_TYPE_SCENE;
				}
				else
				{
					fileData.type=Config.FILE_TYPE_CUSTOM_CONTROL;
				}
				if(Config.curFileData)
				{
					Config.curFileData.save();
					MessageCenter.sendMessage(null,MessageCenter.FILE_SAVED);
				}
				Config.curFileData=fileData;
				Config.fileDataList.push(fileData);
				MessageCenter.sendMessage(null,MessageCenter.NEW_FILE);
			}
			else
			{
				// 修改名称
				var data:FileData=Config.curFileData;
				if(name!=data.name&&FileData.checkExist(name))
				{
					Alert.show("该文件已存在");
					return;
				}
				if(_type.selectedValue==1)
				{
					Config.curFileData.type=Config.FILE_TYPE_SCENE;
				}
				else
				{
					Config.curFileData.type=Config.FILE_TYPE_CUSTOM_CONTROL;
				}
				Config.curFileData.save();
				if(name!=data.name)
				{
					Config.curFileData.rename(name);
					MessageCenter.sendMessage(null,MessageCenter.RENAME_FILE);					
				}
			}
			this.closeHandler(null);
		}
		
		protected function closeHandler(event:CloseEvent):void
		{
			G.curScene.onStart();
			PopUpManager.removePopUp(_ref as TitleWindow);
		}
	}
}