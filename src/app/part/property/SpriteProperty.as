package app.part.property
{
	import app.Config;
	import app.data.property.SpritePropertyData;
	import app.message.MessageCenter;
	
	import flash.events.Event;

	public class SpriteProperty extends PropertyBase
	{
		private var _data:SpritePropertyData;
		private var _property:CSprite;
		
		private var _image:DropImage;
		
		public function SpriteProperty()
		{
			super("Sprite");
			_property=new CSprite();
			_content=_property;
			
			_image=new DropImage(_property.image);
			_image.addEventListener(Event.CHANGE,imageChangeHandler);
			
			_property.image.source=Config.missingImage;
		}
		/**
		 * 图片改变 
		 * @param event
		 * 
		 */
		protected function imageChangeHandler(event:Event):void
		{
			var image:DropImage=event.currentTarget as DropImage;
			_data.image=image.imagePath;
			_data.imagePlist=image.plist;
			this.sendMessage(MessageCenter.CONTROL_IMAGE);
			this.sendMessage(MessageCenter.FILE_DIRTY);
		}
		/**
		 * 绑定数据 
		 * @param data
		 * 
		 */		
		public function bindData(data:SpritePropertyData):void
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
			this.setImage(_image.image,data.image,data.imagePlist);
		}
	}
}