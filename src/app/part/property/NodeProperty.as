package app.part.property
{
	import app.Config;
	import app.data.property.NodePropertyData;
	import app.message.MessageCenter;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;

	public class NodeProperty extends PropertyBase
	{
		private var _data:NodePropertyData;
		private var _property:CNode;
		
		private var _posX:TextInput;
		private var _posY:TextInput;
		private var _posXAlign:DropDownList;
		private var _posYAlign:DropDownList;
		private var _anchorX:TextInput;
		private var _anchorY:TextInput;
		private var _anchorType:DropDownList;
		private var _tag:TextInput;
		private var _isVisible:CheckBox;
		
		public function NodeProperty()
		{
			super("Node");
			_property=new CNode();
			_content=_property;
			
			_posX=_property.posX;
			_posXAlign=_property.posXAlign;
			_posY=_property.posY;
			_posYAlign=_property.posYAlign;
			_anchorX=_property.anchorX;
			_anchorY=_property.anchorY;
			_anchorType=_property.anchorType;
			_tag=_property.tag;
			_isVisible=_property.isVisible;				
			
			//锚点
			var arr:ArrayCollection=new ArrayCollection();
			arr.addItem({label:"",data:"",x:-1,y:-1});
			arr.addItem({label:"CENTER",data:"CENTER",x:0.5,y:0.5});
			arr.addItem({label:"LEFT_TOP",data:"LEFT_TOP",x:0,y:1});
			arr.addItem({label:"CENTER_TOP",data:"CENTER_TOP",x:0.5,y:1});
			arr.addItem({label:"RIGHT_TOP",data:"RIGHT_TOP",x:1,y:1});
			arr.addItem({label:"LEFT_CENTER",data:"LEFT_CENTER",x:0,y:0.5});
			arr.addItem({label:"RIGHT_CENTER",data:"RIGHT_CENTER",x:1,y:0.5});
			arr.addItem({label:"LEFT_BOTTOM",data:"LEFT_BOTTOM",x:0,y:0});
			arr.addItem({label:"RIGHT_BOTTOM",data:"RIGHT_BOTTOM",x:1,y:0});
			arr.addItem({label:"CENTER_BOTTOM",data:"CENTER_BOTTOM",x:0.5,y:0});
			_anchorType.labelField="label";
			_anchorType.dataProvider=arr;
			_anchorType.selectedIndex=0;
			
			//位置
			arr=new ArrayCollection();
			arr.addItem({label:Config.LOCATION_LEFT,data:Config.LOCATION_LEFT});
			arr.addItem({label:Config.LOCATION_CENTER,data:Config.LOCATION_CENTER});
			arr.addItem({label:Config.LOCATION_RIGHT,data:Config.LOCATION_RIGHT});
			_posXAlign.labelField="label";
			_posXAlign.dataProvider=arr;
			_posXAlign.selectedIndex=0;
			
			arr=new ArrayCollection();
			arr.addItem({label:Config.LOCATION_TOP,data:Config.LOCATION_TOP});
			arr.addItem({label:Config.LOCATION_CENTER,data:Config.LOCATION_CENTER});
			arr.addItem({label:Config.LOCATION_BOTTOM,data:Config.LOCATION_BOTTOM});
			_posYAlign.labelField="label";
			_posYAlign.dataProvider=arr;
			_posYAlign.selectedIndex=2;
			
			//addEvent
			this.addEvent(_posX);
			this.addEvent(_posXAlign);
			this.addEvent(_posY);
			this.addEvent(_posYAlign);
			this.addEvent(_anchorType);
			this.addEvent(_anchorX);
			this.addEvent(_anchorY);
			this.addEvent(_tag);
			this.addEvent(_isVisible);
			
		}
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.CONTROL_POSITION)
			{
				// 当前控件位置改变
				_posX.text=_data.x+"";
				_posY.text=_data.y+"";
			}
		}
		/**
		 * 绑定数据 
		 * @param data
		 * 
		 */		
		public function bindData(data:NodePropertyData):void
		{
			_data=data;
			_baseData=data;
			//检测是否可见
			this.checkVisible();
			
			if(data==null)
			{
				return;
			}
			
			//设置值
			_posX.text=data.x+"";
			_posY.text=data.y+"";
			this.downlistSelect(_posXAlign,data.xAlign);
			this.downlistSelect(_posYAlign,data.yAlign);
			_anchorX.text=data.anchorX+"";
			_anchorY.text=data.anchorY+"";
			_anchorType.selectedIndex=0;
			this.downlistSelect(_anchorType,{x:data.anchorX,y:data.anchorY});
			_tag.text=data.tag+"";
			_isVisible.selected=data.visible;
		}
		/**
		 * 值改变 
		 * @param ui
		 * 
		 */		
		override protected function valueChanged(ui:UIComponent):void
		{
			if(ui==_posX||ui==_posY)
			{
				_data.x=Number(_posX.text);
				_data.y=Number(_posY.text);
				this.sendMessage(MessageCenter.CONTROL_POSITION);
			}
			else if(ui==_posXAlign)
			{
				_data.xAlign=_posXAlign.selectedItem.data;
				this.sendMessage(MessageCenter.CONTROL_POSITION);
			}
			else if(ui==_posYAlign)
			{
				_data.yAlign=_posYAlign.selectedItem.data;
				this.sendMessage(MessageCenter.CONTROL_POSITION);
			}
			else if(ui==_anchorX||ui==_anchorY)
			{
				_data.anchorX=Number(_anchorX.text);
				_data.anchorY=Number(_anchorY.text);
				//引起 anchorType 变化
				_anchorType.selectedIndex=0;
				this.downlistSelect(_anchorType,{x:_data.anchorX,y:_data.anchorY});
				this.sendMessage(MessageCenter.CONTROL_ANCHOR);
			}
			else if(ui==_anchorType)
			{
				//引起 anchorX 和 anchorY 变化
				var obj:Object=_anchorType.selectedItem as Object;
				_data.anchorX=obj.x;
				_data.anchorY=obj.y;
				_anchorX.text=obj.x;
				_anchorY.text=obj.y;
				this.sendMessage(MessageCenter.CONTROL_ANCHOR);
			}
			else if(ui==_tag)
			{
				_data.tag=int(_tag.text);
			}
			else if(ui==_isVisible)
			{
				_data.visible=_isVisible.selected;
				this.sendMessage(MessageCenter.CONTROL_VISIBLE);
			}
			this.sendMessage(MessageCenter.FILE_DIRTY);
		}
		
	}
}