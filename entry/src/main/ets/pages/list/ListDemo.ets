import { LoadMoreState, RefreshList } from '../../component/RefreshListOne';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ListDemo {
  @State message: string = 'Hello World';
  @State data: string[] = []
  @State isRefresh: boolean = false
  @State isLoadMore: boolean = false
  @State loadMoreState: LoadMoreState = LoadMoreState.None
  scroller: Scroller = new Scroller()
  index: number = 0

  aboutToAppear(): void {
    for (let index = 0; index < 15; index++) {
      // this.data.push(`${Math.floor(Math.random() * 100)}`)
      this.data.push(index.toString())
    }
    console.error('onPageShow')

  }

  @Builder
  listItem(item: string, index: number) {
    Text(item)
      .fontSize(30)
      .align(Alignment.Center)
      .height(100)
      .width('100%')
      .textAlign(TextAlign.Center)
      .onClick(() => {
        promptAction.showToast({ message: `点击的位置是：${index} , 内容是：${item}` })
      })
  }

  build() {
    RelativeContainer() {
      RefreshList({
        data: this.data,
        isRefresh: this.isRefresh,
        loadMoreState: this.loadMoreState,
        scroller: this.scroller,
        onLoadMore: () => {
          return new Promise<string>((resolve, reject) => {
            // 模拟网络请求操作
            setTimeout(() => {
              resolve('加载更多成功');
              console.log(`执行加载更多`)
              let arr2 = [`${this.index++}`, `${this.index++}`, `${this.index++}`, `${this.index++}`, `${this.index++}`]
              this.data.push(...arr2)
              this.isLoadMore = false
              if (this.index > 9) {
                this.loadMoreState = LoadMoreState.LoadEnd
              } else {
                this.loadMoreState = LoadMoreState.LoadFinish
              }
            }, 2000);
          });
        },
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            // 模拟网络请求操作
            setTimeout(() => {
              resolve('刷新成功');
              promptAction.showToast({ message: '刷新成功' })
              this.data = this.getData();
              this.isRefresh = false

            }, 2000);
          });
        },
        listItem: this.listItem
      }).height('100%').width('100%')
    }
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  getData(): string[] {
    let addData: string[] = []
    for (let index = 0; index < 20; index++) {
      addData.push(`${Math.floor(Math.random() * 100)}`)
    }
    return addData;
  }
}
