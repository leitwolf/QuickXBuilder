package app.part.property
{
	import app.Config;
	import app.data.property.ButtonPropertyData;
	import app.message.MessageCenter;
	
	import flash.events.Event;
	
	import spark.components.Image;
	import spark.components.TextInput;

	public class ButtonProperty extends PropertyBase
	{		
		private var _data:ButtonPropertyData;
		private var _property:CButton;
		
		private var _normal:DropImage;
		private var _pressed:DropImage;
		private var _disabled:DropImage;
		
		public function ButtonProperty()
		{
			super("Button");
			_property=new CButton();
			_content=_property;
			
			_normal=new DropImage(_property.normal);
			_pressed=new DropImage(_property.pressed);
			_disabled=new DropImage(_property.disabled);
			
			_property.normal.source=Config.missingImage;
			_property.pressed.source=Config.missingImage;
			_property.disabled.source=Config.missingImage;
			
			_normal.addEventListener(Event.CHANGE,imageChangeHandler);
			_pressed.addEventListener(Event.CHANGE,imageChangeHandler);
			_disabled.addEventListener(Event.CHANGE,imageChangeHandler);
		}
		/**
		 * 图片改变 
		 * @param event
		 * 
		 */
		protected function imageChangeHandler(event:Event):void
		{
			var image:DropImage=event.currentTarget as DropImage;
			if(image==_normal)
			{
				_data.normal=image.imagePath;
				_data.normalPlist=image.plist;
				this.sendMessage(MessageCenter.CONTROL_IMAGE);
			}
			else if(image==_pressed)
			{
				_data.pressed=image.imagePath;
				_data.pressedPlist=image.plist;
			}
			else if(image==_disabled)
			{
				_data.disabled=image.imagePath;
				_data.disabledPlist=image.plist;
			}
			this.sendMessage(MessageCenter.FILE_DIRTY);
		}
		/**
		 * 绑定数据 
		 * @param data
		 * 
		 */		
		public function bindData(data:ButtonPropertyData):void
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
			this.setImage(_normal.image,data.normal,data.normalPlist);
			this.setImage(_pressed.image,data.pressed,data.pressedPlist);
			this.setImage(_disabled.image,data.disabled,data.disabledPlist);
		}
	}
}