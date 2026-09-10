import { router } from '@kit.ArkUI';
import { getEventList } from '../api/EventApi';
import { EventComponent } from '../component/EventComponent';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { RouterParam } from '../viewmodel/RouterParam';
import { User } from '../viewmodel/User';

@Entry
@Component
struct EventListPage {
  @State keyword: string = '';
  @State eventList: Event[] = [];
  @State loading: boolean = false;
  @State loadFailed: boolean = false;

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<string>;
    if (param !== undefined && param.data !== undefined) {
      this.keyword = param.data.trim();
    }
    this.loadEvents();
  }

  private async loadEvents(): Promise<void> {
    if (this.loading) {
      return;
    }

    let userId: number = 0;
    loginUserAction((user: User) => {
      userId = user.id;
    });

    this.loading = true;
    this.loadFailed = false;
    const response = await getEventList(userId, this.keyword);
    if (!response.success) {
      this.eventList = [];
      this.loadFailed = true;
      this.loading = false;
      return;
    }

    if (!Array.isArray(response.obj)) {
      this.eventList = [];
      this.loadFailed = true;
      this.loading = false;
      return;
    }

    const result = response.obj as Event[];
    const events: Event[] = [];
    result.forEach((item: Event) => {
      events.push(new Event(item.id, item.userId, item.name, item.intro, item.addr, item.headImg,
        item.startTime, item.lon, item.lat, item.state));
    });
    this.eventList = events;
    this.loading = false;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back();
          })

        Text(this.keyword.length > 0 ? this.keyword : '全部活动')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .margin({ left: 20 })

        Blank()
      }
      .width('100%')
      .height(82)
      .padding({ top: 24, left: 16, right: 16 })
      .backgroundColor('#FF3551')

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#FF3551')

          Text('正在搜索活动')
            .fontSize(14)
            .fontColor('#888888')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.loadFailed) {
        Column() {
          Text('活动搜索失败')
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
              this.loadEvents();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.eventList.length === 0) {
        Column() {
          Text('没有找到相关活动')
            .fontSize(16)
            .fontColor('#888888')

          Text('换个关键词试试')
            .fontSize(13)
            .fontColor('#AAAAAA')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Grid() {
          ForEach(this.eventList, (item: Event) => {
            GridItem() {
              EventComponent({
                item: item
              })
            }
          }, (item: Event) => item.id.toString())
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('92%')
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F7F7F7')
  }
}
