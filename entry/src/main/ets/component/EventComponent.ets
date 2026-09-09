import { router } from '@kit.ArkUI';
import { BaseUrl } from '../common/Constant';
import { Event } from '../viewmodel/Event';

@Component
export struct EventComponent {
  @Prop item: Event;

  build() {
    Column() {
      Image(`${BaseUrl}${this.item.headImg}`)
        .width('100%')
        .constraintSize({
          maxHeight: 240
        })
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/EventInfoPage',
            params: {
              data: this.item.id,
              message: '活动详情'
            }
          });
        })

      Text(this.item.name)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 5 })
        .fontColor('#333333')
        .fontSize(16)
        .width('90%')
        .textAlign(TextAlign.Start)

      Text(this.item.addr)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 3, bottom: 5 })
        .fontColor('#666666')
        .fontSize(14)
        .width('90%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
