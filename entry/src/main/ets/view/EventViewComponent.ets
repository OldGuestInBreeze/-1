import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getMyTeamList } from '../api/EventApi';
import { NoLoginComponent } from '../component/NoLoginComponent';
import { BaseUrl } from '../common/Constant';
import { loginUserAction } from '../utils/UserUtil';
import { Team } from '../viewmodel/Team';
import { User } from '../viewmodel/User';

@Component
export default struct EventViewComponent {
  @State teamList: Team[] = [];
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  @StorageProp('isLogin') isLogin: boolean = false;
  @Prop @Watch('onPageVisibilityChange') pageVisible: boolean = false;

  aboutToAppear(): void {
    this.getEventList();
  }

  onPageVisibilityChange(): void {
    if (this.pageVisible) {
      this.getEventList();
    }
  }

  private getEventList(): void {
    if (!this.isLogin) {
      this.teamList = [];
      this.loading = false;
      this.loadFailed = false;
      return;
    }

    loginUserAction((user: User) => {
      this.loadTeams(user.id);
    });
  }

  private async loadTeams(userId: number): Promise<void> {
    this.loading = true;
    this.loadFailed = false;
    try {
      const response = await getMyTeamList(userId);
      if (!response.success) {
        this.teamList = [];
        this.loadFailed = true;
        return;
      }

      if (!Array.isArray(response.obj)) {
        this.teamList = [];
        this.loadFailed = true;
        return;
      }

      const result = response.obj as Team[];
      const teams: Team[] = [];
      result.forEach((item: Team) => {
        teams.push(new Team(item.eventId, item.eventName, item.createUserId, item.userInfoName,
          item.memberCount, item.headImg, item.addr));
      });
      this.teamList = teams;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load teams. Code: ${businessError.code}, message: ${businessError.message}`);
      this.teamList = [];
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  private openEvent(eventId: number): void {
    router.pushUrl({
      url: 'pages/EventInfoPage',
      params: {
        data: eventId
      }
    });
  }

  private openMembers(eventId: number): void {
    router.pushUrl({
      url: 'pages/TeamListPage',
      params: {
        data: eventId
      }
    });
  }

  @Builder
  teamCard(item: Team) {
    Row() {
      Image(`${BaseUrl}${item.headImg}`)
        .alt($r('app.media.ic_swiper_1'))
        .width(128)
        .height(80)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.openEvent(item.eventId);
        })

      Column() {
        Text(item.eventName)
          .width('100%')
          .fontSize(16)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .onClick(() => {
            this.openEvent(item.eventId);
          })

        Row() {
          Image($r('app.media.event_position'))
            .width(14)
            .height(14)

          Text(item.addr)
            .fontSize(13)
            .fontColor('#777777')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .margin({ left: 3 })
        }
        .width('100%')
        .height(24)
        .padding({ left: 4, right: 4 })
        .margin({ top: 8 })
        .borderRadius(3)
        .backgroundColor('#F5F5F5')
        .onClick(() => {
          this.openEvent(item.eventId);
        })

        Row() {
          Row() {
            Image($r('app.media.ic_group_grey600_18dp'))
              .width(14)
              .height(14)

            Text('活动成员')
              .fontSize(13)
              .fontColor('#777777')
              .margin({ left: 3 })
          }
          .height(24)
          .padding({ left: 4, right: 4 })
          .borderRadius(3)
          .backgroundColor('#F5F5F5')

          Text(`${item.memberCount}人`)
            .fontSize(13)
            .fontColor('#555555')
            .margin({ left: 6 })
        }
        .width('100%')
        .margin({ top: 5 })
        .onClick(() => {
          this.openMembers(item.eventId);
        })
      }
      .layoutWeight(1)
      .height(80)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
    }
    .width('92%')
    .height(100)
    .padding({ left: 9, right: 9, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(7)
  }

  build() {
    Column() {
      if (this.isLogin) {
        Text('我的活动')
          .width('100%')
          .height(54)
          .fontSize(23)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(34)
              .height(34)
              .color('#FF3551')

            Text('正在加载活动')
              .fontSize(14)
              .fontColor('#777777')
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.loadFailed) {
          Column() {
            Text('活动加载失败')
              .fontSize(17)
              .fontColor('#333333')

            Button('重新加载')
              .height(40)
              .fontSize(15)
              .backgroundColor('#FF3551')
              .margin({ top: 15 })
              .onClick(() => {
                this.getEventList();
              })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.teamList.length === 0) {
          Column() {
            Text('暂无参加的活动')
              .fontSize(16)
              .fontColor('#777777')
          }
            .layoutWeight(1)
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
        } else {
          List({
            space: 8
          }) {
            ForEach(this.teamList, (item: Team) => {
              ListItem() {
                this.teamCard(item);
              }
            }, (item: Team) => item.eventId.toString())
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .alignListItem(ListItemAlign.Center)
          .scrollBar(BarState.Off)
        }
      } else {
        NoLoginComponent()
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
