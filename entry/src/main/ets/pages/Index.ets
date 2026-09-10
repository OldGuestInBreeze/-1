import HomeViewComponent from '../view/HomeViewComponent';
import EventViewComponent from '../view/EventViewComponent';
import { UserInfoViewComponent } from '../view/UserInfoViewComponent';

@Entry
@Component
struct Index {
  @State selectedIndex: number = 0;
  @State pageVisible: boolean = false;

  onPageShow(): void {
    this.pageVisible = true;
  }

  onPageHide(): void {
    this.pageVisible = false;
  }

  @Builder
  tabBarItem(index: number, title: string, selectedIcon: Resource, normalIcon: Resource) {
    Column() {
      Image(this.selectedIndex === index ? selectedIcon : normalIcon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)

      Text(title)
        .fontSize(12)
        .fontColor(this.selectedIndex === index ? '#FF3B5C' : '#111111')
        .margin({ top: 3 })
    }
    .width('100%')
    .height(62)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      index: this.selectedIndex
    }) {
      TabContent() {
        HomeViewComponent({
          pageVisible: this.pageVisible && this.selectedIndex === 0
        })
      }
      .tabBar(this.tabBarItem(
        0,
        '首页',
        $r('app.media.ic_home_on'),
        $r('app.media.ic_home_off')
      ))

      TabContent() {
        EventViewComponent({
          pageVisible: this.pageVisible && this.selectedIndex === 1
        })
      }
      .tabBar(this.tabBarItem(
        1,
        '活动',
        $r('app.media.ic_event_on'),
        $r('app.media.ic_event_off')
      ))

      TabContent() {
        Column() {
          Blank()
        }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.White)
      }
      .tabBar(this.tabBarItem(
        2,
        '好友',
        $r('app.media.ic_friends_on'),
        $r('app.media.ic_friends_off')
      ))

      TabContent() {
        UserInfoViewComponent()
      }
      .tabBar(this.tabBarItem(
        3,
        '我的',
        $r('app.media.ic_mine_on'),
        $r('app.media.ic_mine_off')
      ))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .barWidth('100%')
    .barHeight(62)
    .animationDuration(0)
    .divider({ strokeWidth: 0 })
    .backgroundColor(Color.White)
    .onChange((index: number) => {
      this.selectedIndex = index;
    })
  }
}
