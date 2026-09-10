import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getEventMemberList } from '../api/EventApi';
import { BaseUrl } from '../common/Constant';
import { loginUserAction } from '../utils/UserUtil';
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
    this.loadMembers();
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
        } else if (this.selectedMember.apply === 2) {
          Button('已申请')
            .height(42)
            .fontSize(16)
            .backgroundColor('#5C5C66')
            .margin({ top: 20 })
            .enabled(false)
        } else {
          Button('加好友')
            .height(42)
            .fontSize(16)
            .backgroundColor('#FF3551')
            .margin({ top: 20 })
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
      Text('活动成员')
        .width('100%')
        .height(54)
        .fontSize(23)
        .fontColor('#222222')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
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
