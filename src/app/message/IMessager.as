package app.message
{
	/**
	 * 信使接口，用于发送和接收消息 
	 * @author lonewolf
	 * 
	 */	
	public interface IMessager
	{
		/**
		 * 发送消息 
		 * @param type 消息类型
		 * 
		 */
		function sendMessage(type:String):void;		
		/**
		 * 延迟发送消息，下一帧发出 
		 * @param type 消息类型
		 * 
		 */
		function sendMessageDelay(type:String):void;
		/**
		 * 接收消息，内部自己判断要不要处理此消息
		 * @param sender 发送者
		 * @param type 消息类型
		 * @param params 参数
		 * 
		 */
		function receiveMessage(sender:Object, type:String):void;
	}
}