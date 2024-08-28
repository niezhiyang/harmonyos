@Component
export struct MinePage {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    Column() {
      Text("我的")
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}