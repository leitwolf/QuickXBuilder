package app.part.property
{
	import app.Config;
	import app.data.property.BasicPropertyData;
	import app.message.MessageCenter;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.TextInput;

	public class BasicProperty extends PropertyBase
	{
		private var _data:BasicPropertyData;
		private var _property:CBasic;
		
		public function BasicProperty()
		{
			super("Basic");
			_property=new CBasic();
			_content=_property;
			
			//addEvent
			this.addEvent(_property.bindName);
		}
		/**
		 * 绑定数据 
		 * @param data
		 * 
		 */		
		public function bindData(data:BasicPropertyData):void
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
			_property.bindName.text=data.name;
			_property.type.text=data.type;
		}
		/**
		 * 值改变 
		 * @param ui
		 * 
		 */		
		override protected function valueChanged(ui:UIComponent):void
		{
			if(ui==_property.bindName)
			{
				_data.name=_property.bindName.text;
				// 显示的名字也改变
				Config.curControl.resetLabel();
				this.sendMessage(MessageCenter.CONTROL_NAME);
				this.sendMessage(MessageCenter.FILE_DIRTY);
				
			}
		}
		
	}
}