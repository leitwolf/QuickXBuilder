package app.message
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;

	/**
	 * 消息中心，所有的信息都是在这里进行转发
	 * 
	 * --整个消息系统旨在为各个模块（部件）之间进行通信
	 * --当某一地方的状态变化时，就可能会引起其它地方状态的改变，这个时候就需要在各个部件之间进行通信了
	 * --消息系统为这一通信过程提供了清晰的思路
	 * --但各个部件还是清楚自己需要什么消息
	 * --注意，这只是内部间的，内部的变动要自己解决
	 * --消息中心没有数据上的交互，数据会放在另一个地方，比如发送消息前要把数据处理好，发消息只是通知状态改变了
	 * --接收消息的时候同时对外发消息要用sendMessageDelay方法，因为这个时候上个消息都已处理完
	 * @author lonewolf
	 * 
	 */	
	public class MessageCenter
	{
		// ====各消息类型====	
		// 分辨率
		public static const RESOLUTION:String="resolution";
		// 场景缩放
		public static const SCENE_ZOOM:String="scene_zoom";
		// 自定义分辨率
		public static const CUSTOM_RESOLUTION:String="custom_resolution";
		// 拖动场景状态改变
		public static const LOCK_SCENE_STATE_CHANGED:String="lock_scene_state_changed";
		// 新项目
		public static const NEW_PROJECT:String="new_project";
		// 新文件
		public static const NEW_FILE:String="new_file";
		// 修改文件名
		public static const RENAME_FILE:String="rename_file";
		// 当前文件
		public static const CURRENT_FILE:String="current_file";
		// 新控件
		public static const NEW_CONTROL:String="new_control";
		// 删除控件
		public static const DELETE_CONTROL:String="delete_control";
		// 当前控件
		public static const CURRENT_CONTROL:String="current_control";
		// 拖动控件
		public static const DRAG_CONTROL:String="drag_control";
		// 锁定控件
		public static const LOCK_CONTROL:String="lock_control";
		// 控件名
		public static const CONTROL_NAME:String="control_name";
		// 控件图片
		public static const CONTROL_IMAGE:String="control_image";
		// 控件坐标
		public static const CONTROL_POSITION:String="control_position";
		// 控件锚点
		public static const CONTROL_ANCHOR:String="control_anchor";
		// 控件颜色
		public static const CONTROL_COLOR:String="control_color";
		// 控件是否可见
		public static const CONTROL_VISIBLE:String="control_visible";
		// 控件其它属性
		public static const CONTROL_PROPERTY:String="control_property";
		// 脏数据，需要保存
		public static const FILE_DIRTY:String="file_dirty";
		// 脏数据已保存
		public static const FILE_SAVED:String="file_saved";
		
		//信使列表，所有发送的消息都会分发给各个信使，除了发送者
		private static var messagerList:Vector.<IMessager>=new Vector.<IMessager>();
		
		// 延迟发送列表
		private static var delayList:Array=[];
		
		public function MessageCenter()
		{
		}
		/**
		 * 初始化 
		 * 
		 */
		public static function init():void
		{
			var stage:Stage=FlexGlobals.topLevelApplication.stage;
			stage.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		/**
		 * 每帧执行，用于发送延迟的消息
		 * @param event
		 * 
		 */		
		protected static function enterFrameHandler(event:Event):void
		{
			if(delayList.length>0)
			{
				//一次只发送一次消息
				var obj:Object=delayList[0];
				MessageCenter.sendMessage(obj.sender,obj.type);
				delayList.splice(0,1);
			}
		}
		/**
		 * 注册信使 
		 * @param messager
		 * 
		 */
		public static function registerMessager(messager:IMessager):void
		{
			// 检测是否重复
			for each(var m:IMessager in messagerList)
			{
				if(m==messager)
				{
					return;
				}
			}
			messagerList.push(messager);
		}
		/**
		 * 发送消息，所有消息都经过这些处理，然后分发到各个部件
		 * @param sender 发送者
		 * @param type 类型
		 * 
		 */
		public static function sendMessage(sender:Object, type:String):void
		{
			//分发到各个部件
			for each(var m:IMessager in messagerList)
			{
				if(m!=sender)
				{
					m.receiveMessage(sender, type);
				}
			}
		}
		/**
		 * 延迟发送消息，下一帧发送，一般在receiveMessage方法中使用
		 * @param sender 发送者
		 * @param type 类型
		 * 
		 */	
		public static function sendMessageDelay(sender:Object, type:String):void
		{
			delayList.push({sender:sender,type:type});
		}
	}
}