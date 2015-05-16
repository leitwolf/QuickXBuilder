package app.part.property
{
	import app.Config;
	import app.data.property.PropertyDataBase;
	import app.message.Messager;
	import app.part.ControlPart;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ColorPicker;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.ColorPickerEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;

	/**
	 * 所有属性的基类 
	 * @author lonewolf
	 * 
	 */	
	public class PropertyBase extends Messager
	{
		
		protected var _container:Group;
		// 控制界面的开关按钮
		protected var _button:Button;
		// 当前属性的界面
		protected var _content:Group=null;
		
		protected var _baseData:PropertyDataBase=null;
		
		public function PropertyBase(name:String)
		{
			_button=new Button();
			_button.label=name;
			_button.percentWidth=100;
			_button.addEventListener(MouseEvent.CLICK,clickHandler);
			
			_container=FlexGlobals.topLevelApplication.propertyContainer;
		}
		/**
		 * 设置图片源，如果源不存在则使用默认的 
		 * @param image
		 * @param path
		 * @param plist
		 * 
		 */		
		protected function setImage(image:Image,path:String,plist:String):void
		{
			var source:Object=Config.missingImage;
			if(path!="")
			{
				var image1:DisplayObject=Config.resourceManager.findImage(path,plist);
				if(image1!=null)
				{
					source=image1;
				}
			}
			image.source=source;
			//提供
			var tip:String="";
			if(plist)
			{
				tip+=plist+"/"
			}
			tip+=path;
			image.toolTip=tip;
		}
		/**
		 * 下拉选择 
		 * @param downlist
		 * @param data string或Object
		 * 
		 */
		protected function downlistSelect(downlist:DropDownList,data:Object):void
		{
			var arr:ArrayCollection=downlist.dataProvider as ArrayCollection;
			for each(var obj:Object in arr)
			{
				if(data is String)
				{					
					if(obj.data==data)
					{
						downlist.selectedItem=obj;
						return;
					}
				}
				else
				{
					//object类型，要一个一个的检测
					var valid:Boolean=true;
					for(var k:String in data)
					{
						if(obj[k]!=data[k])
						{
							valid=false;
							break;
						}
					}
					if(valid)
					{
						downlist.selectedItem=obj;
						return;						
					}
				}
			}
		}
		/**
		 * 显示/隐藏 界面 
		 * @param event
		 * 
		 */		
		protected function clickHandler(event:MouseEvent):void
		{
			if(_content.parent)
			{
				_container.removeElement(_content);
			}
			else
			{
				//放在button的后面
				_container.addElementAt(_content,_container.getElementIndex(_button)+1);
			}
		}
		/**
		 * 检测是否要显示 
		 * 
		 */		
		public function checkVisible():void
		{
			var visible:Boolean=false;
			if(_baseData&&_baseData.isUse)
			{
				visible=true;
			}
			if(visible)
			{
				_container.addElement(_button);
				_container.addElement(_content);
			}
			else
			{
				// 从容器中删除
				if(_button.parent)
				{
					_container.removeElement(_button);
				}
				if(_content.parent)
				{
					_container.removeElement(_content);
				}
			}
		}
		
		/**
		 * 为ui添加事件，具体的事件处理要自己处理 
		 * @param ui
		 * 
		 */		
		protected function addEvent(ui:UIComponent):void
		{			
			if(ui is TextInput)
			{
				(ui as TextInput).addEventListener(FlexEvent.ENTER,valueChangeHandler);	
			}
			else if(ui is DropDownList)
			{
				(ui as DropDownList).addEventListener(IndexChangeEvent.CHANGE,valueChangeHandler);
			}
			else if(ui is CheckBox)
			{
				(ui as CheckBox).addEventListener(Event.CHANGE,valueChangeHandler);
			}
			else if(ui is ColorPicker)
			{
				(ui as ColorPicker).addEventListener(ColorPickerEvent.CHANGE,valueChangeHandler);
			}
		}
		/**
		 * 控件值改变 
		 * @param event
		 * 
		 */
		private function valueChangeHandler(event:Event):void
		{
			this.valueChanged(event.currentTarget as UIComponent);
		}
		/**
		 * 值改变,在子类处理
		 * @param textInput
		 * 
		 */
		protected function valueChanged(ui:UIComponent):void
		{			
		}
	}
}