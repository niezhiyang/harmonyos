// 跳转页面入口函数
// todo 方式2
@Builder
export function PageOneBuilder() {
  SecondPage()
}
@Component
export struct SecondPage {
  @Consume('pageStack') pageStack: NavPathStack;
  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Text("Dialog NavDestination")
            .fontSize(20)
            .margin({ bottom: 100 })
          Button("Close").onClick(() => {
            this.pageStack.pop()
            // // 返回到上一页
            // this.pageStack.pop()
            // // 返回到上一个PageOne页面
            // this.pageStack.popToName("PageOne")
            // // 返回到索引为1的页面
            // this.pageStack.popToIndex(1)
            // // 返回到根首页（清除栈中所有页面）
            // this.pageStack.clear()
          }).width('30%')
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .height('30%')
        .width('80%')
      }.height("100%").width('100%')
    }.onReady((context: NavDestinationContext)=>{
      // todo 方式2
      this.pageStack = context.pathStack
    })
    // 隐藏 TitleBar 包括返回按钮和标题
    // .hideTitleBar(true)
  }
}