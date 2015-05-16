package app.win
{
	import AirLib.G;
	
	import app.Config;
	import app.data.ProjectData;
	import app.message.MessageCenter;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.List;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.components.TitleWindow;

	/**
	 * 自定义分辨率管理
	 * @author lonewolf
	 * 
	 */	
	public class CustomResolutionWin
	{
		// 是否是新项目
		public static var isNewProject:Boolean=true;
		// 项目目录地址
		public static var projectUrl:String="";
		
		private var _ref:Object;
		private var _list:List;
		private var _widthText:TextInput;
		private var _heightText:TextInput;
		
		public function CustomResolutionWin(ref:Object)
		{
			_ref=ref;
			_list=_ref.list;
			_widthText=_ref.width1;
			_heightText=_ref.height1;
			
			var arr:ArrayCollection=new ArrayCollection();
			for each(var obj:Object in Config.configData.customResolutionList)
			{
				arr.addItem({label:obj.width+" * "+obj.height, width:obj.width, height:obj.height});
			}
			_list.dataProvider=arr;
			
			// 居中
			var width:Number=FlexGlobals.topLevelApplication.width;
			var height:Number=FlexGlobals.topLevelApplication.height;
			var win:TitleWindow=ref as TitleWindow;
			win.title="自定义分辨率管理";
			win.x=(width-win.width)/2;
			win.y=(height-win.height)/2;
			win.addEventListener(CloseEvent.CLOSE,closeHandler);
						
			//events
			(_ref.add as Button).addEventListener(MouseEvent.CLICK,addHandler);
			(_ref.remove as Button).addEventListener(MouseEvent.CLICK,removeHandler);
			(_ref.ok as Button).addEventListener(MouseEvent.CLICK,okHandler);
		}
		/**
		 * 添加分辨率 
		 * @param event
		 * 
		 */		
		protected function addHandler(event:MouseEvent):void
		{
			var width:Number=Number(_widthText.text);
			var height:Number=Number(_heightText.text);
			if(width<=0||height<=0)
			{
				return;
			}
			if(width>=height)
			{
				Alert.show("宽要小于高 width<height");
				return;
			}
			var arr:ArrayCollection=_list.dataProvider as ArrayCollection;
			// 是否已经定义了
			for each(var obj:Object in arr)
			{
				if(obj.width==width&&obj.height==height)
				{
					return;
				}
			}
			arr.addItem({label:width+" * "+height, width:width, height:height});
			_list.invalidateDisplayList();
		}
		/**
		 * 删除选中的分辨率 
		 * @param event
		 * 
		 */
		protected function removeHandler(event:MouseEvent):void
		{
			if(_list.selectedIndex==-1)
			{
				return;
			}
			var arr:ArrayCollection=_list.dataProvider as ArrayCollection;
			arr.removeItemAt(_list.selectedIndex);
			_list.invalidateDisplayList();
		}
		
		protected function okHandler(event:MouseEvent):void
		{
			var arr:Array=[];
			for each(var obj:Object in _list.dataProvider)
			{
				arr.push({width:obj.width, height:obj.height});
			}
			Config.configData.setCustomResolution(arr);
			MessageCenter.sendMessage(null,MessageCenter.CUSTOM_RESOLUTION);
			this.closeHandler(null);
		}
		
		protected function closeHandler(event:CloseEvent):void
		{
			G.curScene.onStart();
			PopUpManager.removePopUp(_ref as TitleWindow);
		}
	}
}