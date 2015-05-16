package app.win
{
	import AirLib.G;
	
	import app.Config;
	import app.data.ProjectData;
	import app.message.MessageCenter;
	
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.RadioButtonGroup;
	import spark.components.TitleWindow;

	/**
	 * 建立项目
	 * @author lonewolf
	 * 
	 */	
	public class CreateProjectWin
	{
		// 是否是新项目
		public static var isNewProject:Boolean=true;
		// 项目目录地址
		public static var projectUrl:String="";
		
		private var _ref:Object;
		private var _resolution:DropDownList;
		private var _dir:RadioButtonGroup;
		
		public function CreateProjectWin(ref:Object)
		{
			_ref=ref;
			_resolution=_ref.resolution;
			_dir=_ref.radiogroup1;
			
			_resolution.dataProvider=Config.getResolutionList();
			_resolution.selectedIndex=0;
			
			if(!isNewProject)
			{
				var w:Number=Config.projectData.width;
				var h:Number=Config.projectData.height;
				if(w>h)
				{
					// 横屏
					_dir.selectedValue=2;
					w=Config.projectData.height;
					h=Config.projectData.width;
				}
				for each(var obj:Object in _resolution.dataProvider)
				{
					if(obj.width==w&&obj.height==h)
					{
						_resolution.selectedItem=obj;
						break;
					}
				}
			}
			
			// 居中
			var width:Number=FlexGlobals.topLevelApplication.width;
			var height:Number=FlexGlobals.topLevelApplication.height;
			var win:TitleWindow=ref as TitleWindow;
			if(isNewProject)
			{
				win.title="新建项目";
			}
			else
			{
				win.title="修改项目";
			}
			win.x=(width-win.width)/2;
			win.y=(height-win.height)/2;
			win.addEventListener(CloseEvent.CLOSE,closeHandler);
						
			//events
			(_ref.ok as Button).addEventListener(MouseEvent.CLICK,okHandler);
		}
		
		protected function okHandler(event:MouseEvent):void
		{
			var obj:Object=_resolution.selectedItem;
			var width:Number=obj.width;
			var height:Number=obj.height;
			if(_dir.selectedValue==2)
			{
				width=obj.height;
				height=obj.width;
			}
			if(isNewProject)
			{
				var project:ProjectData=new ProjectData();
				project.newProject(projectUrl,width,height);
				Config.projectData=project;
				MessageCenter.sendMessage(null,MessageCenter.NEW_PROJECT);
			}
			else
			{
				// 修改当前的分辨率
				Config.projectData.modify(width,height);
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