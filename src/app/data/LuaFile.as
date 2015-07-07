package app.data
{
	import app.Config;
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	import mx.utils.ColorUtil;

	/**
	 * 生成lua文件的操作类
	 * @author lonewolf
	 * 
	 */	
	public class LuaFile
	{
		private var _data:FileData;
		// 最后生成的字符串
		private var _luaData:String="";
		// 是否是场景
		private var _isScene:Boolean=false;
		// 使用到的plist
		private var _plistList:Array=[];
		// 控件名称索引
		private var _index:int=1;
		
		public function LuaFile(data:FileData)
		{
			_data=data;
			var template:String;
			
				_isScene=true;
			if(data.type==Config.FILE_TYPE_SCENE)
			{
				template=Config.getLuaTemplate("Scene");
				var re:RegExp=new RegExp(/\$Scene\$/g);
				template=template.replace(re,data.name);
			}
			else
			{
				template=Config.getLuaTemplate("Node");	
				re=new RegExp(/\$Node\$/g);
				template=template.replace(re,data.name);
			}
			
			// 解析各个控件
			if(data.children)
			{
				for each(var d:ControlData in data.children)
				{
					this.analyseControl(d,"self");
				}
			}
			this.addLine("");
			
			// 加上plist
			var str:String="";
			for each(var p:String in _plistList)
			{				
				var image:String=p.substr(0,p.length-6)+".png";
				str+="\r\n    display.addSpriteFrames(\""+p+"\", \""+image+"\")";
			}
			_luaData=str+_luaData;
			
			// 添加模板
			_luaData=template.replace("$ctor$",_luaData);
		}
		/**
		 * 生成控件，递归调用 
		 * @param data
		 * @param parent 要加到的控件名称 第一层为self
		 * 
		 */		
		private function analyseControl(data:ControlData, parent:String):void
		{
			this.addLine("");
			_index++;
			var name:String;
			if(data.type==Config.CONTROL_TYPE_NODE)
			{
				name="node"+_index;
				this.analyseNode(data,name,parent);
			}
			else if(data.type==Config.CONTROL_TYPE_SPRITE)
			{
				name="sprite"+_index;
				this.analyseSprite(data,name,parent);
			}
			else if(data.type==Config.CONTROL_TYPE_BUTTON)
			{
				name="button"+_index;
				this.analyseButton(data,name,parent);
			}
			else if(data.type==Config.CONTROL_TYPE_LAYER)
			{
				name="layer"+_index;
				this.analyseLayer(data,name,parent);
			}
			if(data.children)
			{
				for each(var d:ControlData in data.children)
				{
					this.analyseControl(d,name);
				}
			}
		}
		/**
		 * 解析Node 
		 * @param data
		 * @param name 分配的名称
		 * @param parent 添加到控件
		 * 
		 */		
		private function analyseNode(data:ControlData,name:String,parent:String):void
		{
			this.addLine("local _control = display.newNode()",{_control:name});
			var pos:Object=this.getPosition(data);
			this.addLine("_control:setPosition(_x, _y)",{_control:name,_x:pos.x,_y:pos.y});
			this.addLine("_control:setVisible(_visible)",{_control:name,_visible:data.nodeData.visible});
			this.addLine("_parent:addChild(_control)",{_control:name,_parent:parent});
			if(data.basicData.name!="")
			{
				this.addLine("self._name=_control",{_control:name,_name:data.basicData.name});
			}			
		}
		/**
		 * 解析Sprite 
		 * @param data
		 * @param name 分配的名称
		 * @param parent 添加到控件
		 * 
		 */
		private function analyseSprite(data:ControlData,name:String,parent:String):void
		{
			var filename:String=data.spriteData.image;
			if(data.spriteData.imagePlist!="")
			{
				filename="#"+filename;
				this.addPlist(data.spriteData.imagePlist);
			}
			else
			{
				// 查看是不是demo文件夹下的
				// 在demo文件夹下的不生成到lua中
				if(filename.indexOf(ResourceManager.demoDir)==0)
				{
					trace("demo, pass.");
					return;
				}
			}
			this.addLine("local _control = display.newSprite(\"_filename\")",{_control:name,_filename:filename});
			var pos:Object=this.getPosition(data);
			this.addLine("_control:setPosition(_x, _y)",{_control:name,_x:pos.x,_y:pos.y});
			this.addLine("_control:setAnchorPoint(cc.p(_x,_y))",{_control:name,_x:data.nodeData.anchorX,_y:data.nodeData.anchorY});
			this.addLine("_control:setVisible(_visible)",{_control:name,_visible:data.nodeData.visible});
			this.addLine("_parent:addChild(_control)",{_control:name,_parent:parent});
			if(data.basicData.name!="")
			{
				this.addLine("self._name=_control",{_control:name,_name:data.basicData.name});
			}			
		}
		/**
		 * 解析Button 
		 * @param data
		 * @param name 分配的名称
		 * @param parent 添加到控件
		 * 
		 */		
		private function analyseButton(data:ControlData,name:String,parent:String):void
		{
			var normal:String=data.buttonData.normal;
			if(data.buttonData.normalPlist!="")
			{
				normal="#"+normal;
				this.addPlist(data.buttonData.normalPlist);
			}
			var pressed:String=data.buttonData.pressed;
			if(data.buttonData.pressedPlist!="")
			{
				pressed="#"+pressed;
				this.addPlist(data.buttonData.pressedPlist);
			}
			// 为空则要前一个
			if(pressed=="")
			{
				pressed=normal;
			}
			var disabled:String=data.buttonData.disabled;
			if(data.buttonData.disabledPlist!="")
			{
				disabled="#"+disabled;
				this.addPlist(data.buttonData.disabledPlist);
			}
			// 为空则要第一个			
			if(disabled=="")
			{
				disabled=normal;
			}
			this.addLine("local images = {normal = \"_normal\", pressed = \"_pressed\", disabled = \"_disabled\"}",{_normal:normal,_pressed:pressed,_disabled:disabled});
			this.addLine("local _control = cc.ui.UIPushButton.new(images)",{_control:name});
			var pos:Object=this.getPosition(data);
			this.addLine("_control:setPosition(_x, _y)",{_control:name,_x:pos.x,_y:pos.y});
			this.addLine("_control:setAnchorPoint(cc.p(_x,_y))",{_control:name,_x:data.nodeData.anchorX,_y:data.nodeData.anchorY});
			this.addLine("_control:setVisible(_visible)",{_control:name,_visible:data.nodeData.visible});
			this.addLine("_parent:addChild(_control)",{_control:name,_parent:parent});
			if(data.basicData.name!="")
			{
				this.addLine("self._name=_control",{_control:name,_name:data.basicData.name});
			}			
		}
		/**
		 * 解析Layer 
		 * @param data
		 * @param name 分配的名称
		 * @param parent 添加到控件
		 * 
		 */		
		private function analyseLayer(data:ControlData,name:String,parent:String):void
		{
			var color:ColorTransform=new ColorTransform();
			color.color=data.layerData.color;
			color.alphaOffset=255*data.layerData.alpha;
			this.addLine("local color = cc.c4f(_r, _g, _b, _a)",{_r:color.redOffset,_g:color.greenOffset,_b:color.blueOffset,_a:color.alphaOffset});			
			this.addLine("local _control = display.newColorLayer(color)",{_control:name});
			this.addLine("_control:setVisible(_visible)",{_control:name,_visible:data.nodeData.visible});
			this.addLine("_parent:addChild(_control)",{_control:name,_parent:parent});
			if(data.basicData.name!="")
			{
				this.addLine("self._name=_control",{_control:name,_name:data.basicData.name});
			}			
		}
		/**
		 * 位置
		 * @param data
		 * @return {x,y}
		 * 
		 */		
		private function getPosition(data:ControlData):Object
		{
			var x:String="";
			var y:String="";
			if(_isScene)
			{
				//用系统的分辨率
				if(data.nodeData.xAlign==Config.LOCATION_LEFT)
				{
					x=this.handleSymbol("display.left",data.nodeData.x);
				}
				else if(data.nodeData.xAlign==Config.LOCATION_CENTER)
				{
					x=this.handleSymbol("display.cx",data.nodeData.x);
				}
				else if(data.nodeData.xAlign==Config.LOCATION_RIGHT)
				{
					x=this.handleSymbol("display.right",data.nodeData.x);
				}
				
				if(data.nodeData.yAlign==Config.LOCATION_TOP)
				{
					y=this.handleSymbol("display.top",data.nodeData.y);
				}
				else if(data.nodeData.yAlign==Config.LOCATION_CENTER)
				{
					y=this.handleSymbol("display.cy",data.nodeData.y);
				}
				else if(data.nodeData.yAlign==Config.LOCATION_BOTTOM)
				{
					y=this.handleSymbol("display.bottom",data.nodeData.y);
				}
			}
			else
			{
				// 使用控件分辨率
				if(data.nodeData.xAlign==Config.LOCATION_LEFT)
				{
					x=data.nodeData.x+"";
				}
				else if(data.nodeData.xAlign==Config.LOCATION_CENTER)
				{
					x=(_data.width/2+data.nodeData.x)+"";
				}
				else if(data.nodeData.xAlign==Config.LOCATION_RIGHT)
				{
					x=(_data.width-data.nodeData.x)+"";
				}
				
				if(data.nodeData.yAlign==Config.LOCATION_TOP)
				{
					y=(_data.height-data.nodeData.y)+"";
				}
				else if(data.nodeData.yAlign==Config.LOCATION_CENTER)
				{
					y=(_data.height/2+data.nodeData.y)+"";
				}
				else if(data.nodeData.yAlign==Config.LOCATION_BOTTOM)
				{
					y=data.nodeData.y+"";
				}
			}
			return {x:x,y:y};
		}
		/**
		 * 字符串连接时注意到的符号+- 
		 * @param str
		 * @param num
		 * @return 
		 * 
		 */		
		private function handleSymbol(str:String,num:Number):String
		{
			if(num<0)
			{
				return str+" - "+Math.abs(num);
			}
			else
			{
				return str+" + "+Math.abs(num);
			}
		}
		/**
		 * 添加一行字 
		 * @param line
		 * @param replace 要替换的
		 * 
		 */		
		private function addLine(line:String,replace:Object=null):void
		{
			if(replace)
			{
				for(var i:String in replace)
				{
					line=line.replace(i,replace[i]);
				}
			}
			_luaData+="\r\n    "+line;
		}
		/**
		 * 添加使用到的plist文件 
		 * @param plist
		 * 
		 */		
		private function addPlist(plist:String):void
		{
			for each(var p:String in _plistList)
			{
				if(p==plist)
				{
					return;
				}
			}
			_plistList.push(plist);
		}

		public function get luaData():String
		{
			return _luaData;
		}

	}
}