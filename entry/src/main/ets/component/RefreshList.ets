import { JSON } from '@kit.ArkTS'
import { Logger } from '@nzy/logger'
import { MyData } from '../pages/list/ListDemo'
import { BaseListData } from './BaseListData'

const OFFSET = 60

export enum LoadMoreState {
  None,
  Loading,
  LoadFinish,
  LoadEnd,
  LoadFail,
}
@Component
@Preview
export struct  RefreshList  {
  // 数据源
  @Watch('onDataChange')
  @Link data: Object[]
  @Require scroller: Scroller = new Scroller()
  // 加载更多的回调
  @Require onLoadMore: () => void = () => {
  }
  // 刷新的时候回调
  @Require onRefresh: () => void = () => {
  }
  // 是否正在刷新
  @Link isRefresh: boolean
  // 加载更多的枚举
  @Watch('onLoadMoreStateChange')
  @Link loadMoreState: LoadMoreState

  // list 单个item
  @BuilderParam listItem: (item: Object, index: number) => void
  // 刷新的文案
  @State refreshText: string = '加载中。。。'
  @State loadingText: string = '正在加载。。。'
  // 刷新文案左边的图片
  @State refreshIcon: PixelMap | ResourceStr | DrawableDescriptor = $r("app.media.arrow_down")


  onDataChange() {
    Logger.info(`data 发生了变化 - ${this.data}`)
  }

  onLoadMoreStateChange() {
    Logger.info(`loadMoreState 发生了变化 - ${this.loadMoreState}`)
    switch (this.loadMoreState) {
      case LoadMoreState.Loading:
        this.loadingText = '正在加载。。。'
        break
      case LoadMoreState.LoadEnd:
        this.loadingText = '已经加载全部了'
        break
      case LoadMoreState.LoadFail:
        this.loadingText = '加载失败'
        break
    }
  }

  // 下拉刷新的自定义builder
  @Builder
  refreshBuild() {
    Row({ space: 10 }) {
      if (this.isRefresh) {
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(40).color(Color.Gray)
          .style({ strokeWidth: 5, status: ProgressStatus.LOADING })
      } else {
        Image(this.refreshIcon).width(50).height(50)
      }
      Text(this.refreshText)
    }.alignItems(VerticalAlign.Center)
  }

  @Builder
  loadMore() {
    ListItem() {
      Row() {
        // 如果是正在加载更多显示个loading
        if (this.loadMoreState == LoadMoreState.Loading) {
          LoadingProgress().width(30).height(30)
        }
        // 加载更多的文案
        Text(this.loadingText)
          .fontSize(20)
          .align(Alignment.Center)
          .height(100)
          .textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width('100%')
    }
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefresh, builder: this.refreshBuild }) {
        List({ scroller: this.scroller }) {
          ForEach(this.data, (item: string, index: number) => {
            ListItem() {
              this.listItem(item, index)
            }
          }, (item: string) => item)
          // 添加loadmore
          this.loadMore()
        }
        .onScrollIndex((start: number, end: number, center: number) => {
          // 有子组件划入或划出List显示区域时触发。从API version 10开始，List显示区域中间位置子组件变化时也会触发
          if (end >= this.data.length - 1) {
            // 显示加载
            Logger.info(`end = ${end} length = ${this.data.length} this.loadMoreState=>${this.loadMoreState}`)
            // 如果是初始化状态，或者 加载更多的时候，进去刷新
            if (this.loadMoreState == LoadMoreState.LoadFinish || this.loadMoreState == LoadMoreState.None) {
              this.loadMoreState = LoadMoreState.Loading
              this.onLoadMore()
            }
          }
        })
        .width('100%')
        .height('100%')
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        switch (refreshStatus) {
          case RefreshStatus.Inactive:
          // 默认未下拉状态
            break
          case RefreshStatus.Drag:
          //下拉中，下拉距离小于刷新距离。
            this.refreshText = '继续下拉加载'
            this.refreshIcon = $r("app.media.arrow_down")

            break
          case RefreshStatus.OverDrag:
          // 下拉中，下拉距离超过刷新距离。
            this.refreshText = '松手即可加载'
            this.refreshIcon = $r("app.media.arrow_up")
            break
          case RefreshStatus.Refresh:
          //下拉结束，回弹至刷新距离，进入刷新状态。
            this.refreshText = '加载中。。。'
            break
          case RefreshStatus.Done:
          // 刷新结束，返回初始状态（顶部）。
          //下拉结束，回弹至刷新距离，进入刷新状态。
            this.refreshText = '成功'
            this.refreshIcon = $r("app.media.refresh_success")
            break
        }
        console.info('Refresh onStatueChange state is ' + refreshStatus)
      })
      .onRefreshing(this.onRefresh)
      .refreshOffset(OFFSET)
      .pullToRefresh(true)
    }

  }
}
