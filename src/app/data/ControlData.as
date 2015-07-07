package app.data
{
	import app.Config;
	import app.data.property.BasicPropertyData;
	import app.data.property.ButtonPropertyData;
	import app.data.property.LayerPropertyData;
	import app.data.property.NodePropertyData;
	import app.data.property.SpritePropertyData;

	/**
	 * 控件数据，即树结点
	 * 里面包含了所有的属性数据
	 * 该类包含了 json数据<->内部数据 的双向转换方法
	 * 
	 * @author lonewolf
	 * 
	 */	
	public class ControlData extends NodeDataBase
	{
		// 控件类型
		private var _type:String;
		// 自定义的其它场景(只是文件名，不包含后缀)，为空则不是自定义
		private var _custom:String="";
		// 是否锁定，锁住位置
		private var _locked:Boolean=false;
		
		private var _basicData:BasicPropertyData=new BasicPropertyData();
		private var _nodeData:NodePropertyData=new NodePropertyData();
		private var _spriteData:SpritePropertyData=new SpritePropertyData();
		private var _layerData:LayerPropertyData=new LayerPropertyData();
		private var _buttonData:ButtonPropertyData=new ButtonPropertyData();
		
		public function ControlData(type:String="")
		{
			_type=type;
			this.resetLabel();
			if(type==Config.CONTROL_TYPE_NODE)
			{
				_basicData.isUse=true;
				_nodeData.isUse=true;
			}
			else if(type==Config.CONTROL_TYPE_SPRITE)
			{
				_basicData.isUse=true;
				_nodeData.isUse=true;
				_spriteData.isUse=true;
			}
			else if(type==Config.CONTROL_TYPE_LAYER)
			{
				_basicData.isUse=true;
				_nodeData.isUse=true;
				_layerData.isUse=true;
			}
			else if(type==Config.CONTROL_TYPE_BUTTON)
			{
				_basicData.isUse=true;
				_nodeData.isUse=true;
				_buttonData.isUse=true;
			}
		}
		/**
		 * 锁定/解锁控件 
		 * 
		 */		
		public function toggleLock():void
		{
			_locked=!_locked;
			this.resetLabel();
		}
		/**
		 * 设置标签名
		 * 
		 */		
		public function resetLabel():void
		{
			if(_basicData.name!="")
			{
				label=_basicData.name;
			}
			else if(_custom!="")
			{
				label=_custom;
			}
			else
			{
				label=this.getUpperFirst(_type);
			}
			// 加上锁定和可见
			label+="[";
			if(_locked)
			{
				label+="lock,";
			}
			else
			{
				label+="unlock,";
			}
			if(_nodeData.visible)
			{
				label+="v";
			}
			else
			{
				label+="uv";
			}
			label+="]";
		}
		/**
		 * 首字母大写 
		 * @param str
		 * @return 
		 * 
		 */		
		public function getUpperFirst(str:String):String
		{
			return str.substr(0,1).toUpperCase()+str.substr(1);
		}
		
		/**
		 * 解码，从data中填充各个数据 
		 * @param data
		 * 
		 */		
		public function decodeData(data:Object):void
		{
			_type=data["type"];
			_custom=data["custom"];
			if(_custom=="")
			{
				_basicData.decodeObj(data);
				_nodeData.decodeObj(data);
				if(_type==Config.CONTROL_TYPE_SPRITE)
				{
					_spriteData.decodeObj(data);
				}
				else if(_type==Config.CONTROL_TYPE_LAYER)
				{
					_layerData.decodeObj(data);
				}
				else if(_type==Config.CONTROL_TYPE_BUTTON)
				{
					_buttonData.decodeObj(data);
				}
				
				//子组件
				var arr:Array=data["children"] as Array;
				if(arr)
				{
					for each(var d:Object in arr)
					{
						var control:ControlData=new ControlData();
						control.decodeData(d);
						this.addChild(control);
					}
				}
			}
			this.resetLabel();
		}
		/**
		 * 将数据转化为Object，最终生成json 
		 * {type,custom,children=[],x,y,anchorX,...}
		 * @return 
		 * 
		 */
		public function encodeData():Object
		{
			var list:Array=[];
			var data:Object={type:_type,custom:_custom,children:list};
			if(_custom=="")
			{
				//内部会决定是不是要编码
				_basicData.encodeObj(data);
				_nodeData.encodeObj(data);
				_spriteData.encodeObj(data);
				_layerData.encodeObj(data);
				_buttonData.encodeObj(data);
				//子组件
				for each(var controlData:ControlData in this.children)
				{
					list.push(controlData.encodeData());
				}
			}
			return data;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get custom():String
		{
			return _custom;
		}

		public function set custom(value:String):void
		{
			_custom = value;
		}

		public function get basicData():BasicPropertyData
		{
			return _basicData;
		}

		public function get nodeData():NodePropertyData
		{
			return _nodeData;
		}

		public function get spriteData():SpritePropertyData
		{
			return _spriteData;
		}

		public function get layerData():LayerPropertyData
		{
			return _layerData;
		}

		public function get buttonData():ButtonPropertyData
		{
			return _buttonData;
		}

		public function get locked():Boolean
		{
			return _locked;
		}

		public function set locked(value:Boolean):void
		{
			_locked = value;			
		}
	}
}