import { router } from '@kit.ArkUI';
import { PathConstant } from '../constant/PathConstant';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button('List').onClick(() => {
        router.pushUrl({ url: PathConstant.PATH_LIST })
      })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}