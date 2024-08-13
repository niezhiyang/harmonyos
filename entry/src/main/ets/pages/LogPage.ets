
import { Logger } from '../util/log/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { FaultLogger, hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';

class TestJson {
  name: string = '小刚'
  age: number = 18
}

// 现在 devcos studio 有bug
// 频繁打印日志，会有遗漏的
@Entry
@Component
struct LogPage {
  @State message: string = 'Hello World';
  private tag = 'LogPage'
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
    }
    .height('100%')
    .width('100%')
  }
}