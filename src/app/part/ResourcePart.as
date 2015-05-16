package app.part
{
	import app.Config;
	import app.data.ResourceManager;
	import app.data.ResourceNodeData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.controls.Tree;
	import mx.core.FlexGlobals;
	import mx.events.ListEvent;
	
	import spark.components.Image;

	/**
	 * 资源树列表 
	 * @author lonewolf
	 * 
	 */	
	public class ResourcePart extends Messager
	{
		private var _tree:Tree;
		// 预览图像
		private var _preview:Image;
		
		public function ResourcePart()
		{
			_tree=FlexGlobals.topLevelApplication.res;
			_preview=FlexGlobals.topLevelApplication.preview;			
			_preview.smooth=true;
			
			_tree.addEventListener(ListEvent.CHANGE,treeChangeHandler);
			FlexGlobals.topLevelApplication.refreshRes.addEventListener(MouseEvent.CLICK,refreshResHandler);
		}
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.NEW_PROJECT)
			{
				// 新项目，加载新资源
				this.loadResources();
			}
		}
		/**
		 * 加载资源 
		 * 
		 */
		private function loadResources():void
		{
			Config.resourceManager.load();
			_tree.dataProvider=Config.resourceManager.data;
			_tree.validateNow();
			_tree.expandChildrenOf(Config.resourceManager.data,true);
		}
		/**
		 *  刷新资源 
		 * @param event
		 * 
		 */		
		protected function refreshResHandler(event:MouseEvent):void
		{
			this.loadResources();
		}
		/**
		 * 点击树节点显示预览图
		 * @param event
		 * 
		 */
		protected function treeChangeHandler(event:ListEvent):void
		{
			var node:ResourceNodeData=_tree.selectedItem as ResourceNodeData;
			if(node.type==Config.RESOURCE_IMAGE||node.type==Config.RESOURCE_PLIST)
			{
				_preview.source=node.image;
				var width:Number=240;
				var height:Number=90;
				var scale1:Number=width/node.image.width;
				var scale2:Number=height/node.image.height;
				var scale:Number=scale1<scale2?scale1:scale2;
				if(scale>1)
				{
					scale=1;
				}
				_preview.scaleX=_preview.scaleY=scale;
			}
			else
			{
				_preview.source=null;
			}
		}
	}
}