import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getEventInfo } from '../api/EventApi';
import { BaseUrl } from '../common/Constant';
import { Event } from '../viewmodel/Event';
import { RouterParam } from '../viewmodel/RouterParam';

@Entry
@Component
struct EventInfoPage {
  @State item: Event = new Event(0, 0, '', '', '', '', '', 0, 0, 0);
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  private eventId: number = 0;

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<number>;
    if (param === undefined || param.data === undefined || param.data <= 0) {
      this.loadFailed = true;
      return;
    }
    this.eventId = param.data;
  }

  onPageShow(): void {
    if (this.eventId > 0) {
      this.loadEvent();
    }
  }

  private async loadEvent(): Promise<void> {
    if (this.loading) {
      return;
    }

    this.loading = true;
    this.loadFailed = false;
    try {
      const response = await getEventInfo(this.eventId);
      if (!response.success) {
        this.loadFailed = true;
        return;
      }

      const event = response.obj as Event;
      this.item = new Event(event.id, event.userId, event.name, event.intro, event.addr, event.headImg,
        event.startTime, event.lon, event.lat, event.state);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load event details. Code: ${businessError.code}, message: ${businessError.message}`);
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  @Builder
  PageHeader() {
    Row() {
      Image($r('app.media.ic_return_white'))
        .width(30)
        .height(30)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          router.back();
        })

      Text('活动详情')
        .fontSize(21)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Blank()
        .width(30)
    }
    .width('100%')
    .height(82)
    .padding({ top: 24, left: 14, right: 14 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.loading || this.loadFailed ? '#FF3551' : '#00000000')
  }

  @Builder
  BottomBar() {
    Row() {
      Column() {
        Image($r('app.media.ic_eventinfo_share'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)

        Text('分享')
          .fontSize(13)
          .fontColor('#333333')
          .margin({ top: 2 })
      }
      .width(64)

      Column() {
        Image($r('app.media.ic_eventinfo_commit'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)

        Text('评论')
          .fontSize(13)
          .fontColor('#333333')
          .margin({ top: 2 })
      }
      .width(64)

      Button('+加入')
        .layoutWeight(1)
        .height(44)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#FF3551')
        .borderRadius(24)
        .margin({ left: 12, right: 14 })
    }
    .width('100%')
    .height(72)
    .padding({ left: 6 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 5,
      color: '#18000000',
      offsetX: 0,
      offsetY: -2
    })
  }

  @Builder
  EventDetails() {
    Column() {
      Text(this.item.name)
        .width('100%')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#292929')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.item.startTime.length > 0) {
        Row() {
          Image($r('app.media.startIcon'))
            .width(17)
            .height(17)
            .objectFit(ImageFit.Contain)

          Text(this.item.startTime)
            .layoutWeight(1)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 6 })
        }
        .width('100%')
        .margin({ top: 14 })
      }

      Row() {
        Image($r('app.media.event_position'))
          .width(17)
          .height(17)
          .objectFit(ImageFit.Contain)

        Text(this.item.addr)
          .layoutWeight(1)
          .fontSize(14)
          .fontColor('#777777')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 6 })
      }
      .width('100%')
      .padding({ left: 7, right: 7, top: 5, bottom: 5 })
      .margin({ top: 12 })
      .backgroundColor('#F5F5F5')
      .borderRadius(5)

      Text(this.item.intro)
        .width('100%')
        .fontSize(16)
        .fontColor('#333333')
        .lineHeight(24)
        .margin({ top: 12 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 25, bottom: 30 })
  }

  build() {
    Stack() {
      Column() {
        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(38)
              .height(38)
              .color('#FF3551')

            Text('正在加载活动详情')
              .fontSize(14)
              .fontColor('#888888')
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.loadFailed) {
          Column() {
            Text('活动详情加载失败')
              .fontSize(16)
              .fontColor('#888888')

            Button('重新加载')
              .height(38)
              .fontSize(15)
              .fontColor(Color.White)
              .backgroundColor('#FF3551')
              .borderRadius(20)
              .margin({ top: 16 })
              .onClick(() => {
                if (this.eventId > 0) {
                  this.loadEvent();
                } else {
                  router.back();
                }
              })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Stack() {
            if (this.item.headImg.length > 0) {
              Image(`${BaseUrl}${this.item.headImg}`)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.bg_eventinfo'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            }

            this.PageHeader()
          }
          .width('100%')
          .height(250)
          .alignContent(Alignment.Top)

          Scroll() {
            this.EventDetails()
          }
          .layoutWeight(1)
          .width('100%')
          .margin({ top: -28 })
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 28, topRight: 28 })
          .scrollBar(BarState.Off)

          this.BottomBar()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F7F7F7')

      if (this.loading || this.loadFailed) {
        this.PageHeader()
      }
    }
    .width('100%')
    .height('100%')
  }
}
