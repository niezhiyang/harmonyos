import { webview } from '@kit.ArkWeb';
import { fileIo as fs } from '@kit.CoreFileKit';
import { OfflineUtil } from './OfflineUtil';


@Entry
@Component
struct OfflineWebPage {
  @State message: string = 'Hello World';
  // @State url: string | Resource = 'https://www.huawei.com/cn'
  // @State url: string | Resource = 'https://www.csdn.net/'
  @State url: string | Resource = 'https://juejin.cn/'
  controller: webview.WebviewController = new webview.WebviewController();
  startTime: number = 0

  aboutToAppear(): void {
    OfflineUtil.instance.init()
  }

  build() {
    RelativeContainer() {
      Web({ src: this.url, controller: this.controller })
        .fileAccess(true)// 是否可以读存储的html，api11 默认是true ，api12 默认是false $rawfile 不受影响
        .zoomAccess(false)// 设置是否支持手势进行缩放 默认允许，咱们app一般不允许
        .databaseAccess(true)//设置是否开启数据库存储API权限，默认不开启
        .cacheMode(CacheMode.Online)// 设置成只从网络读取，不读取缓存
        .onPageBegin(() => {
          this.startTime = new Date().getTime()
        })
        .onPageEnd(() => {
          console.log(`从onPageBegin到onPageEnd 事件是 ${new Date().getTime() - this.startTime}`)
        })
        .onInterceptRequest((event) => {
          if (event) {
            let responseWeb = OfflineUtil.instance.getLocalFile(event.request.getRequestUrl());
            return responseWeb
          }
          return null
        })
        .width('100%')
        .height('100%')
    }
    .height('100%')
    .width('100%')
  }
}





