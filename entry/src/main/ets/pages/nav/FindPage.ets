@Component
export struct FindPage {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    Column() {
      Text("发现")
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}