import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getApplyList, getFriendList } from '../api/FriendApi';
import { NoLoginComponent } from '../component/NoLoginComponent';
import { BaseUrl } from '../common/Constant';
import { loginUserAction } from '../utils/UserUtil';
import { User } from '../viewmodel/User';

@Component
export struct FriendViewComponent {
  @State friendList: User[] = [];
  @State applyList: User[] = [];
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  @StorageProp('isLogin') isLogin: boolean = false;
  @Prop @Watch('onPageVisibilityChange') pageVisible: boolean = false;

  aboutToAppear(): void {
    this.loadFriendData();
  }

  onPageVisibilityChange(): void {
    if (this.pageVisible) {
      this.loadFriendData();
    }
  }

  private loadFriendData(): void {
    if (!this.isLogin) {
      this.friendList = [];
      this.applyList = [];
      this.loading = false;
      this.loadFailed = false;
      return;
    }

    loginUserAction((user: User) => {
      this.loadUserRelations(user.id);
    }, () => {
      this.friendList = [];
      this.applyList = [];
      this.loading = false;
      this.loadFailed = false;
    });
  }

  private normalizeUsers(items: User[]): User[] {
    const users: User[] = [];
    items.forEach((item: User) => {
      users.push(new User(
        item.id === undefined || item.id === null ? 0 : item.id,
        item.username === undefined || item.username === null ? '' : item.username,
        item.name === undefined || item.name === null ? '' : item.name,
        item.headImg === undefined || item.headImg === null ? '' : item.headImg,
        item.addr === undefined || item.addr === null ? '' : item.addr,
        item.gender === undefined || item.gender === null ? '' : item.gender,
        item.lon === undefined || item.lon === null ? 0 : item.lon,
        item.lat === undefined || item.lat === null ? 0 : item.lat
      ));
    });
    return users;
  }

  private async loadUserRelations(userId: number): Promise<void> {
    this.loading = true;
    this.loadFailed = false;
    try {
      const friendResponse = await getFriendList(userId);
      if (!friendResponse.success || !Array.isArray(friendResponse.obj)) {
        this.friendList = [];
        this.applyList = [];
        this.loadFailed = true;
        return;
      }
      this.friendList = this.normalizeUsers(friendResponse.obj as User[]);

      const applyResponse = await getApplyList(userId);
      if (applyResponse.success && Array.isArray(applyResponse.obj)) {
        this.applyList = this.normalizeUsers(applyResponse.obj as User[]);
      } else {
        this.applyList = [];
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load friends. Code: ${businessError.code}, message: ${businessError.message}`);
      this.friendList = [];
      this.applyList = [];
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  private openApplications(): void {
    router.pushUrl({
      url: 'pages/ApplyPage'
    });
  }

  private openChat(item: User): void {
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        data: item
      }
    });
  }

  @Builder
  FriendCard(item: User) {
    Row() {
      Image(`${BaseUrl}${item.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(58)
        .height(58)
        .borderRadius(29)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.name.length > 0 ? item.name : item.username)
          .width('100%')
          .fontSize(19)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Image($r('app.media.user_position'))
            .width(17)
            .height(17)

          Text(item.addr.length > 0 ? item.addr : '暂未填写地址')
            .layoutWeight(1)
            .fontSize(14)
            .fontColor('#777777')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ top: 9 })

        Row() {
          Row() {
            Image($r('app.media.ic_chat'))
              .width(17)
              .height(17)

            Text('聊天')
              .fontSize(12)
              .fontColor('#444444')
              .margin({ left: 3 })
          }
          .height(29)
          .padding({ left: 9, right: 9 })
          .borderRadius(15)
          .border({ width: 1, color: '#EEEEEE' })
          .onClick(() => {
            this.openChat(item);
          })

          Row() {
            Image($r('app.media.ic_phone'))
              .width(17)
              .height(17)

            Text('电话')
              .fontSize(12)
              .fontColor('#777777')
              .margin({ left: 3 })
          }
          .height(29)
          .padding({ left: 9, right: 9 })
          .borderRadius(15)
          .border({ width: 1, color: '#EEEEEE' })
          .margin({ left: 8 })

          Row() {
            Image($r('app.media.ic_email'))
              .width(17)
              .height(17)

            Text('邮箱')
              .fontSize(12)
              .fontColor('#777777')
              .margin({ left: 3 })
          }
          .height(29)
          .padding({ left: 9, right: 9 })
          .borderRadius(15)
          .border({ width: 1, color: '#EEEEEE' })
          .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 9 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
    }
    .width('92%')
    .height(122)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  build() {
    Column() {
      if (this.isLogin) {
        Row() {
          Blank()
            .width(50)

          Text('好友')
            .layoutWeight(1)
            .fontSize(23)
            .fontColor('#222222')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)

          Badge({
            count: this.applyList.length,
            style: {
              badgeSize: 14,
              badgeColor: '#FA2A2D',
              fontSize: 10
            }
          }) {
            Image($r('app.media.ic_bell_normal'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Contain)
          }
          .width(50)
          .height(40)
          .onClick(() => {
            this.openApplications();
          })
        }
        .width('100%')
        .height(54)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(34)
              .height(34)
              .color('#FF3551')

            Text('正在加载好友')
              .fontSize(14)
              .fontColor('#777777')
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.loadFailed) {
          Column() {
            Text('好友列表加载失败')
              .fontSize(17)
              .fontColor('#333333')

            Button('重新加载')
              .height(40)
              .fontSize(15)
              .backgroundColor('#FF3551')
              .margin({ top: 15 })
              .onClick(() => {
                this.loadFriendData();
              })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.friendList.length === 0) {
          Column() {
            Text('还没有好友哦')
              .fontSize(20)
              .fontColor('#333333')

            Text('快去添加好友吧')
              .fontSize(16)
              .fontColor('#777777')
              .margin({ top: 10 })

            Image($r('app.media.ic_friend_no'))
              .width(66)
              .height(66)
              .margin({ top: 22 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          List({
            space: 10
          }) {
            ForEach(this.friendList, (item: User) => {
              ListItem() {
                this.FriendCard(item);
              }
            }, (item: User) => item.id.toString())
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .alignListItem(ListItemAlign.Center)
          .scrollBar(BarState.Off)
        }
      } else {
        NoLoginComponent()
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F8F8')
  }
}
