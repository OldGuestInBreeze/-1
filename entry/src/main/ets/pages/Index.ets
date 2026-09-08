@Entry
@Component
struct Index {
  @State selectedIndex: number = 0;

  @Builder
  navigationItem(index: number, title: string, selectedIcon: Resource, normalIcon: Resource) {
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
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedIndex = index;
    })
  }

  build() {
    Column() {
      Blank()
        .layoutWeight(1)

      Row() {
        this.navigationItem(
          0,
          '首页',
          $r('app.media.ic_home_on'),
          $r('app.media.ic_home_off')
        )
        this.navigationItem(
          1,
          '活动',
          $r('app.media.ic_event_on'),
          $r('app.media.ic_event_off')
        )
        this.navigationItem(
          2,
          '好友',
          $r('app.media.ic_friends_on'),
          $r('app.media.ic_friends_off')
        )
        this.navigationItem(
          3,
          '我的',
          $r('app.media.ic_mine_on'),
          $r('app.media.ic_mine_off')
        )
      }
      .width('100%')
      .height(62)
      .backgroundColor(Color.White)
      .shadow({
        radius: 5,
        color: '#10000000',
        offsetX: 0,
        offsetY: -1
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}