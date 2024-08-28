import { promptAction, window } from '@kit.ArkUI';
import { Logger } from '@nzy/logger';
import lottie from '@ohos/lottie';
import { FindPage } from './FindPage';
import { FirstPage } from './FirstPage';
import { PageMap } from './Glable';
import { MinePage } from './MinePage';
import { HashMap } from '@kit.ArkTS';

@Entry
@Component
struct NavigationDemoPage {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()
  @State selectIndex: number = 0;
  private renderingSettings1: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext1: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings1);
  private renderingSettings2: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext2: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings2);
  private renderingSettings3: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext3: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings3);
  private tabBarOption1: TabBarOption = {
    index: 0,
    text: "首页",
    name: 'tab1',
    path: 'common/lottie/tabbar1.json',
    canvasRenderingContext: this.canvasRenderingContext1
  };
  private tabBarOption2: TabBarOption = {
    index: 1,
    text: "发现",
    name: 'tab2',
    path: 'common/lottie/tabbar2.json',
    canvasRenderingContext: this.canvasRenderingContext2
  };
  private tabBarOption3: TabBarOption = {
    index: 2,
    text: "我的",
    name: 'tab3',
    path: 'common/lottie/tabbar3.json',
    canvasRenderingContext: this.canvasRenderingContext3
  };
  private arrPage: [] = []

  @Builder
  BottomTabBuilder(tabBarOptions: TabBarOption[]) {
    Row() {
      ForEach(tabBarOptions, (tabBarOption: TabBarOption, index: number) => {
        Column() {
          Canvas(tabBarOption.canvasRenderingContext)
            .width(40)
            .height(40)
            .onReady(() => {
              lottie.loadAnimation({
                container: tabBarOption.canvasRenderingContext,
                renderer: 'canvas',
                loop: false,
                autoplay: false,
                name: tabBarOption.name,
                path: tabBarOption.path,
              });
            })
          Text(tabBarOption.text)
            .fontSize(15)
            .fontWeight(500)
            .fontColor(this.selectIndex === tabBarOption.index ? "#0A59F7" : "#000000")
            .margin({ top: 4 })
        }
        .onClick(() => {
          if (this.selectIndex != index) {
            this.selectIndex = index
            this.lottieController();
          }
        })
        .height(80)
        .justifyContent(FlexAlign.Center)
        .onAppear(() => {
          this.lottieController();
        })
      })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Color.White)
    .height(80)
    .width("100%")

  }

  lottieController(): void {
    if (this.selectIndex === 0) {
      lottie.stop();
      lottie.play(this.tabBarOption1.name);
    }
    if (this.selectIndex === 1) {
      lottie.stop();
      lottie.play(this.tabBarOption2.name);
    }
    if (this.selectIndex === 2) {
      lottie.stop();
      lottie.play(this.tabBarOption3.name);
    }
  }

  build() {
    Column() {
      Navigation(this.pageStack) {
        if (this.selectIndex == 0) {
          FirstPage()
        } else if (this.selectIndex == 1) {
          FindPage()
        } else {
          MinePage()
        }
        // FirstPage().visibility(this.selectIndex == 0 ? Visibility.Visible : Visibility.Hidden)
        // FindPage().visibility(this.selectIndex == 1 ? Visibility.Visible : Visibility.Hidden)
        // MinePage().visibility(this.selectIndex == 2 ? Visibility.Visible : Visibility.Hidden)
      }
      .mode(NavigationMode.Auto)
      .navDestination(PageMap)
      .titleMode(NavigationTitleMode.Mini)
      .hideTitleBar(true)
      .height('100%')
      .toolbarConfiguration(this.BottomTabBuilder([this.tabBarOption1, this.tabBarOption2, this.tabBarOption3]))
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}


interface TabBarOption {
  index: number;
  text: string;
  name: string;
  path: string;
  canvasRenderingContext: CanvasRenderingContext2D;
}

