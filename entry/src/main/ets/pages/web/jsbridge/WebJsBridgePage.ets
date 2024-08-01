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
  @State controller: webview.WebviewController = new webview.WebviewController();
  jsBridgeHelper: JsBridgeHelper = new JsBridgeHelper(this.controller)
  @State jsBridge: MainJavascriptInterface = new MainJavascriptInterface(this.jsBridgeHelper);

  build() {
    Column() {
      Button('给h5发送消息,有回调').onClick(() => {
        this.jsBridgeHelper.callHandler('functionInJs', '大哥好呀', (data) => {
          console.log(`Button=>点击 回调 ${data}`)
        })
      })
      Button('给h5发送消息 无回调').onClick(() => {
        this.jsBridgeHelper.sendToWeb('hello')
      })
      Web({ src: this.url, controller: this.controller })
        .onControllerAttached(() => {
          // // 注册 jsbridge，类，h5中的名字，注册的方法
          this.controller.registerJavaScriptProxy(this.jsBridge, "WebViewJavascriptBridge",
            ["send", "response", "submitFromWeb"]);
          // 这种注册必须调用refresh
          this.controller.refresh()
        })
        .zoomAccess(false)// 设置是否支持手势进行缩放 默认允许，咱们app一般不允许
        .onPageEnd(() => {
          // 加载 WebViewJavascriptBridge.js
          let jsBridge = getContext(this).resourceManager.getRawFileContentSync('WebViewJavascriptBridge.js')
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


class MainJavascriptInterface {
  jsBridgeHelper: JsBridgeHelper

  constructor(jsBridgeHelper: JsBridgeHelper) {
    this.jsBridgeHelper = jsBridgeHelper;
  }

  // h5 调用 NA , NA回调给h5的。是通过 runJavaScript
  send(data: string, callbackId: string): string {
    console.log(TAG, `MainJavascriptInterface： method=send ,data=>${data} , callbackId=>${callbackId}`)
    // 这里的返回值其实是没有意义的
    return '--'
  }

  // 当 NA 发送消息，h5 回调给 NA是用这种方法
  response(data: string, responseId: string): void {
    console.log(TAG, `MainJavascriptInterface： method=response  data=>${data} , responseId=>${responseId}`)
    if (this.jsBridgeHelper.map.hasKey(responseId)) {
      this.jsBridgeHelper.map.remove(responseId)(data)
    }
  }

  submitFromWeb(data: string, callbackId: string) {
    console.log(TAG, `MainJavascriptInterface: method=submitFromWeb data=>${data} , responseId=>${callbackId}`)
    this.jsBridgeHelper.sendResponse('submitFromWeb response', callbackId)
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

class JsBridgeHelper {
  controller: webview.WebviewController;
  map: HashMap<string, (data: string) => void> = new HashMap()

  constructor(controller: webview.WebviewController) {
    this.controller = controller
  }

  sendResponse(data: string, callbackId: string) {
    let response: JSResponse = new JSResponse()
    response.responseId = callbackId
    response.responseData = data
    let content = `javascript:WebViewJavascriptBridge._handleMessageFromNative('${JSON.stringify(response)}');`
    console.log(`json=> ${content}`)
    this.controller.runJavaScript(content)
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
    this.controller.runJavaScript(content)
  }

  sendToWeb(data: string) {
    this.callHandler('', data)
  }
}
