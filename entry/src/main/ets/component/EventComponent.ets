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
        .height(132)
        .borderRadius({
          topLeft: 12,
          topRight: 12
        })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(this.item.name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor('#262626')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)

        Row() {
          Image($r('app.media.event_position'))
            .width(14)
            .height(14)
            .margin({ right: 4 })

          Text(this.item.addr)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor('#8A8A8A')
            .fontSize(12)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .width('100%')
      .padding({
        left: 10,
        right: 10,
        top: 9,
        bottom: 10
      })
    }
    .width('100%')
    .height(190)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 5,
      color: '#18000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/EventInfoPage',
        params: {
          data: this.item.id,
          message: '活动详情'
        }
      });
    })
  }
}
