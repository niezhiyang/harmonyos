// 创建NodeController
// common.ets
import { UIContext, NodeController, BuilderNode, Size, FrameNode } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { Logger } from '@nzy/logger';

// @Builder中为动态组件的具体组件内容
// Data为入参封装类
class Data{
  url: string = "https://www.example.com";
  controller: WebviewController = new webview.WebviewController();
}

@Builder
function WebBuilder(data:Data) {
  Column() {
    Web({ src: data.url, controller: data.controller })
      .width("100%")
      .height("100%")
  }
}

let wrap = wrapBuilder<Data[]>(WebBuilder);

// 用于控制和反馈对应的NodeContainer上的节点的行为，需要与NodeContainer一起使用
export class myNodeController extends NodeController {
  private rootnode: BuilderNode<Data[]> | null = null;
  // 必须要重写的方法，用于构建节点数、返回节点挂载在对应NodeContainer中
  // 在对应NodeContainer创建的时候调用、或者通过rebuild方法调用刷新
  makeNode(uiContext: UIContext): FrameNode | null {
    Logger.info(" uicontext is undefined : "+ (uiContext === undefined));
    if (this.rootnode != null) {
      // 返回FrameNode节点
      return this.rootnode.getFrameNode();
    }
    // 返回null控制动态组件脱离绑定节点
    return null;
  }
  // 当布局大小发生变化时进行回调
  aboutToResize(size: Size) {
    Logger.info("aboutToResize width : " + size.width  +  " height : " + size.height );
  }

  // 当controller对应的NodeContainer在Appear的时候进行回调
  aboutToAppear() {
    Logger.info("aboutToAppear");
  }

  // 当controller对应的NodeContainer在Disappear的时候进行回调
  aboutToDisappear() {
    Logger.info("aboutToDisappear");
  }

  // 此函数为自定义函数，可作为初始化函数使用
  // 通过UIContext初始化BuilderNode，再通过BuilderNode中的build接口初始化@Builder中的内容
  initWeb(url:string, uiContext:UIContext, control:WebviewController) {
    if(this.rootnode != null)
    {
      return;
    }
    // 创建节点，需要uiContext
    this.rootnode = new BuilderNode(uiContext);
    // 创建动态Web组件
    this.rootnode.build(wrap, { url:url, controller:control });
  }
}
// 创建Map保存所需要的NodeController
let NodeMap:Map<string, myNodeController | undefined> = new Map();
// 创建Map保存所需要的WebViewController
let controllerMap:Map<string, WebviewController | undefined> = new Map();

// 初始化需要UIContext 需在Ability获取
export const createNWeb = (url: string, uiContext: UIContext) => {
  // 创建NodeController
  let baseNode = new myNodeController();
  let controller = new webview.WebviewController() ;
  // 初始化自定义Web组件
  baseNode.initWeb(url, uiContext, controller);
  controllerMap.set(url, controller)
  NodeMap.set(url, baseNode);
}
// 自定义获取NodeController接口
export const getNWeb = (url : string) : myNodeController | undefined => {
  return NodeMap.get(url);
}