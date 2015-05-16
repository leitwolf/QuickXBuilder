package AirLib
{
	import AirLib.dragable.DragableManager;
	
	import mx.core.FlexGlobals;

	public class G
	{
		//是否初始化过
		private static var _inited:Boolean=false;
		//已初始化过的场景列表
		private static var _sceneList:Array=[];
		//当前场景
		private static var _curScene:SceneBase;
		//拖动管理
		private static var _dragableManager:DragableManager;
		
		public function G()
		{
		}
		//初始化
		private static function init():void
		{
			_dragableManager=new DragableManager();
		}
		/**
		 * 切换场景 
		 * @param scene SceneBase的子类
		 * 
		 */		
		public static function switchScene(scene:Class):void
		{
			//在此初始化
			if(!_inited)
			{
				_inited=true;
				init();
			}
			var s:SceneBase=null;
			for each(var ss:SceneBase in _sceneList)
			{
				if(ss is scene)
				{
					s=ss;
					break;
				}
			}
			if(s==null)
			{
				//new scene
				s=new scene() as SceneBase;
				_sceneList.push(s);
			}
			//先停止之前的场景
			if(_curScene!=null)
			{
				_curScene.onEnd();
				FlexGlobals.topLevelApplication.currentState=s.state;
			}			
			_curScene=s;
			s.onStart();
		}

		public static function get dragableManager():DragableManager
		{
			return _dragableManager;
		}

		public static function get curScene():SceneBase
		{
			return _curScene;
		}


	}
}