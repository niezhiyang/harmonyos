// xxx.ets
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { ProgressButton, promptAction, router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  currentTimestamp: number = Date.now();
  heads: Header[] = new Array();
  @State loadingVisibility: Visibility = Visibility.Visible
  @State progress: number = 0
  url = $rawfile('index.html')
  // url = 'https://m.jiduapp.cn/jidulife/#/pages/goodsDetail?naviStyle=1&id=105029312889711560'
  // url = 'https://juejin.cn/'
  @State webTestObj: WebObj = new WebObj(this.controller);
  @State webTestNew: WebObjNew = new WebObjNew(this.controller);

  aboutToAppear(): void {
    console.error(`aboutToAppear 到达这里的时间：${Date.now() - this.currentTimestamp}`)
    try {
      // 设置调试
      webview.WebviewController.setWebDebuggingAccess(true);
      // 设置cookie
      webview.WebCookieManager.configCookieSync('https://www.example.com', 'a=b')
      // 设置Web内核自定义协议URL的跨域请求与fetch请求的权限 customizeSchemes
      let scheme1: webview.WebCustomScheme = { schemeName: "name1", isSupportCORS: true, isSupportFetch: true };
      let scheme2: webview.WebCustomScheme = { schemeName: "name2", isSupportCORS: true, isSupportFetch: true };
      let scheme3: webview.WebCustomScheme = { schemeName: "name3", isSupportCORS: true, isSupportFetch: true };
      webview.WebviewController.customizeSchemes([scheme1, scheme2, scheme3]);
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  build() {
    Stack() {
      Web({ src: this.url, controller: this.controller })
        .onControllerAttached(() => {
          // // 注册 jsbridge，类，h5中的名字，注册的方法
          this.controller.registerJavaScriptProxy(this.webTestNew, "objTestNameNew", ["callNativeNew"]);
          // 这种注册必须调用refresh
          this.controller.refresh()

          // 拿到当前的UserAgent
          let userAgent = this.controller.getUserAgent() + '  appVersion/1.0.0';
          console.log(`userAgent=> ${userAgent}}`)
          // 设置新的UserAgent
          this.controller.setCustomUserAgent(userAgent);
        })
        .onLoadIntercept((event) => {
          if (event) {
            console.log('--------------- onLoadIntercept start ---------------')
            console.log('onLoadIntercept url:' + event.data.getRequestUrl())
            console.log('getRequestMethod:' + event.data.getRequestMethod())
            console.log('header:' + event.data.getRequestHeader())
            console.log('url:' + event.data.getRequestUrl())
            console.log('isMainFrame:' + event.data.isMainFrame())
            console.log('isRedirect:' + event.data.isRedirect())
            console.log('isRequestGesture:' + event.data.isRequestGesture())
            console.log('--------------- onLoadIntercept end ---------------')
          }
          let url: string = event.data.getRequestUrl();
          // 如果是http协议继续加载
          if (url.startsWith("http")) {
            // 是网页，直接返回false
            return true
          }
          // 比如是Native页面，自己的非网页页面 , native:// 是自己的定义，一般咱们也是通过Bridge去做的
          // 比如 native://pages/mine
          if (url.indexOf('native://') === 0) {
            // 是网页，直接返回false
            router.pushUrl({ url: 'pages/mine' });
            return true
          }
          // 其他协议比如  alipay://dl/scan 扫一扫 ,直接打开 支付宝扫一扫，不用加载了 ，直接打开
          // 这里是打开逻辑
          let context = getContext(this) as common.UIAbilityContext;
          // 打开其他应用界面
          context.openLink(event.data.getRequestUrl())
          // 返回true表示阻止此次加载，否则允许此次加载
          return false
        })

        .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
          // 如果是http协议继续加载
          if (webResourceRequest && webResourceRequest.getRequestUrl().startsWith("http")) {
            // 是网页，直接返回false
            return false
          }
          // 其他协议比如  alipay://dl/scan 扫一扫 ,直接打开 支付宝扫一扫，不用加载了 ，直接打开
          // 这里是打开逻辑
          let context = getContext(this) as common.UIAbilityContext;
          // 打开其他应用界面
          context.openLink(webResourceRequest.getRequestUrl())
          return false;
        })
        .onInterceptRequest((event) => {
          if (event) {
            // 是图片的正则表达式
            const imageRegex = /\.(jpg|jpeg|png|gif|bmp|webp)(?:\?.*)?$/i;
            if (imageRegex.test(event.request.getRequestUrl())) {
              console.log(`onInterceptRequest=> ${event.request.getRequestUrl()}`)
              // 图片，全部替换成本地的一个图片
              let responseWeb: WebResourceResponse = new WebResourceResponse();
              // ResponseDataID
              // 构造响应数据
              // 为自定义的JavaScript请求响应生成 CodeCache：自定义请求响应的资源类型如果是JavaScript脚本，
              // 可以在响应头中添加“ResponseDataID”字段，Web内核读取到该字段后会在为该JS资源生成CodeCache，
              // 加速JS执行，并且ResponseData如果有更新时必须更新该字段。不添加“ResponseDataID”字段的情况下默认不生成CodeCache。
              responseWeb.setResponseHeader([
                {
                  // 格式：不超过13位纯数字。js识别码，Js有更新时必须更新该字段
                  headerKey: "ResponseDataID",
                  headerValue: "0000000000001"
                }]);
              responseWeb.setResponseHeader(this.heads);
              // 1.要设置的资源响应数据。string表示HTML格式的字符串。
              // 2. number表示文件句柄, 此句柄由系统的Web组件负责关闭。
              // 3. Resource表示应用rawfile目录下文件资源。
              // 4. ArrayBuffer表示资源的原始二进制数据。
              responseWeb.setResponseData($rawfile('img1.webp'));
              responseWeb.setResponseMimeType('image/webp');
              responseWeb.setResponseEncoding('utf-8');
              responseWeb.setResponseCode(200);
              responseWeb.setReasonMessage('OK');
              responseWeb.setResponseIsReady(true)
              return responseWeb
            }
          }
          // 返回响应数据则按照响应数据加载，无响应数据则返回null表示按照原来的方式加载
          return null;
        })
        .onPageBegin((event) => {
          // h5 开始加载
          if (event) {
            console.log(`onPageBegin: ${event.url}`);
            // 显示loading
            this.loadingVisibility = Visibility.Visible
          }
        })
        .onProgressChange((event) => {
          // h5 加载进度变化，100% 有可能走多次
          if (event) {
            console.log('newProgress:' + event.newProgress);
            // 显示loading 进度
            this.progress = event.newProgress
          }
        })
        .onPageEnd((event) => {
          // 推荐在此事件中执行JavaScript脚本
          if (event) {
            console.log('onPageEnd url:' + event.url);
            // 隐藏loading
            this.loadingVisibility = Visibility.None
          }
        })
        .javaScriptProxy({
          object: this.webTestObj,
          name: "objTestName",
          methodList: ["callNative"],
          controller: this.controller,
          asyncMethodList: ['asyncMethodList']
        })
        .onConsole((event) => {
          // h5的打印，可以在这里看到
          console.log(`H5自己的打印-${event?.message}`)
          return true
        })
        .onBeforeUnload((event) => {
          return true;
        })
        .onPermissionRequest((event) => {
          AlertDialog.show({
            title: 'title',
            message: 'text',
            primaryButton: {
              value: 'deny',
              action: () => {
                event?.request.deny();
              }
            },
            secondaryButton: {
              value: 'onConfirm',
              action: () => {
                event?.request.grant(event.request.getAccessibleResource());
              }
            },
            cancel: () => {
              event?.request.deny();
            }
          })
        })
      // .onAlert((event) => {
      //   promptAction.showToast({message:"1111"})
      //   return true
      // })
      // .onPageVisible((event) => {
      //   console.log('onPageVisible url:' + event.url);
      // })
      // .onRenderExited((event) => {
      //   if (event) {
      //     console.log('onRenderExited reason:' + event.renderExitReason);
      //   }
      // })
      // .onDisAppear(() => {
      //   console.log('onDisAppear : The web is hidden');
      //   promptAction.showToast({
      //     message: 'The web is hidden',
      //     duration: 2000
      //   })
      // })
      // .onAppear(() => {
      //   console.error(`onAppear :到达这里的时间：${Date.now() - this.currentTimestamp}`);
      // })
      // .onFirstContentfulPaint(event => {
      //   if (event) {
      //     console.error("onFirstContentfulPaint:" + JSON.stringify(event));
      //   }
      // })
      // .onFirstMeaningfulPaint(event => {
      //   if (event) {
      //     console.error("onFirstMeaningfulPaint:" + JSON.stringify(event));
      //   }
      // })
      // .onLargestContentfulPaint(event => {
      //   if (event) {
      //     console.error("onLargestContentfulPaint:" + JSON.stringify(event));
      //   }
      // })
      Button('调用js方法 无参数').onClick(() => {
        this.controller.runJavaScript('htmlTestHasParam(1)')
      })
      Button('调用js方法 有参数').onClick(() => {
        this.controller.runJavaScript('htmlTestNoParam()')
      }).margin({ top: 100 })
      Button('调用js方法 有返回值的').onClick(() => {
        this.controller.runJavaScript('getHtmlTest()').then((data) => {
          promptAction.showToast({ message: data })
        }).catch((error: BusinessError) => {
        })
      }).margin({ top: 200 })
      Progress({
        value: this.progress, // 当前进度
        // 形状 type: ProgressType.Ring//圆形
        // 形状 type: ProgressType.Linear//直角型
        // 其他太多了不看了
        type: ProgressType.Ring,
        total: 100
      })// 总进度 默认100
        .width(50)// 圆形设置了 status， value就不管用了
        .style({ strokeWidth: 5 }).visibility(this.loadingVisibility)

    }.height('100%')
    .width('100%')
  }

  aboutToDisappear(): void {
    console.error(`aboutToDisappear `);
  }
}

class WebObj {
  controller: webview.WebviewController;

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  // h5 调用 NA
  callNative(): string {
    promptAction.showToast({ message: 'web来了' })
    return "给h5返回值";
  }
}

class WebObjNew {
  controller: webview.WebviewController;

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  // h5 调用 NA
  callNativeNew(): string {
    promptAction.showToast({ message: 'web来了 另一个' })
    return "给h5返回值 另一个";
  }
}