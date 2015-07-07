package app.part
{
	import app.Config;
	import app.data.ControlData;
	import app.message.MessageCenter;
	import app.message.Messager;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	
	import mx.controls.Tree;
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.events.DragEvent;
	import mx.events.ListEvent;
	import mx.managers.DragManager;

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
		// 拖动的时候不处理节点改变
		private var _dragging:Boolean=false;
		// 右键菜单
		private var _menu:NativeMenu;
		
		public function ControlViewPart()
		{
			_tree=FlexGlobals.topLevelApplication.controlView;
			_tree.showRoot=false;
			_tree.dragEnabled=true;
			_tree.dragMoveEnabled=true;
			_tree.dropEnabled=true;
			_tree.focusEnabled=false;
			
			_menu=new NativeMenu();
			var item:NativeMenuItem=new NativeMenuItem("lock1");
			_menu.addItem(item);
			_tree.contextMenu=_menu;
			_menu.addEventListener(Event.DISPLAYING,menuDisplayingHandler);
			_menu.addEventListener(Event.SELECT,menuSelectHandler);
			
			_tree.addEventListener(ListEvent.CHANGE,treeChangeHandler);	
			_tree.addEventListener(DragEvent.DRAG_COMPLETE,dragCompleteHandler);
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
				this.refresh();
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
			else if(type==MessageCenter.CONTROL_NAME||type==MessageCenter.LOCK_CONTROL||type==MessageCenter.CONTROL_VISIBLE)
			{
				// 控件名改变，刷新树列表
				_tree.invalidateList();
			}
		}
		/**
		 * 显示右键菜单
		 * @param event
		 * 
		 */		
		protected function menuDisplayingHandler(event:Event):void
		{
			_menu.removeAllItems();
			var cur:ControlData=Config.curControl;
			if(cur)
			{
				var item:NativeMenuItem=new NativeMenuItem();
				if(cur.locked)
				{
					item.label="unlock";
				}
				else
				{
					item.label="lock";
				}
				_menu.addItem(item);
			}
		}
		/**
		 * 选择菜单 
		 * @param event
		 * 
		 */		
		protected function menuSelectHandler(event:Event):void
		{
			if(Config.curControl)
			{
				Config.curControl.toggleLock();
				this.sendMessage(MessageCenter.LOCK_CONTROL);
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
			if(_dragging)
			{
				_dragging=false;
				return;
			}
			Config.curControl=_tree.selectedItem as ControlData;
			
			this.sendMessage(MessageCenter.CURRENT_CONTROL);
		}
		/**
		 * 拖动完成 
		 * @param event
		 * 
		 */
		protected function dragCompleteHandler(event:DragEvent):void
		{
			var arr:Array=event.dragSource.dataForFormat("treeItems") as Array;
			var control:ControlData=arr[0] as ControlData;
			Config.curControl=control;
			_tree.selectedItem=control;
			_dragging=true;
			trace(Config.curControl.label);
			this.sendMessageDelay(MessageCenter.DRAG_CONTROL);
			MessageCenter.sendMessageDelay(null,MessageCenter.CURRENT_CONTROL);
		}
		/**
		 * 删除当前的控件 
		 * 
		 */
		public function deleteControl():void
		{
			if(Config.curControl!=null)
			{
				Config.curControl.parent.removeChild(Config.curControl);
				this.refresh();
				this.sendMessageDelay(MessageCenter.DELETE_CONTROL);
				this.sendMessageDelay(MessageCenter.FILE_DIRTY);
				this.sendMessageDelay(MessageCenter.CURRENT_CONTROL);
			}
		}
		/**
		 * 刷新控件列表
		 * 一般在重设文件以及删除控件之后调用
		 * 
		 */		
		private function refresh():void
		{
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