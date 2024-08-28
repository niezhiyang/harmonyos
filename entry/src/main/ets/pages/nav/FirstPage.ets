@Component
export struct FirstPage {
  @Consume('pageStack') pageStack: NavPathStack;

  build() {
    Column() {
      Text("首页").onClick(() => {
        this.pageStack.pushPath({ name: 'SecondPage', param: "参数" })
        // 带参数
        // this.pageInfos.pushPathByName('SecondPage', "参数")

        // // 带返回
        // this.pageInfos.pushPathByName('SecondPage', "参数", (popInfo) => {
        //   console.log('Pop page name is: ' + popInfo.info.name + ', result: ' + JSON.stringify(popInfo.result))
        // })
      })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}