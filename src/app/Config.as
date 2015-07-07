package app
{
	import AirLib.Helper;
	
	import app.data.ConfigData;
	import app.data.ControlData;
	import app.data.FileData;
	import app.data.LuaFile;
	import app.data.ProjectData;
	import app.data.ResourceManager;
	import app.data.Size;
	import app.part.ControlPart;
	import app.part.ControlViewPart;
	import app.part.ProjectViewPart;
	import app.part.PropertyPart;
	import app.part.ResourcePart;
	import app.part.ToolbarPart;
	import app.part.WorkAreaPart;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.messaging.channels.StreamingAMFChannel;

	/**
	 * 配置文件
	 * --定义各种枚举类型
	 * --定义系统常量
	 * --储存系统变量
	 * --定义常用方法
	 * @author lonewolf
	 * 
	 */	
	public class Config
	{
		/**
		 * 场景与自定义控件的主要区别：
		 * 它们的主要区别在于导出lua文件时，如果ui文件的分辨率与项目的分辨率不一样，则被认为是自定义控件，
		 * 其内部控件如果用相对坐标，在计算实际坐标时，则是相对于ui文件的分辨率，场景的则是相对于实际的设备分辨率
		 */	
		
		// 嵌入资源--缺失素材的替换符
		[Embed(source="../assets/missing-texture.png")]
		public static var missingImage:Class;
		
		// lua文件模板
		[Embed(source="../assets/Node.lua", mimeType = "application/octet-stream")]
		private static var nodeClass:Class;
		[Embed(source="../assets/Scene.lua", mimeType = "application/octet-stream")]
		private static var sceneClass:Class;
		
		
		// ====enum 类型定义	====
		// 文件类型，场景或自定义控件
		public static const FILE_TYPE_SCENE:String="scene";
		public static const FILE_TYPE_CUSTOM_CONTROL:String="custom_control";
		
		// 控件类型
		public static const CONTROL_TYPE_NODE:String="node";
		public static const CONTROL_TYPE_SPRITE:String="sprite";
		public static const CONTROL_TYPE_LAYER:String="layer";
		public static const CONTROL_TYPE_BUTTON:String="button";
		
		// 位置
		public static const LOCATION_LEFT:String="left";
		public static const LOCATION_CENTER:String="center";
		public static const LOCATION_RIGHT:String="right";
		public static const LOCATION_TOP:String="top";
		public static const LOCATION_BOTTOM:String="bottom";
		
		// 资源类型
		public static const RESOURCE_IMAGE:String="image";
		public static const RESOURCE_PLIST:String="plist";
		public static const RESOURCE_SOUND:String="sound";
		
		// ===所有保存的文件都是json格式===
		// 系统配置文件，保存最近文件列表和自定义分辨率
		public static const SYSTEM_CONFIG_FILENAME:String="sys.txt";
		// 项目文件存放名称（里面有当前项目的分辨率），放在 _ui 里
		public static const PROJECT_CONFIG_FILENAME:String="project.conf";
		// 场景文件存放地址
		public static const UI_DIRECTORY:String="ui_";
		// 资源文件存放地址
		public static const RESOURCE_DIRECTORY:String="res";
		// 资源文件存放地址
		public static const LUA_DIRECTORY:String="src/app/ui";
		// 场景文件扩展名
		public static const FILE_EXT:String="qui";
		
		// 前一次打开的文件夹，主要用于连续打开目录
		public static var prevFileUrl:String="";
		
		// 界面上的各个组件
		public static var mainScene:MainScene;
		public static var toolbarPart:ToolbarPart;
		public static var propertyPart:PropertyPart;
		public static var resourcePart:ResourcePart;
		public static var projectViewPart:ProjectViewPart;
		public static var controlViewPart:ControlViewPart;
		public static var controlPart:ControlPart;
		public static var workAreaPart:WorkAreaPart;
		
		// 资源管理器
		public static var resourceManager:ResourceManager=new ResourceManager();
		
		// 系统配置
		public static var configData:ConfigData=new ConfigData();
		// 项目数据信息
		public static var projectData:ProjectData=null;
		// 项目场景文件列表 [fileData]
		public static var fileDataList:Array=[];
		// 场景缩放列表(预定)
		public static const zoomList:Array=[15,30,50,75,100,150,200];
		// 当前文件
		public static var curFileData:FileData=null;
		// 当前控件
		public static var curControl:ControlData=null;
		// 场景缩放比率
		public static var sceneZoom:Number=100;
		// 是否可拖动场景
		public static var enableDragScene:Boolean=false;
		// 当前分辨率，与toolbar保持一致
		public static var resolution:Size=new Size();
		// 刚刚建好的控件
		public static var newControl:ControlData=null;
		
		public function Config()
		{
		}
		/**
		 * 初始化 
		 * 
		 */
		public static function init():void
		{
			Config.configData.load();
		}
		/**
		 * 获取lua模板字符串 
		 * @param type Node or Scene
		 * @return 
		 * 
		 */		
		public static function getLuaTemplate(type:String):String
		{
			var ba:ByteArray;
			if(type=="Node")
			{
				ba=new nodeClass() as ByteArray;
			}
			else
			{
				ba=new sceneClass() as ByteArray;
			}
			return ba.readMultiByte(ba.length,"utf8");
		}
		/**
		 * 分辨率列表，供组件中使用
		 * @return 
		 * 
		 */
		public static function getResolutionList():ArrayCollection
		{
			var arr:ArrayCollection=new ArrayCollection();			
			arr.addItem({label:"iPhone 4(640x960)",width:640,height:960});
			arr.addItem({label:"iPhone 5(640x1136)",width:640,height:1136});
			arr.addItem({label:"iPad(768x1024)",width:768,height:1024});
			arr.addItem({label:"iPad Retina(1536x2048)",width:1536,height:2048});
			arr.addItem({label:"Andriod(720x1280)",width:720,height:1280});
			arr.addItem({label:"Andriod(1080x1920)",width:1080,height:1920});
			
			// 加上自定义的
			for each(var obj:Object in Config.configData.customResolutionList)
			{
				var width:Number=obj.width;
				var height:Number=obj.height;
				var data:Object={label:width+" * "+height,width:width,height:height};
				arr.addItem(data);
			}
			return arr;
		}
		/**
		 * 建立新的文件 
		 * @param name
		 * @return 
		 * 
		 */
		public static function newFile(name:String):FileData
		{
			//保存一个空的场景文件
			var file:File=Config.projectData.sceneFilesDirFile.resolvePath(name+"."+Config.FILE_EXT);
			var data:FileData=new FileData(file.url);
			data.width=Config.projectData.width;
			data.height=Config.projectData.height;
			data.newFile();
			return data;
		}
		
		/**
		 * 获取最近的项目列表
		 * 返回 [{label:name,data:url}]
		 * @return 
		 * 
		 */
		public static function getRecentProjectList():ArrayCollection
		{
			var arr:ArrayCollection=new ArrayCollection();
			for each(var url:String in Config.configData.recentProjectList)
			{
				var f:File=new File(url);
				if(f.exists)
				{
					var name:String=f.name;
					arr.addItem({label:name,data:url});
				}				
			}
			if(arr.length>0)
			{
				arr.addItem({label:"删除最近列表",data:null});
			}
			return arr;
		}
		/**
		 * 导出lua代码 
		 * 
		 */
		public static function generateLua():void
		{
			for each(var data:FileData in Config.fileDataList)
			{
				Config.generateLuaFile(data);
			}
		}
		/**
		 * 生成一个lua文件 
		 * @param data
		 * 
		 */		
		private static function generateLuaFile(data:FileData):void
		{
			data.load();
			var lua:LuaFile=new LuaFile(data);
			var file:File=Config.projectData.luaFilesDirFile.resolvePath(data.name+".lua");
			Helper.saveData(lua.luaData,file.url);			
		}
		/**
		 * 打开一个文件，并返回File对象 
		 * @param defaultUrl
		 * @return 
		 * 
		 */		
		public static function getOpenFile(defaultUrl:String="documents"):File
		{
			var file:File=null;
			if(prevFileUrl!="")
			{
				file=new File(prevFileUrl);
			}
			else
			{
				if(defaultUrl=="documents")
				{
					file=File.documentsDirectory;
				}
				else
				{
					file=new File(defaultUrl);
				}
			}
			file.addEventListener(Event.SELECT,fileSelectHandler);
			return file;
		}
		
		protected static function fileSelectHandler(event:Event):void
		{
			prevFileUrl=(event.currentTarget as File).url;
		}
	}
}