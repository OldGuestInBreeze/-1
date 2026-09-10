import { router } from '@kit.ArkUI';

@Component
export struct NoLoginComponent {
  build() {
    Column() {
      Text('未登录')
        .fontSize(24)
        .fontColor('#0F172A')
        .height(50)
        .lineHeight(50)
        .fontWeight(FontWeight.Medium)

      Text('请先登录！')
        .fontSize(16)
        .fontColor('#64748B')
        .height(30)
        .lineHeight(30)

      Button('去登录')
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#FF3551')
        .height(56)
        .width(238)
        .borderRadius(12)
        .margin({ top: 28 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/LoginPage'
          });
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}
