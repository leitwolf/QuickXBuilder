package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.message.MessageCenter;
	import app.message.Messager;
	import app.part.property.BasicProperty;
	import app.part.property.ButtonProperty;
	import app.part.property.LayerProperty;
	import app.part.property.NodeProperty;
	import app.part.property.PropertyBase;
	import app.part.property.SpriteProperty;

	public class PropertyPart extends Messager
	{
		//各个组件
		private var _basicProperty:BasicProperty;
		private var _nodeProperty:NodeProperty;
		private var _spriteProperty:SpriteProperty;
		private var _layerProperty:LayerProperty;
		private var _buttonProperty:ButtonProperty;
		
		// 当前控件数据
		private var _curControlData:ControlData=null;
		
		public function PropertyPart()
		{
			_basicProperty=new BasicProperty();
			_nodeProperty=new NodeProperty();
			_spriteProperty=new SpriteProperty();
			_layerProperty=new LayerProperty();
			_buttonProperty=new ButtonProperty();
			
			// 注册
			MessageCenter.registerMessager(_basicProperty);
			MessageCenter.registerMessager(_nodeProperty);
			MessageCenter.registerMessager(_spriteProperty);
			MessageCenter.registerMessager(_layerProperty);
			MessageCenter.registerMessager(_buttonProperty);			
		}
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.CURRENT_CONTROL)
			{
				// 当前控件改变
				if(Config.curControl==null)
				{
					_basicProperty.bindData(null);
					_nodeProperty.bindData(null);
					_spriteProperty.bindData(null);
					_layerProperty.bindData(null);
					_buttonProperty.bindData(null);
				}
				else
				{
					_basicProperty.bindData(Config.curControl.basicData);
					_nodeProperty.bindData(Config.curControl.nodeData);
					_spriteProperty.bindData(Config.curControl.spriteData);
					_layerProperty.bindData(Config.curControl.layerData);
					_buttonProperty.bindData(Config.curControl.buttonData);
				}
			}
		}

	}
}