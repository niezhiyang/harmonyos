import { webview } from '@kit.ArkWeb';
import { HashMap, JSON } from '@kit.ArkTS';

@Entry
@Component
struct JsBridgePage {
  @State message: string = 'Hello World';
  @State controller: webview.WebviewController = new webview.WebviewController();
  // @State url:string | Resource= 'https://www.csdn.net/'
  // @State url: string | Resource= 'https://www.huawei.com/cn'
  @State url: string | Resource = $rawfile('indexDemo.html')
  @State map: HashMap<string, CordovaPlugin> = new HashMap()
  @State jsBridge: JsBridge = new JsBridge(this.controller, this.map);

  aboutToAppear(): void {
    let pagePlugin = new PagePlugin(this.controller)
    let loginPlugin = new UserPlugin(this.controller)
  }

  build() {
    Column() {
      Web({ src: this.url, controller: this.controller })
        .onControllerAttached(() => {
          // // 注册 jsbridge，类，h5中的名字，注册的方法
          this.controller.registerJavaScriptProxy(this.jsBridge, "_cordovaNative", ["exec"]);
          // 这种注册必须调用refresh
          this.controller.refresh()
          // 拿到当前的UserAgent
          let userAgent = this.controller.getUserAgent();
          console.log(`userAgent=> ${userAgent}}`)
          // 设置新的UserAgent
        })
        .onProgressChange((event) => {
          if (event) {
            console.log(`进度--》 ${event.newProgress}`)
          }
        })
        .fileAccess(true)// 是否可以读存储的html，api11 默认是true ，api12 默认是false $rawfile 不受影响
        .zoomAccess(false)// 设置是否支持手势进行缩放 默认允许，咱们app一般不允许
        .databaseAccess(true)//设置是否开启数据库存储API权限，默认不开启
        .horizontalScrollBarAccess(false)//设置是否显示横向滚动条 默认是有的
        .verticalScrollBarAccess(false)//设置是否显示纵向滚动条 默认是有的
        .onConsole((event) => {
          // h5的打印，可以在这里看到
          console.log(`H5自己的打印-${event?.message.getMessage()}`)
          return true
        })
        .width('100%')
        .height('100%')
    }
    .height('100%')
    .width('100%')
  }
}

class JsBridge {
  controller: webview.WebviewController
  map: HashMap<string, CordovaPlugin>

  constructor(controller: webview.WebviewController, map: HashMap<string, CordovaPlugin>) {

    this.controller = controller;
    this.map = map;
  }

  exec(bridgeSecret: number, service: string, action: string, callbackId: string, argument: string): string {
    // 整体try ，抛异常 给 h5
    console.log(`JsBridge=> service= ${service} action=${action} callbackId=${callbackId} argument=${argument}`)
    if (this.map.hasKey(service)) {
      let plugin: CordovaPlugin = this.map.get(service)
      plugin.exec(action, JSON.parse(argument) as Array<JSON>, new CallbackContext(callbackId, this.controller))
    } else {
      // 没有这个 service

    }
    return ""
  }
}

abstract class CordovaPlugin {
  controller: webview.WebviewController

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  abstract exec(action: string, args: Array<JSON>, callbackContext: CallbackContext): boolean
}

export class PagePlugin extends CordovaPlugin {
  exec(action: string, args: JSON[], callbackContext: CallbackContext): boolean {
    if (action == 'query') {

      callbackContext.success({ "status": "0" })
    }
    return false
  }
}

export class UserPlugin extends CordovaPlugin {
  exec(action: string, args: JSON[], callbackContext: CallbackContext): boolean {
    if (action == 'user') {
      callbackContext.success({ "status": "0" })
      return true
    }

    return false
  }
}


class CallbackContext {
  callbackId: string
  controller: webview.WebviewController

  constructor(callbackId: string, controller: webview.WebviewController) {
    this.callbackId = callbackId;
    this.controller = controller
  }

  success(ext: Record<string, string>) {
    this.controller.runJavaScript(`cordova.callbackFromNative('${this.callbackId}',true,1,[{"code":"1","msg":"success","ext":${JSON.stringify(ext)}}],false);`)
  }

  cancel(ext: Record<string, string>) {
    this.controller.runJavaScript(`cordova.callbackFromNative('${this.callbackId}',true,1,[{"code":"2","msg":"cancel","ext":{"status":"0"}}],false);`)
  }

  failed(ext: Record<string, string>) {
    this.controller.runJavaScript(`cordova.callbackFromNative('${this.callbackId}',true,1,[{"code":"0","msg":"fail","ext":{"status":"0"}}],false);`)

  }
}



