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
      Button('web').onClick(() => {
        router.pushUrl({ url: PathConstant.PATH_WEB })
      })
      Button('webAll').onClick(() => {
        router.pushUrl({ url: PathConstant.PATH_WEB2 })
      })
      Button('jsbridge').onClick(() => {
        router.pushUrl({ url: "pages/web/JsBridgePage"})
      })
      Button('offline').onClick(() => {
        router.pushUrl({ url: "pages/web/offline/OfflineWebPage"})
      })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}