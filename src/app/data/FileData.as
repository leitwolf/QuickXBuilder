package app.data
{
	import AirLib.Helper;
	
	import app.Config;
	
	import flash.filesystem.File;

	/**
	 * 场景文件数据,可做为控件树根结点，也可做文件列表的结点，要延迟加载
	 * 
	 * 已保存的文件结构为{type,width,height,controls:[]}
	 * controls为所包含的控件，其结构为{type,custom,children:[],x,y,anchorX,...}
	 * 一个control包含了其子组件的信息
	 * 
	 * @author lonewolf
	 * 
	 */	
	public class FileData extends NodeDataBase
	{
		//是否合法，一般是加载文件后
		private var _isValid:Boolean=false;
				
		// 类型
		private var _type:String=Config.FILE_TYPE_SCENE;
		// 文件地址
		private var _url:String;
		//不包含后缀的文件名
		private var _name:String;
		// 场景分辨率
		private var _width:Number=0;
		private var _height:Number=0;
		//是否已加载
		private var _loaded:Boolean=false;
		
		public function FileData(url:String)
		{
			_url=url;
			_name=_url.substring(_url.lastIndexOf("/")+1,_url.lastIndexOf("."));
			label=_name;
		}
		/**
		 * 这是新建的文件 
		 * 
		 */
		public function newFile():void
		{
			_isValid=true;
			_loaded=true;
			this.save();
		}
		/**
		 * 重命名 
		 * @param name
		 * 
		 */
		public function rename(name:String):void
		{
			var file:File=new File(_url);
			var newFile:File=Config.projectData.sceneFilesDirFile.resolvePath(name+"."+Config.FILE_EXT);
			file.moveTo(newFile,true);
			_name=name;
			label=name;
			try
			{
				file.deleteFile();
			}
			catch(e:Error)
			{
				
			}
		}
		/**
		 * 加载 
		 * 
		 */
		public function load():void
		{
			if(_loaded)
			{
				return;
			}
			_loaded=true;
			// 解析文件数据{width,height,controls:[]}
			try
			{
				var str:String=Helper.readData(_url);
				var obj:Object=JSON.parse(str);
				if(obj)
				{
					if(!obj.controls||!(obj.controls is Array))
					{
						return;
					}
					if(obj.type)
					{
						_type=obj.type;
					}
					_width=obj.width;
					_height=obj.height;
					//解析控件列表
					var arr:Array=obj.controls as Array;
					for each(var data:Object in arr)
					{
						var control:ControlData=new ControlData();
						control.decodeData(data);
						this.addChild(control);
					}
					_isValid=true;
				}				
			}
			catch(e:Error)
			{
				trace("load file error:("+_url+")"+e.message);
			}			
		}
		
		/**
		 * 保存到文件
		 * 
		 */
		public function save():void
		{
			if(!_isValid||!_loaded)
			{
				return;
			}
			//编码控件列表
			var arr:Array=[];
			if(this.children!=null)
			{
				for each(var controlData:ControlData in this.children)
				{
					arr.push(controlData.encodeData());
				}
			}
			var obj:Object={type:_type,width:_width,height:_height,controls:arr};
			Helper.saveData(JSON.stringify(obj),_url);
		}
		/**
		 * 删除文件 
		 * 
		 */		
		public function deleteFile():void
		{
			var file:File=new File(_url);
			try
			{
				file.deleteFile()
			}
			catch(e:Error)
			{
				trace(e.toString());
			}
			
		}
		/**
		 * 是否已经存在场景文件 
		 * @param name
		 * @return 
		 * 
		 */		
		public static function checkExist(name:String):Boolean
		{
			var file:File=Config.projectData.sceneFilesDirFile.resolvePath(name+"."+Config.FILE_EXT);
			return file.exists;
		}
		
		public function get isValid():Boolean
		{
			return _isValid;
		}

		public function get name():String
		{
			return _name;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			_width = value;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

	}
}