import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { Logger } from '../../util/log/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';


@Entry
@Component
struct NetPage {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    for(let index = 0; index<1000;index++){
      hilog.info(0x1111,'index',`----${index}-----`)
    }
  }

  build() {
    Column() {
      Button('get').onClick(() => {
        let request = http.createHttp()
        request.request('https://wanandroid.com/harmony/index/json',
          { method: http.RequestMethod.GET })
          .then((data) => {
            // 将 JSON 字符串解析为对象
            let jsonObject: object | null = JSON.parse(data.result as string);
            Logger.json('response', jsonObject)
            this.message = JSON.stringify(jsonObject, null, 2)
          }).catch((error: BusinessError) => {
        })

      })
      Scroll() {
        Text(this.message)
      }
    }
    .height('100%')
    .width('100%')
  }
}
