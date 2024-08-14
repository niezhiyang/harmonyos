import { hilog } from '@kit.PerformanceAnalysisKit';
import { Logger } from '@nzy/logger';

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
        Logger.json(new TestJson(), this.tag)
      })
    }
    .height('100%')
    .width('100%')
  }
}