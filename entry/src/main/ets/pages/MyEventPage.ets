import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { deleteEvent, getMyEventList } from '../api/EventApi';
import { BaseUrl } from '../common/Constant';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { User } from '../viewmodel/User';

@Entry
@Component
struct MyEventPage {
  @State eventList: Event[] = [];
  @State loading: boolean = false;
  @State deletingId: number = 0;

  onPageShow(): void {
    loginUserAction((user: User) => {
      this.loadEvents(user.id);
    }, () => {
      showText('请先登录', () => {
        router.back();
      });
    });
  }

  private async loadEvents(userId: number): Promise<void> {
    if (this.loading) {
      return;
    }

    this.loading = true;
    try {
      const result = await getMyEventList(userId);
      if (!result.success) {
        this.eventList = [];
        showText(result.info.length > 0 ? result.info : '活动列表加载失败');
        return;
      }

      if (!Array.isArray(result.obj)) {
        this.eventList = [];
        showText('活动列表数据异常');
        return;
      }

      const responseList = result.obj as Event[];
      const events: Event[] = [];
      responseList.forEach((item: Event) => {
        events.push(new Event(item.id, item.userId, item.name, item.intro, item.addr, item.headImg,
          item.startTime, item.lon, item.lat, item.state));
      });
      this.eventList = events;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load user events. Code: ${businessError.code}, message: ${businessError.message}`);
      showText(businessError.message.length > 0 ? businessError.message : '活动列表加载失败');
    } finally {
      this.loading = false;
    }
  }

  private confirmDelete(eventId: number): void {
    if (this.deletingId > 0) {
      return;
    }

    AlertDialog.show({
      message: '您确定要删除这个活动吗？',
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '确定',
        action: () => {
          this.removeEvent(eventId);
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  private async removeEvent(eventId: number): Promise<void> {
    this.deletingId = eventId;
    try {
      const result = await deleteEvent(eventId);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : '删除失败');
        return;
      }

      this.eventList = this.eventList.filter((item: Event) => item.id !== eventId);
      showText(result.info.length > 0 ? result.info : '删除成功');
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to delete event. Code: ${businessError.code}, message: ${businessError.message}`);
      showText(businessError.message.length > 0 ? businessError.message : '删除失败');
    } finally {
      this.deletingId = 0;
    }
  }

  @Builder
  EventCard(item: Event) {
    Row() {
      Image(`${BaseUrl}${item.headImg}`)
        .width(145)
        .height(92)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.name)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#292929')

        Row() {
          Image($r('app.media.event_position'))
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain)

          Text(item.addr)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(13)
            .fontColor('#777777')
            .margin({ left: 4 })
        }
        .width('100%')
        .height(26)
        .padding({ left: 5, right: 5 })
        .margin({ top: 7 })
        .borderRadius(4)
        .backgroundColor('#F5F5F5')

        Row() {
          Text('编辑')
            .fontSize(14)
            .fontColor('#333333')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/EventEditPage',
                params: {
                  message: 'edit',
                  data: item
                }
              });
            })

          Text(this.deletingId === item.id ? '删除中' : '删除')
            .fontSize(14)
            .fontColor('#FF3551')
            .margin({ left: 14 })
            .onClick(() => {
              this.confirmDelete(item.id);
            })
        }
        .width('100%')
        .margin({ top: 10 })
      }
      .layoutWeight(1)
      .height(92)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('92%')
    .height(116)
    .padding(12)
    .margin({ top: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 5,
      color: '#12000000',
      offsetX: 0,
      offsetY: 2
    })
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

        Text('管理活动')
          .fontSize(23)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .margin({ left: 20 })

        Blank()
      }
      .width('100%')
      .height(82)
      .padding({ top: 24, left: 16, right: 16 })
      .backgroundColor('#FF3551')

      if (this.loading && this.eventList.length === 0) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#FF3551')

          Text('正在加载活动')
            .fontSize(14)
            .fontColor('#888888')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.eventList.length === 0) {
        Column() {
          Text('暂无创建的活动')
            .fontSize(16)
            .fontColor('#888888')

          Button('发布活动')
            .height(38)
            .fontSize(15)
            .fontColor(Color.White)
            .backgroundColor('#FF3551')
            .borderRadius(20)
            .margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/EventEditPage',
                params: {
                  message: 'add'
                }
              });
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.eventList, (item: Event) => {
            ListItem() {
              this.EventCard(item);
            }
          }, (item: Event) => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Off)
        .padding({ bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F7F7')
  }
}
