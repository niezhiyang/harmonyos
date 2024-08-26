import { router } from '@kit.ArkUI';
import { PathConstant } from '../constant/PathConstant';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  aboutToAppear(): void {

  }
  build() {
    Navigation() {
      Column() {
        Button('List').onClick(() => {
          router.pushUrl({ url: PathConstant.PATH_LIST })
        })
        Button('web').onClick(() => {
          router.pushUrl({ url: PathConstant.PATH_WEB })
        })
        Button('webAll').onClick(() => {
          router.pushUrl({ url: PathConstant.PATH_WEB_ALL })
        })
        Button('jsbridge').onClick(() => {
          router.pushUrl({ url: PathConstant.PATH_WEB_JSBRIDGE })
        })
        Button('offline').onClick(() => {
          router.pushUrl({ url: PathConstant.PATH_WEB_OFFLINE })
        })
        Button('navigation').onClick(() => {
          router.pushUrl({ url: 'pages/nav/NavigationDemoPage' })
        })
        Button('NetPage').onClick(() => {
          router.pushUrl({ url: 'pages/net/NetPage' })
        })
        Button('photo').onClick(() => {
          router.pushUrl({ url: 'pages/photo/PhotoPage' })
        })
        Button('LazyList').onClick(() => {
          router.pushUrl({ url: 'pages/list/LazyListPage' })
        })
        Button('water').onClick(() => {
          router.pushUrl({ url: 'pages/list/WaterPage' })
        })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .height('100%')
      .width('100%')
    }
    .mode(NavigationMode.Auto)

  }
}