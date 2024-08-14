import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import OpenLinkOptions from '@ohos.app.ability.OpenLinkOptions';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '@nzy/logger';

@Entry
@Component
struct WebDemo {
  @State message: string = 'Hello World';
  @State controller: webview.WebviewController = new webview.WebviewController();
  // @State url:string | Resource= 'https://www.csdn.net/'
  @State url:string | Resource= 'https://juejin.cn/'
  // @State url: string | Resource= 'https://www.huawei.com/cn'
  // @State url: string | Resource = $rawfile('indexDemo.html')
  @State loadingVisibility: Visibility = Visibility.Visible
  @State progress: number = 0
  @State isWebError: boolean = false

  aboutToAppear(): void {
    try {
      // 设置调试
      webview.WebviewController.setWebDebuggingAccess(true);
      // 设置cookie
      // webview.WebCookieManager.configCookieSync(this.url, 'a=b')
      // 设置Web内核自定义协议URL的跨域请求与fetch请求的权限 customizeSchemes
      let scheme1: webview.WebCustomScheme = { schemeName: "name1", isSupportCORS: true, isSupportFetch: true };
      webview.WebviewController.customizeSchemes([scheme1]);
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        NetError({
          reTryClick: () => {
            // 重新load
            this.controller.loadUrl(this.url)
            this.loadingVisibility = Visibility.Visible
            this.isWebError = false
          }
        }).visibility(this.isWebError ? Visibility.Visible : Visibility.Hidden)
        WebComponent({
          url: this.url,
          controller: this.controller,
          loadingVisibility: this.loadingVisibility,
          progress: this.progress,
          isWebError: this.isWebError
        })
        Progress({
          value: this.progress, // 当前进度
          type: ProgressType.Ring,
          total: 100
        })
          .width(50)
          .style({ strokeWidth: 5, status: ProgressStatus.LOADING })
          .visibility(this.loadingVisibility)
      }.width('100%')
      .height('100%')

    }
    .height('100%')
    .width('100%')
  }
}

@Component
struct WebComponent {
  @Link controller: webview.WebviewController
  @Link url: string | Resource
  @Link loadingVisibility: Visibility
  @Link progress: number
  @Link isWebError: boolean
  @State jsBridge: JsBridge = new JsBridge(this.controller);
  @State jsBridge2: JsBridge2 = new JsBridge2(this.controller);

