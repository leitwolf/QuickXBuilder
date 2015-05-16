package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import mx.controls.Tree;
	import mx.core.FlexGlobals;
	import mx.events.ListEvent;

	/**
	 * 控件列表，树结构
	 * @author lonewolf
	 * 
	 */	
	public class ControlViewPart extends Messager
	{
		private var _tree:Tree;
		//根结点，不会变
		private var _root:ControlData=new ControlData();
		
		public function ControlViewPart()
		{
			_tree=FlexGlobals.topLevelApplication.controlView;
			_tree.showRoot=false;
			
			_tree.addEventListener(ListEvent.CHANGE,treeChangeHandler);	
		}
		
		/**
		 * 接收消息 
		 * @param sender
		 * @param type
		 * 
		 */		
		override public function receiveMessage(sender:Object, type:String):void
		{
			if(type==MessageCenter.CURRENT_FILE)
			{
				// 当前文件改变
				if(Config.curFileData==null)
				{
					_tree.dataProvider=null;
				}
				else
				{
					var arr:Array=Config.curFileData.children;
					if(arr&&arr.length>0)
					{
						_tree.dataProvider=Config.curFileData;
						_tree.expandItem(Config.curFileData,true);
					}
					else
					{
						_tree.dataProvider=null;
					}
				}
				_tree.selectedItem=null;
				Config.curControl=null;
				this.sendMessage(MessageCenter.CURRENT_CONTROL);
			}
			else if(type==MessageCenter.NEW_CONTROL)
			{
				// 新控件
				this.addControl();
				this.sendMessageDelay(MessageCenter.CURRENT_CONTROL);
				this.sendMessageDelay(MessageCenter.FILE_DIRTY);
			}
			else if(type==MessageCenter.CURRENT_CONTROL)
			{
				// 当前控件
				_tree.selectedItem=Config.curControl;
			}
			else if(type==MessageCenter.CONTROL_NAME)
			{
				// 控件名改变，刷新树列表
				_tree.invalidateList();
			}
		}
		/**
		 * 当前节点改变
		 * @param event
		 * 
		 */
		protected function treeChangeHandler(event:ListEvent):void
		{
			Config.curControl=_tree.selectedItem as ControlData;
			this.sendMessage(MessageCenter.CURRENT_CONTROL);
		}
		/**
		 * 添加新控件
		 * 
		 */
		private function addControl():void
		{
			var control:ControlData=Config.newControl;
			if(Config.curControl==null)
			{
				//当前没有选中节点，放在根下
				Config.curFileData.addChild(control);
				_tree.dataProvider=Config.curFileData;
			}
			else if(Config.curControl.type==Config.CONTROL_TYPE_NODE)
			{
				//放在Node下
				Config.curControl.addChild(control);
			}
			else
			{
				//放在当前node的parent的后面
				Config.curControl.parent.addChild(control);
			}			
			_tree.validateNow();
			_tree.expandChildrenOf(control.parent,true);
			_tree.selectedItem=control;
			Config.curControl=control;
		}

	}
}