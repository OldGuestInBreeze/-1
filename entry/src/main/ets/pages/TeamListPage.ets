import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getEventInfo, getEventMemberList, isJoin, Join } from '../api/EventApi';
import { getFriendStatus, sendApply } from '../api/FriendApi';
import { BaseUrl } from '../common/Constant';
import { PageBackButton } from '../component/PageBackButton';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { EventMember } from '../viewmodel/EventMember';
import { RouterParam } from '../viewmodel/RouterParam';
import { User } from '../viewmodel/User';

@Entry
@Component
struct TeamListPage {
  @State teamList: EventMember[] = [];
  @State filteredList: EventMember[] = [];
  @State keyword: string = '';
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  @State eventMemberShow: boolean = false;
  @State memberAddShow: boolean = false;
  @State memberIds: string = '';
  @State addingMember: boolean = false;
  @State applyingFriend: boolean = false;
  @State isOwner: boolean = false;
  @State selectedMember: EventMember = new EventMember(0, '', '', '', 0);
  private eventId: number = 0;
  private userId: number = 0;

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<number>;
    if (param === undefined || param.data === undefined || param.data <= 0) {
      this.loadFailed = true;
      return;
    }

    this.eventId = param.data;
    loginUserAction((user: User) => {
      this.userId = user.id;
    });
    this.loadOwnerStatus();
    this.loadMembers();
  }

  private async loadOwnerStatus(): Promise<void> {
    try {
      const response = await getEventInfo(this.eventId);
      if (!response.success || response.obj === undefined || response.obj === null) {
        this.isOwner = false;
        return;
      }

      const event = response.obj as Event;
      if (event.userId === undefined || event.userId === null) {
        this.isOwner = false;
        return;
      }
      this.isOwner = parseInt(event.userId.toString()) === this.userId;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load event owner. Code: ${businessError.code}, message: ${businessError.message}`);
      this.isOwner = false;
    }
  }

  private async loadMembers(): Promise<void> {
    this.loading = true;
    this.loadFailed = false;
    try {
      const response = await getEventMemberList(this.userId, this.eventId);
      if (!response.success) {
        this.teamList = [];
        this.filteredList = [];
        this.loadFailed = true;
        return;
      }

      if (!Array.isArray(response.obj)) {
        this.teamList = [];
        this.filteredList = [];
        this.loadFailed = true;
        return;
      }

      const result = response.obj as EventMember[];
      const members: EventMember[] = [];
      result.forEach((item: EventMember) => {
        members.push(new EventMember(item.userId, item.name, item.addr, item.headImg, item.apply));
      });
      this.teamList = members;
      this.filterMembers(this.keyword);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load event members. Code: ${businessError.code}, message: ${businessError.message}`);
      this.teamList = [];
      this.filteredList = [];
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  private filterMembers(value: string): void {
    this.keyword = value;
    const normalizedKeyword: string = value.trim().toLowerCase();
    if (normalizedKeyword.length === 0) {
      this.filteredList = this.teamList.slice();
      return;
    }

    const members: EventMember[] = [];
    this.teamList.forEach((item: EventMember) => {
      if (item.name.toLowerCase().includes(normalizedKeyword)) {
        members.push(item);
      }
    });
    this.filteredList = members;
  }

  private showMember(item: EventMember): void {
    this.selectedMember = item;
    this.eventMemberShow = true;
    this.refreshFriendStatus(item.userId);
  }

  private async refreshFriendStatus(memberId: number): Promise<void> {
    if (this.userId <= 0 || memberId <= 0 || this.userId === memberId) {
      return;
    }

    try {
      const response = await getFriendStatus(this.userId, memberId);
      if (!response.success || response.obj === undefined || response.obj === null) {
        return;
      }

      const status = parseInt(response.obj.toString());
      if (status >= 0 && status <= 2 && this.selectedMember.userId === memberId) {
        this.selectedMember = new EventMember(
          this.selectedMember.userId,
          this.selectedMember.name,
          this.selectedMember.addr,
          this.selectedMember.headImg,
          status
        );
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load friend status. Code: ${businessError.code}, message: ${businessError.message}`);
    }
  }

  private sendFriendApplication(): void {
    if (this.applyingFriend) {
      return;
    }

    if (this.selectedMember.userId <= 0) {
      showText('好友信息无效，请关闭后重新选择');
      return;
    }

    loginUserAction((user: User) => {
      this.userId = user.id;
      this.submitFriendApplication(user.id, this.selectedMember.userId);
    }, () => {
      showText('请先登录');
    });
  }

  private async submitFriendApplication(userId: number, friendId: number): Promise<void> {
    if (userId === friendId) {
      showText('不能添加自己为好友');
      return;
    }

    this.applyingFriend = true;
    try {
      const response = await sendApply(userId, friendId);
      if (!response.success) {
        showText(response.info.length > 0 ? `申请失败：${response.info}` : '好友申请发送失败');
        return;
      }

      const memberId = friendId;
      this.selectedMember = new EventMember(
        memberId,
        this.selectedMember.name,
        this.selectedMember.addr,
        this.selectedMember.headImg,
        2
      );
      this.teamList.forEach((item: EventMember) => {
        if (item.userId === memberId) {
          item.apply = 2;
        }
      });
      this.filterMembers(this.keyword);
      this.eventMemberShow = false;
      showText('好友申请已发送');
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to send friend application. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      showText('好友申请发送失败');
    } finally {
      this.applyingFriend = false;
    }
  }

  private openChat(item: EventMember): void {
    this.eventMemberShow = false;
    const targetUser = new User(item.userId, item.name, item.name, item.headImg, item.addr, '', 0, 0);
    router.pushUrl({
      url: 'pages/ChatPage',
      params: {
        data: targetUser
      }
    });
  }

  private parseMemberIds(): number[] {
    const values = this.memberIds.replaceAll('，', ',').replaceAll(' ', ',').split(',');
    const memberIds: number[] = [];
    values.forEach((value: string) => {
      const userId = parseInt(value.trim());
      if (userId > 0 && !memberIds.includes(userId)) {
        memberIds.push(userId);
      }
    });
    return memberIds;
  }

  private async addMembers(): Promise<void> {
    if (!this.isOwner) {
      showText('仅活动创建者可以添加成员');
      return;
    }
    if (this.addingMember) {
      return;
    }

    const memberIds = this.parseMemberIds();
    if (memberIds.length === 0) {
      showText('请输入有效的用户ID');
      return;
    }
    if (memberIds.length > 4) {
      showText('每次最多添加4个成员');
      return;
    }

    this.addingMember = true;
    let addedCount: number = 0;
    let skippedCount: number = 0;
    try {
      for (let index: number = 0; index < memberIds.length; index++) {
        const targetUserId: number = memberIds[index];
        const statusResponse = await isJoin(targetUserId, this.eventId);
        if (!statusResponse.success || statusResponse.obj === undefined || statusResponse.obj === null) {
          skippedCount++;
          continue;
        }

        const state = parseInt(statusResponse.obj.toString());
        if (state !== 0) {
          skippedCount++;
          continue;
        }

        const joinResponse = await Join(targetUserId, this.eventId);
        if (joinResponse.success) {
          addedCount++;
        } else {
          skippedCount++;
        }
      }

      this.memberIds = '';
      this.memberAddShow = false;
      await this.loadMembers();
      if (skippedCount > 0) {
        showText(`成功添加${addedCount}名成员，跳过${skippedCount}名`);
      } else {
        showText(`成功添加${addedCount}名成员`);
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to add event members. Code: ${businessError.code}, message: ${businessError.message}`);
      showText('成员添加失败');
    } finally {
      this.addingMember = false;
    }
  }

  @Builder
  AddMemberSheet() {
    Column() {
      Text('添加活动成员')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#222222')
        .margin({ top: 28 })

      Text('输入最多4个用户ID，使用逗号分隔')
        .fontSize(14)
        .fontColor('#777777')
        .margin({ top: 10 })

      TextInput({
        text: this.memberIds,
        placeholder: '例如：2, 3, 4, 5'
      })
        .width('82%')
        .height(48)
        .type(InputType.Normal)
        .fontSize(16)
        .fontColor('#333333')
        .placeholderColor('#AAAAAA')
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .margin({ top: 24 })
        .onChange((value: string) => {
          this.memberIds = value;
        })

      Button(this.addingMember ? '添加中' : '确认添加')
        .width('82%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#FF3551')
        .borderRadius(22)
        .enabled(!this.addingMember)
        .margin({ top: 24 })
        .onClick(() => {
          this.addMembers();
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MemberSheet() {
    Column() {
      Image(`${BaseUrl}${this.selectedMember.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(92)
        .height(92)
        .margin({ top: 28 })
        .borderRadius(46)
        .objectFit(ImageFit.Cover)

      Text(this.selectedMember.name)
        .fontSize(28)
        .fontColor('#222222')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20 })

      Row() {
        Image($r('app.media.event_position'))
          .width(20)
          .height(20)

        Text(this.selectedMember.addr)
          .fontSize(18)
          .fontColor('#333333')
          .maxLines(2)
          .textAlign(TextAlign.Center)
          .margin({ left: 4 })
      }
      .constraintSize({ maxWidth: '82%' })
      .margin({ top: 4 })

      if (this.userId !== this.selectedMember.userId) {
        if (this.selectedMember.apply === 1) {
          Button('聊天')
            .height(42)
            .fontSize(16)
            .backgroundColor('#2ECC71')
            .margin({ top: 20 })
            .onClick(() => {
              this.openChat(this.selectedMember);
            })
        } else if (this.selectedMember.apply === 2) {
          Button('已申请')
            .height(42)
            .fontSize(16)
            .backgroundColor('#5C5C66')
            .margin({ top: 20 })
            .enabled(false)
        } else {
          Button(this.applyingFriend ? '发送中' : '加好友')
            .height(42)
            .fontSize(16)
            .backgroundColor('#FF3551')
            .margin({ top: 20 })
            .enabled(!this.applyingFriend)
            .onClick(() => {
              this.sendFriendApplication();
            })
        }
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MemberItem(item: EventMember) {
    Column() {
      Image(`${BaseUrl}${item.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(60)
        .height(60)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)

      Text(item.name)
        .width(72)
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 3 })
    }
    .onClick(() => {
      this.showMember(item);
    })
  }

  build() {
    Column() {
      Row() {
        PageBackButton()

        Text('活动成员')
          .layoutWeight(1)
          .fontSize(23)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .height(54)
      .padding({ left: 8, right: 8 })
      .backgroundColor(Color.White)
      .shadow(ShadowStyle.OUTER_DEFAULT_XS)

      Search({
        placeholder: '搜索成员',
        value: this.keyword
      })
        .width('91%')
        .height(38)
        .placeholderColor('#999999')
        .fontColor('#333333')
        .backgroundColor(Color.White)
        .borderRadius(20)
        .margin({ top: 10, bottom: 8 })
        .textAlign(TextAlign.Center)
        .onChange((value: string) => {
          this.filterMembers(value);
        })

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(34)
            .height(34)
            .color('#FF3551')

          Text('正在加载成员')
            .fontSize(14)
            .fontColor('#777777')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.loadFailed) {
        Column() {
          Text('成员加载失败')
            .fontSize(17)
            .fontColor('#333333')

          Button('重新加载')
            .height(40)
            .fontSize(15)
            .backgroundColor('#FF3551')
            .margin({ top: 15 })
            .onClick(() => {
              this.loadMembers();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredList.length === 0 && this.keyword.trim().length > 0) {
        Text('未找到相关成员')
          .layoutWeight(1)
          .width('100%')
          .fontSize(16)
          .fontColor('#777777')
          .textAlign(TextAlign.Center)
      } else {
        Grid() {
          ForEach(this.filteredList, (item: EventMember) => {
            GridItem() {
              this.MemberItem(item);
            }
          }, (item: EventMember) => item.userId.toString())

          if (this.isOwner) {
            GridItem() {
              Column() {
                Image($r('app.media.ic_event_add_to_photos'))
                  .width(60)
                  .height(60)
                  .shadow(ShadowStyle.OUTER_DEFAULT_XS)

                Text('添加')
                  .fontSize(14)
                  .fontColor('#333333')
                  .margin({ top: 3 })
              }
              .onClick(() => {
                this.memberAddShow = true;
              })
              .bindSheet($$this.memberAddShow, this.AddMemberSheet(), {
                height: 330,
                backgroundColor: Color.White
              })
            }
          }
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(6)
        .rowsGap(10)
        .layoutWeight(1)
        .width('91%')
        .padding({ top: 2, bottom: 12 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F8F8')
    .bindSheet($$this.eventMemberShow, this.MemberSheet(), {
      height: 400,
      backgroundColor: Color.White
    })
  }
}
