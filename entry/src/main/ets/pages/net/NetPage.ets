import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FaultLogger, hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';
import { Logger } from '../../util/log/Logger';

class TestJson {
  name: string = '小刚'
  age: number = 18
}

@Entry
@Component
struct NetPage {
  @State message: string = 'Hello World';
  private tag = 'NetPage'

  build() {
    Column() {
      Button(`json`).onClick(() => {
        Logger.json(this.tag, new TestJson())
      })
      Button(`debug`).onClick(() => {
        Logger.debug(this.tag, '我是debug')
      })
      Button(`info`).onClick(() => {
        Logger.info(this.tag, '我是info')
      })
      Button(`warn`).onClick(() => {
        Logger.warn(this.tag, '我是warn')
      })
      Button(`error`).onClick(() => {
        Logger.error(this.tag, '我是error')
      })
      Button(`error`).onClick(() => {
        for (let i = 0; i < 1000; i++) {
          hilog.debug(0x002, '1111', `----${i}----`)
        }
      })
      Button('get').onClick(() => {
        let request = http.createHttp()
        request.request('https://wanandroid.com/harmony/index/json',
          { method: http.RequestMethod.GET, header: { 'Accept': 'application/json' } })
          .then((data) => {
            // 将 JSON 字符串解析为对象
            let jsonObject: object | null = JSON.parse(data.result as string);
            Logger.json(this.tag, jsonObject)
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