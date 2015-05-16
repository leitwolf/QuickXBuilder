package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.message.MessageCenter;
	import app.part.property.BasicProperty;
	import app.part.property.NodeProperty;
	import app.part.property.SpriteProperty;
	
	import flash.events.MouseEvent;
	
	import mx.controls.LinkButton;
	import mx.core.FlexGlobals;
	
	import spark.components.SkinnableContainer;

	/**
	 * 控件列表 
	 * @author lonewolf
	 * 
	 */	
	public class ControlPart
	{
		public function ControlPart()
		{
			var container:SkinnableContainer=FlexGlobals.topLevelApplication.controlContainer;
			container.setStyle("backgroundColor","0xc67f46");
			container.setStyle("backgroundAlpha","1.0");
			
			FlexGlobals.topLevelApplication.cnode.addEventListener(MouseEvent.CLICK,nodeClickHandler);
			FlexGlobals.topLevelApplication.csprite.addEventListener(MouseEvent.CLICK,spriteClickHandler);
			FlexGlobals.topLevelApplication.clayer.addEventListener(MouseEvent.CLICK,layerClickHandler);
			FlexGlobals.topLevelApplication.cbutton.addEventListener(MouseEvent.CLICK,buttonClickHandler);
		}
		/**
		 * 添加一个node 
		 * @param event
		 * 
		 */
		protected function nodeClickHandler(event:MouseEvent):void
		{
			this.createControl(Config.CONTROL_TYPE_NODE);
		}
		/**
		 * 添加Sprite 
		 * @param event
		 * 
		 */		
		protected function spriteClickHandler(event:MouseEvent):void
		{
			this.createControl(Config.CONTROL_TYPE_SPRITE);
		}
		/**
		 * 添加layer 
		 * @param event
		 * 
		 */		
		protected function layerClickHandler(event:MouseEvent):void
		{
			this.createControl(Config.CONTROL_TYPE_LAYER);
		}
		/**
		 * 添加按钮 
		 * @param event
		 * 
		 */		
		protected function buttonClickHandler(event:MouseEvent):void
		{
			this.createControl(Config.CONTROL_TYPE_BUTTON);
		}
		/**
		 * 创建控件
		 * @param type
		 * 
		 */
		private function createControl(type:String):void
		{
			if(Config.curFileData==null)
			{
				trace("no current file");
				return;
			}
			Config.newControl=new ControlData(type);
			MessageCenter.sendMessage(null,MessageCenter.NEW_CONTROL);
		}
	}
}