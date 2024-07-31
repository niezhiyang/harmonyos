import { webview } from '@kit.ArkWeb';
import { HashMap, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

/**
 * https://github.com/uknownothingsnow/JsBridge
 * https://github.com/lzyzsd/JsBridge
 */

const TAG = "JsBridge"

@Entry
@Component
struct WebJsBridgePage {
  @State url: string | Resource = $rawfile('JsBridgeDemo.html')
  map: HashMap<string, (data: string) => void> = new HashMap()
  @State controller: MyWebviewController = new MyWebviewController(this.map);
  @State jsBridge: MainJavascriptInterface = new MainJavascriptInterface(this.controller);

  build() {
    Column() {
      Button('给h5发送消息,有回调').onClick(() => {
        this.controller.callHandler('functionInJs', '大哥好呀', (data) => {
          console.log(`Button=>点击 回调 ${data}`)
        })
      })
      Button('给h5发送消息 无回调').onClick(() => {
        this.controller.sendToWeb('hello')
      })
      Web({ src: this.url, controller: this.controller })
        .onControllerAttached(() => {
          // // 注册 jsbridge，类，h5中的名字，注册的方法
          this.controller.registerJavaScriptProxy(this.jsBridge, "WebViewJavascriptBridge",
            ["send", "response", "submitFromWeb"]);

          // 这种注册必须调用refresh
          this.controller.refresh()
          // 拿到当前的UserAgent
          let userAgent = this.controller.getUserAgent();
          console.log(`userAgent=> ${userAgent}}`)
          // 设置新的UserAgent
        })
        .fileAccess(true)// 是否可以读存储的html，api11 默认是true ，api12 默认是false $rawfile 不受影响
        .zoomAccess(false)// 设置是否支持手势进行缩放 默认允许，咱们app一般不允许
        .databaseAccess(true)//设置是否开启数据库存储API权限，默认不开启
        .horizontalScrollBarAccess(false)//设置是否显示横向滚动条 默认是有的
        .verticalScrollBarAccess(false)//设置是否显示纵向滚动条 默认是有的
        .onPageEnd(() => {
          // 加载 WebViewJavascriptBridge.js
          let jsBridge = getContext(this).resourceManager.getRawFileContentSync('WebViewJavascriptBridgeYa.js')
          let decoder = new util.TextDecoder('utf-8')
          let content = decoder.decode(jsBridge)
          console.log('读取到 ' + content)
          this.controller.loadUrl('javascript:' + content)
        })
        .textZoomRatio(250)
        .onConsole((event) => {
          // h5的打印，可以在这里看到
          console.log(`H5的打印-> ${event?.message.getMessage()}`)
          return true
        })
        .width('100%')
        .height('100%')
    }
    .height('100%')
    .width('100%')
  }
}

abstract class BaseJsBridge {
  controller: MyWebviewController

  constructor(controller: MyWebviewController) {
    this.controller = controller;
  }

  abstract sendMessage(): string

  // h5 调用 NA , NA回调给h5的。是通过 runJavaScript
  send(data: string, callbackId: string): string {
    console.log(TAG, `BaseJsBridge： method=send ,data=>${data} , callbackId=>${callbackId}`)
    return this.sendMessage()
  }

  // 当 NA 发送消息，h5 回调给 NA是用这种方法
  response(data: string, responseId: string): void {
    console.log(TAG, `BaseJsBridge： method=response  data=>${data} , responseId=>${responseId}`)
    if (this.controller.map.hasKey(responseId)) {
      this.controller.map.remove(responseId)(data)
    }
  }
}

class MainJavascriptInterface extends BaseJsBridge {
  sendMessage(): string {
    console.log(TAG, `MainJavascriptInterface： sendMessage`)
    return "这里应该是无用的信息";
  }

  submitFromWeb(data: string, callbackId: string) {
    console.log(TAG, `submitFromWeb： data=>${data} , responseId=>${callbackId}`)
    this.controller.sendResponse('submitFromWeb response', callbackId)
  }
}


class MyWebviewController extends webview.WebviewController {
  map: HashMap<string, (data: string) => void>

  constructor(map: HashMap<string, (data: string) => void>) {
    super()
    this.map = map
  }

  sendResponse(data: string, callbackId: string) {
    let response: JSResponse = new JSResponse()
    response.responseId = callbackId
    response.responseData = data
    let content = `javascript:WebViewJavascriptBridge._handleMessageFromNative('${JSON.stringify(response)}');`
    console.log(`json=> ${content}`)
    this.runJavaScript(content)
  }

  callHandler(handlerName: string, data: string, callBack?: (event: string) => void) {
    let callbackId = `ArkTs${new Date().getTime()}`
    let jsRequest = new JSRequest()
    jsRequest.data = data
    if (callBack) {
      this.map.set(callbackId, callBack)
      jsRequest.callbackId = callbackId
    }
    jsRequest.handlerName = handlerName
    let content = `javascript:WebViewJavascriptBridge._handleMessageFromNative('${JSON.stringify(jsRequest)}');`
    this.runJavaScript(content)
  }

  sendToWeb(data: string) {
    this.callHandler('', data)
  }
}

class JSRequest {
  callbackId: string = '';
  data: string = '';
  handlerName: string = '';
}

class JSResponse {
  responseId: string = ''
  responseData: string = ''
}
