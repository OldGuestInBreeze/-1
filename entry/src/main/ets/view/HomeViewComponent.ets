import { router } from '@kit.ArkUI';
import { getEventList } from '../api/EventApi';
import { EventComponent } from '../component/EventComponent';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { User } from '../viewmodel/User';

class EventType {
  name: string;
  icon: Resource;

  constructor(name: string, icon: Resource) {
    this.name = name;
    this.icon = icon;
  }
}

const typeList: EventType[] = [
  new EventType('附近', $r('app.media.ic_home_recommend')),
  new EventType('运动', $r('app.media.ic_home_motion')),
  new EventType('骑行', $r('app.media.ic_home_ride')),
  new EventType('郊游', $r('app.media.ic_home_excursion'))
];

@Preview
@Component
export default struct HomeViewComponent {
  @State eventList: Event[] = [];
  @Prop @Watch('onPageVisibilityChange') pageVisible: boolean = false;

  aboutToAppear(): void {
    this.getEvents();
  }

  onPageVisibilityChange(): void {
    if (this.pageVisible) {
      this.getEvents();
    }
  }

  private async getEvents(kw: string = ''): Promise<void> {
    let userId: number = 0;
    loginUserAction((user: User) => {
      userId = user.id;
    });

    const response = await getEventList(userId, kw);
    if (!response.success) {
      this.eventList = [];
      return;
    }

    const result = response.obj as Event[];
    const events: Event[] = [];
    result.forEach((item: Event) => {
      events.push(new Event(item.id, item.userId, item.name, item.intro, item.addr, item.headImg,
        item.startTime, item.lon, item.lat, item.state));
    });
    this.eventList = events;
  }

  build() {
    Column() {
      Search({
        placeholder: '搜索活动',
        value: ''
      })
        .width('90%')
        .height(36)
        .placeholderColor('#999999')
        .backgroundColor(Color.White)
        .fontColor('#333333')
        .borderRadius(20)
        .textAlign(TextAlign.Center)
        .margin({ top: 32 })
        .onSubmit((value: string) => {
          router.pushUrl({
            url: 'pages/EventListPage',
            params: {
              data: value
            }
          });
        })

      Swiper() {
        Image($r('app.media.ic_swiper_1'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Image($r('app.media.ic_swiper_2'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Image($r('app.media.ic_swiper_3'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('95%')
      .height(160)
      .margin({ top: 20 })
      .borderRadius(20)
      .autoPlay(true)
      .loop(true)

      Row() {
        ForEach(typeList, (item: EventType) => {
          Column() {
            Image(item.icon)
              .width(40)
              .height(40)

            Text(item.name)
              .fontSize(14)
              .fontColor('#333333')
              .padding({ top: 5 })
          }
          .layoutWeight(1)
          .onClick(() => {
            if (item.name === '附近') {
              router.pushUrl({
                url: 'pages/MapPage'
              });
              return;
            }

            router.pushUrl({
              url: 'pages/EventListPage',
              params: {
                data: item.name
              }
            });
          })
        }, (item: EventType) => item.name)
      }
      .width('90%')
      .height(68)
      .margin({ top: 10 })

      WaterFlow() {
        ForEach(this.eventList, (item: Event) => {
          FlowItem() {
            EventComponent({
              item: item
            })
          }
        }, (item: Event) => item.id.toString())
      }
      .layoutDirection(FlexDirection.Column)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('90%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.bg_home'))
    .backgroundImageSize({
      height: '20%',
      width: '100%'
    })
  }
}
