package app.part.property
{
	import app.data.property.LayerPropertyData;
	import app.message.MessageCenter;
	
	import mx.core.UIComponent;
	
	import spark.components.CheckBox;

	public class LayerProperty extends PropertyBase
	{
		private var _data:LayerPropertyData;
		private var _property:CLayer;
		
		public function LayerProperty()
		{
			super("Layer");
			_property=new CLayer();
			_content=_property;
			
			//addEvent
			this.addEvent(_property.color);
			this.addEvent(_property.transparent);
		}
		/**
		 * 绑定数据 
		 * @param data
		 * 
		 */		
		public function bindData(data:LayerPropertyData):void
		{
			_data=data;
			_baseData=data;
			//检测是否可见
			this.checkVisible();
			this.checkLock();
			
			if(data==null)
			{
				return;
			}
			//设置值
			_property.color.selectedColor=data.color;
			_property.transparent.text=data.alpha+"";
		}
		/**
		 * 值改变 
		 * @param ui
		 * 
		 */		
		override protected function valueChanged(ui:UIComponent):void
		{
			if(ui==_property.color)
			{
				_data.color=_property.color.selectedColor;
				this.sendMessage(MessageCenter.CONTROL_COLOR);
				this.sendMessage(MessageCenter.FILE_DIRTY);
			}
			else if(ui==_property.transparent)
			{
				_data.alpha=Number(_property.transparent.text);
				this.sendMessage(MessageCenter.CONTROL_COLOR);
				this.sendMessage(MessageCenter.FILE_DIRTY);
			}
		}
	}
}