  build() {
    Web({ src: this.url, controller: this.controller })
      .onControllerAttached(() => {
        // // 注册 jsbridge，类，h5中的名字，注册的方法
        this.controller.registerJavaScriptProxy(this.jsBridge, "jsBridge", ["callNative"]);
        // 这种注册必须调用refresh
        this.controller.refresh()
        // 拿到当前的UserAgent
        let userAgent = this.controller.getUserAgent() + '  appVersion/1.0.0';
        Logger.info(`userAgent=> ${userAgent}}`)
        // 设置新的UserAgent
        this.controller.setCustomUserAgent(userAgent);
      })
      .onPageBegin((event) => {
        // h5 开始加载 显示loading
        this.loadingVisibility = Visibility.Visible
      })
      .onProgressChange((event) => {
        // h5 加载进度变化，100% 有可能走多次 显示loading 进度
        this.progress = event?.newProgress ?? 0
      })
      .onPageEnd((event) => {
        // 推荐在此事件中执行JavaScript脚本
        // this.controller.runJavaScript('onPageEnd()')
        Logger.info("onPageEnd")
        // 隐藏loading
        this.loadingVisibility = Visibility.Hidden
      })
      .domStorageAccess(true)//置是否开启文档对象模型存储接口（DOM Storage API）权限
      .javaScriptAccess(true)// 设置是否允许执行JavaScript脚本 默认是执行，防止以后更改了
      .fileAccess(true)// 是否可以读存储的html，api11 默认是true ，api12 默认是false $rawfile 不受影响
      .zoomAccess(false)// 设置是否支持手势进行缩放 默认允许，咱们app一般不允许
      .databaseAccess(true)//设置是否开启数据库存储API权限，默认不开启
      .horizontalScrollBarAccess(false)//设置是否显示横向滚动条 默认是有的
      .verticalScrollBarAccess(false)//设置是否显示纵向滚动条 默认是有的
      .onTitleReceive((event) => {
        Logger.info(`onTitleReceive=> ${event?.title}`)
      })
      .onLoadIntercept((event) => {
        console.error(`onLoadIntercept=>${event.data.getRequestUrl()}`)
        let url: string = event.data.getRequestUrl();
        if (url.startsWith("resource://")) {
          return false
        } else if (url.startsWith("http")) {
          // 如果是http协议继续加载网页，直接返回false 不拦截
          return false
        } else if (url.indexOf('native://') === 0) {
          // 比如是Native页面，自己的非网页页面 , native:// 是自己的定义，一般咱们也是通过Bridge去做的
          // 比如 native://pages/mine
          router.pushUrl({ url: 'pages/mine' });
          return true
        }
        // else if (whitelist) {
        //   // 这里先注释，防止是使用 resource 和 /data/storage 本地打开h5,返回false，一般也不允许从咱们app打开其他的，一般是有白名单的
        //   // 其他协议比如  alipay://dl/scan 扫一扫 ,直接打开 支付宝扫一扫，不用加载了 ，直接打开
        //   // 这里是打开逻辑
        //   let context = getContext(this) as common.UIAbilityContext;
        //   // 打开其他应用界面
        //   let openLinkOptions: OpenLinkOptions = {
        //     appLinkingOnly: false
        //   };
        //   context.openLink(event.data.getRequestUrl(), openLinkOptions)
        //   // 返回true表示阻止此次加载，否则允许此次加载
        //   // return true
        // }

        return false
      })
      .onOverrideUrlLoading((webReq:WebResourceRequest)=>{
        Logger.info(`onOverrideUrlLoading = > ${webReq.getRequestUrl()}`)
        return false
      })
      .onInterceptRequest((event) => {

        // if (event) {
        //   // 是图片的正则表达式
        //   const imageRegex = /\.(jpg|jpeg|png|gif|bmp|webp)(?:\?.*)?$/i;
        //   if (imageRegex.test(event.request.getRequestUrl())) {
        //     console.log(`onInterceptRequest=> ${event.request.getRequestUrl()}`)
        //     // 图片，全部替换成本地的一个图片
        //     let responseWeb: WebResourceResponse = new WebResourceResponse();
        //     // ResponseDataID
        //     // 构造响应数据
        //     // 为自定义的JavaScript请求响应生成 CodeCache：自定义请求响应的资源类型如果是JavaScript脚本，
        //     // 可以在响应头中添加“ResponseDataID”字段，Web内核读取到该字段后会在为该JS资源生成CodeCache，
        //     // 加速JS执行，并且ResponseData如果有更新时必须更新该字段。不添加“ResponseDataID”字段的情况下默认不生成CodeCache。
        //     responseWeb.setResponseHeader([
        //       {
        //         // 格式：不超过13位纯数字。js识别码，Js有更新时必须更新该字段
        //         headerKey: "ResponseDataID",
        //         headerValue: "0000000000001"
        //       }]);
        //     // 1.要设置的资源响应数据。string表示HTML格式的字符串。
        //     // 2. number表示文件句柄, 此句柄由系统的Web组件负责关闭。
        //     // 3. Resource表示应用rawfile目录下文件资源。
        //     // 4. ArrayBuffer表示资源的原始二进制数据。
        //     responseWeb.setResponseData($rawfile('img1.webp'));
        //     responseWeb.setResponseMimeType('image/webp');
        //     responseWeb.setResponseEncoding('utf-8');
        //     responseWeb.setResponseCode(200);
        //     responseWeb.setReasonMessage('OK');
        //     responseWeb.setResponseIsReady(true)
        //     return responseWeb
        //   }
        // }
        // 返回响应数据则按照响应数据加载，无响应数据则返回null表示按照原来的方式加载
        return null;
      })
      .javaScriptProxy({
        object: this.jsBridge2,
        name: "jsBridge2", // 这是在h5中对象的名字
        methodList: ["callNative"], // 注册的方法
        controller: this.controller,
        asyncMethodList: ['asyncMethodList'] // 异步方法
      })
      .onConsole((event) => {
        // h5的打印，可以在这里看到
        Logger.info(`H5自己的打印-${event?.message.getMessage()}`)
        return true
      })
      .onErrorReceive((event) => {
        console.error(`onErrorReceive=> ${JSON.stringify(event)}}`)
        // if (event?.error) {
        //   console.error(`onErrorReceive.error=> ${JSON.stringify(event.error)}}`)
        // }
        // // 接收到错误 网页加载遇到错误时触发该回调。出于性能考虑，建议此回调中尽量执行简单逻辑。在无网络的情况下，触发此回调
        // this.isWebError = true
      })
      .onShowFileSelector(() => {
        //调用此函数以处理具有“文件”输入类型的HTML表单。如果不调用此函数或返回false，
        // Web组件会提供默认的“选择文件”处理界面。如果返回true,则自己去实现
        return false
      })
      .onFirstContentfulPaint((event) => {
        // 网页首次内容绘制的回调函数。首次绘制文本
        if (event) {
          console.error("onFirstContentfulPaint:" + JSON.stringify(event));
        }
      })
      .visibility(this.isWebError ? Visibility.Hidden : Visibility.Visible)
      .width('100%')
      .height('100%')
  }
}

@Component
struct NetError {
  @Require reTryClick: () => void = () => {
  }

  build() {
    Column() {
      Image($r('app.media.error')).width(100).height(100)
      Button('出错了，点击我刷新').onClick(() => {
        this.reTryClick()
      }).margin({ top: 20 })

    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

class JsBridge {
  controller: webview.WebviewController = new webview.WebviewController();

  constructor(controller: webview.WebviewController) {
    this.controller = controller
  }

  callNative() {
    Logger.info('h5 调用了 Native的 JsBridge callNativeNew 方法')
    return '11111'
  }
}

class JsBridge2 {
  controller: webview.WebviewController = new webview.WebviewController();

  constructor(controller: webview.WebviewController) {
    this.controller = controller
  }

  callNative() {
    Logger.info('h5 调用了 Native 的 JsBridge2 的 callNative 方法')
    return '2222'
  }

  asyncMethodList() {
    Logger.info('h5 调用了 Native 的 JsBridge2 的 asyncMethodList 方法')
  }
}