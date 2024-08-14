import { LoadMoreState, RefreshList } from '../../component/RefreshList';
import { promptAction } from '@kit.ArkUI';
import { Logger } from '@nzy/logger';

export class MyData {
  age: number = 0

  constructor(age: number) {
    this.age = age
  }
}

@Entry
@Component
struct ListDemo {
  @State message: string = 'Hello World';
  @State data: MyData[] = []
  @State isRefresh: boolean = false
  @State loadMoreState: LoadMoreState = LoadMoreState.None
  scroller: Scroller = new Scroller()
  index: number = 0

  aboutToAppear(): void {
    for (let index = 0; index < 15; index++) {
      // this.data.push(`${Math.floor(Math.random() * 100)}`)
      this.data.push(new MyData(index))
    }
    console.error('onPageShow')

  }

  @Builder
  listItem(item: Object, index: number) {
    Text((item as MyData).age.toString())
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
              Logger.info(`执行加载更多`)
              let arr2 =
                [new MyData(this.index++), new MyData(this.index++), new MyData(this.index++), new MyData(this.index++),
                  new MyData(this.index++)]
              this.data.push(...arr2)
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

  getData(): MyData[] {
    let addData: MyData[] = []
    for (let index = 0; index < 20; index++) {
      addData.push(new MyData(Math.floor(Math.random() * 100)))
    }
    return addData;
  }
}
