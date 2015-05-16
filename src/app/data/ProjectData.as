package app.data
{
	import AirLib.Helper;
	
	import app.Config;
	
	import flash.filesystem.File;

	/**
	 * 项目数据
	 * --名称
	 * --项目目录地址
	 * --素材目录
	 * --场景文件保存目录
	 * --当前项目所用分辨率
	 * --项目信息保存格式 {width,height}
	 * 
	 * @author lonewolf
	 * 
	 */	
	public class ProjectData
	{
		// 是否有效，只有设置了项目了才有效
		private var _isValid:Boolean=false;
		
		// 项目分辨率
		private var _width:Number;
		private var _height:Number;
		// 项目地址
		private var _projectDirFile:File=null;
		private var _resourceDirFile:File=null;
		private var _sceneFilesDirFile:File=null;
		// lua文件生成地址
		private var _luaFilesDirFile:File=null;
		
		public function ProjectData()
		{
		}
		/**
		 *  加载项目信息 
		 * @param url
		 * 
		 */		
		public function load(url:String):void
		{
			var file:File=new File(url);
			if(file.exists&&file.isDirectory)
			{
				_projectDirFile=file;
				_resourceDirFile=file.resolvePath(Config.RESOURCE_DIRECTORY);
				_sceneFilesDirFile=file.resolvePath(Config.UI_DIRECTORY);
				_luaFilesDirFile=file.resolvePath(Config.LUA_DIRECTORY);
				
				// 加载项目文件
				var f:File=_sceneFilesDirFile.resolvePath(Config.PROJECT_CONFIG_FILENAME);
				if(f.exists)
				{
					var data:String=Helper.readData(f.url);
					var json:Object=JSON.parse(data);
					if(json.width&&json.height)
					{
						_width=json.width;
						_height=json.height;
						_isValid=true;
					}
				}
			}
		}
		/**
		 * 新项目 
		 * @param url
		 * @param width
		 * @param height
		 * 
		 */
		public function newProject(url:String,width:Number,height:Number):void
		{
			var file:File=new File(url);
			_projectDirFile=file;
			_resourceDirFile=file.resolvePath(Config.RESOURCE_DIRECTORY);
			_sceneFilesDirFile=file.resolvePath(Config.UI_DIRECTORY);
			_luaFilesDirFile=file.resolvePath(Config.LUA_DIRECTORY);
			_width=width;
			_height=height;
			_isValid=true;
			this.save();
			// 添加到最近列表
			Config.configData.addRecentProject(url);
		}
		/**
		 * 修改项目信息 
		 * @param width
		 * @param height
		 * 
		 */		
		public function modify(width:Number,height:Number):void
		{
			_width=width;
			_height=height;
			this.save();			
		}
		/**
		 * 保存项目信息 
		 * 
		 */
		public function save():void
		{
			if(!_isValid)
			{
				return;
			}
			var f:File=_sceneFilesDirFile.resolvePath(Config.PROJECT_CONFIG_FILENAME);
			var obj:Object={width:_width,height:_height};
			var data:String=JSON.stringify(obj);
			Helper.saveData(data,f.url);
		}

		public function get isValid():Boolean
		{
			return _isValid;
		}

		public function get width():Number
		{
			return _width;
		}

		public function get height():Number
		{
			return _height;
		}

		public function get projectDirFile():File
		{
			return _projectDirFile;
		}

		public function get resourceDirFile():File
		{
			return _resourceDirFile;
		}

		public function get sceneFilesDirFile():File
		{
			return _sceneFilesDirFile;
		}

		public function get luaFilesDirFile():File
		{
			return _luaFilesDirFile;
		}


	}
}