// 跳转页面入口函数
@Builder
export function PageOneBuilder() {
  PageOne()
}

@Component
struct PageOne {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
    }
    .title('PageOne')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}