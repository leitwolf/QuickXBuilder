package app.data
{
	import AirLib.Helper;
	
	import app.Config;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;

	/**
	 * 资源结点数据结构，可做为树的结点
	 * 约定：图片在_demo文件夹中（以_demo起止）的为示例图片
	 * @author lonewolf
	 * 
	 */	
	public dynamic class ResourceNodeData extends NodeDataBase
	{
		//是否有效，用于加载后的验证
		private var _isValid:Boolean=false;
		
		// =====具体数据====
		// 资源类型，如果是空，且children为空，则无效
		public var type:String="";
		// 路径，相对于资源文件夹的
		public var path:String="";
		// 如果是图片，则可能是plist中的
		public var plist:String="";
		// 图片
		private var _image:DisplayObject=null;
		
		// plist小图
		private var _imageFile:File;
		private var _plistFile:File;
		private var _bigImage:DisplayObject;
		private var _plistItem:PlistItem=null;
		
		
		public function ResourceNodeData()
		{
		}
		/**
		 * 加载图片 
		 * @param file
		 * 
		 */		
		public function loadImage(file:File):void
		{
			try{
				type=Config.RESOURCE_IMAGE;
				var ba:ByteArray=new ByteArray();
				var stream:FileStream=new FileStream();
				stream.open(file,FileMode.READ);
				stream.readBytes(ba);
				var loader:Loader=new Loader();
				loader.loadBytes(ba);
				_image=loader;
				
				// 素材相对路径等
				var index:int=Config.projectData.resourceDirFile.url.length+1;
				path=file.url.substring(index);
				var dotIndex:int=path.lastIndexOf(".");
				label=file.name.substring(0,dotIndex);
				
				_isValid=true;
			}
			catch(e:Error)
			{
				trace("Load image error: ("+file.url+")"+e.toString());
			}
		}
		/**
		 * 加载文件夹 
		 * @param file
		 * 
		 */		
		public function loadDirectory(file:File):void
		{
			label=file.name;
			var arr:Array=file.getDirectoryListing();
			for each(var f:File in arr)
			{
				var node:ResourceNodeData=load(f);
				if(node.isValid)
				{
					this.addChild(node);
				}
			}
			// 当有子节点时才有效
			if(this.children&&this.children.length>0)
			{
				_isValid=true;
			}
		}
		/**
		 * 加载plist整个文件
		 * @param imageFile
		 * @param plistFile
		 * 
		 */
		public function loadPlist(imageFile:File,plistFile:File):void
		{
			_imageFile=imageFile;
			_plistFile=plistFile;
			type=Config.RESOURCE_PLIST;
			label=_plistFile.name;
			try{
				// 加载大图
				var ba:ByteArray=new ByteArray();
				var stream:FileStream=new FileStream();
				stream.open(imageFile,FileMode.READ);
				stream.readBytes(ba);
				var loader:Loader=new Loader();
//				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);				
				loader.loadBytes(ba);
				_image=loader;
				
				// 加载小图信息
				var itemList:Array=Plist.analysePlist(plistFile.url);
				for each(var item:PlistItem in itemList)
				{
					var node:ResourceNodeData=new ResourceNodeData();
					node.setPlistItem(item, _image ,_plistFile.url);
					this.addChild(node);
				}
				if(itemList.length>0)					
				{
					_isValid=true;
				}				
			}
			catch(e:Error)
			{
				trace("Load image error: ("+imageFile.url+")"+e.toString());
			}
		}
		/**
		 * 设置plist节点，延迟加载图片
		 * @param item
		 * @param bigImage
		 * @param plistUrl
		 * 
		 */
		public function setPlistItem(item:PlistItem, bigImage:DisplayObject, plistUrl:String):void
		{
			_plistItem=item;
			_bigImage=bigImage;
			
			type=Config.RESOURCE_IMAGE;
			
			path=item.name;
			var index:int=Config.projectData.resourceDirFile.url.length+1;
			plist=plistUrl.substring(index);
			
			var dotIndex:int=path.lastIndexOf(".");
			label=path.substring(0,dotIndex);
			
			_isValid=true;
		}
		/**
		 * 加载图片完成
		 * @param event
		 * 
		 */
		protected function completeHandler(event:Event):void
		{
		}
		
		/**
		 * 从文件加载
		 * @param file
		 * @return 如果不符合，则返回的node是isValid=false
		 * 
		 */
		public static function load(file:File):ResourceNodeData
		{
			var nodeData:ResourceNodeData=new ResourceNodeData();
			if(file.isDirectory)
			{
				nodeData.loadDirectory(file);
			}
			else if(file.extension=="png"||file.extension=="jpg")
			{
				// 检测是不是plist
				var index:int=file.name.lastIndexOf(".");
				var baseName:String=file.name.substring(0,index);
				var pf:File=file.parent.resolvePath(baseName+".plist");
				if(pf.exists)
				{
					// trace("plist ---- "+pf.url);
					Plist.analysePlist(pf.url);
					nodeData.loadPlist(file,pf);
				}
				else
				{
					nodeData.loadImage(file);
				}				
			}
			return nodeData;
		}

		public function get isValid():Boolean
		{
			return _isValid;
		}

		public function get image():DisplayObject
		{
			// 如果为空则先加载
			if(_image==null)
			{
				if(type==Config.RESOURCE_IMAGE&&_bigImage)
				{
					_image=Plist.extraImage(_bigImage,_plistItem);
				}
			}
			return _image;
		}

	}
}