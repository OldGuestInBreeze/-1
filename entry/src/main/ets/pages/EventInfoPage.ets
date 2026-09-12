import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  Join,
  addComment as requestAddComment,
  getCommentList as requestCommentList,
  getEventInfo,
  isJoin
} from '../api/EventApi';
import { BaseUrl } from '../common/Constant';
import { PageBackButton } from '../component/PageBackButton';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { EventComment } from '../viewmodel/EventComment';
import { Location } from '../viewmodel/Location';
import { RouterParam } from '../viewmodel/RouterParam';
import { User } from '../viewmodel/User';

@Entry
@Component
struct EventInfoPage {
  @State item: Event = new Event(0, 0, '', '', '', '', '', 0, 0, 0);
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  @State commentListShow: boolean = false;
  @State commentList: EventComment[] = [];
  @State comment: string = '';
  @State commentsLoading: boolean = false;
  @State commentsFailed: boolean = false;
  @State submittingComment: boolean = false;
  @State joinStatusLoading: boolean = false;
  @State joining: boolean = false;
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

      if (response.obj === undefined || response.obj === null) {
        this.loadFailed = true;
        return;
      }

      const event = response.obj as Event;
      this.item = new Event(event.id, event.userId, event.name, event.intro, event.addr, event.headImg,
        event.startTime, event.lon, event.lat, event.state);
      this.loadComments();
      this.getJoinStatus();
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load event details. Code: ${businessError.code}, message: ${businessError.message}`);
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  private async loadComments(): Promise<void> {
    if (this.eventId <= 0 || this.commentsLoading) {
      return;
    }

    this.commentsLoading = true;
    this.commentsFailed = false;
    try {
      const response = await requestCommentList(this.eventId);
      if (!response.success) {
        this.commentList = [];
        this.commentsFailed = true;
        return;
      }
      if (!Array.isArray(response.obj)) {
        this.commentList = [];
        this.commentsFailed = true;
        return;
      }
      this.commentList = response.obj as EventComment[];
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load comments. Code: ${businessError.code}, message: ${businessError.message}`);
      this.commentList = [];
      this.commentsFailed = true;
    } finally {
      this.commentsLoading = false;
    }
  }

  private addComment(): void {
    loginUserAction((user: User) => {
      this.publishComment(user);
    }, () => {
      showText('请先登录');
    });
  }

  private async publishComment(user: User): Promise<void> {
    const content: string = this.comment.trim();
    if (content.length === 0) {
      showText('请输入评论内容');
      return;
    }
    if (this.submittingComment) {
      return;
    }

    this.submittingComment = true;
    try {
      const response = await requestAddComment(new EventComment(this.eventId, user.id, content));
      if (response.success) {
        this.comment = '';
        await this.loadComments();
        showText('评论添加成功');
      } else {
        showText('评论添加失败');
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to publish comment. Code: ${businessError.code}, message: ${businessError.message}`);
      showText('评论添加失败');
    } finally {
      this.submittingComment = false;
    }
  }

  private getJoinStatus(): void {
    loginUserAction((user: User) => {
      this.loadJoinStatus(user);
    }, () => {
      this.item.state = 0;
      this.joinStatusLoading = false;
    });
  }

  private async loadJoinStatus(user: User): Promise<void> {
    this.joinStatusLoading = true;
    try {
      const response = await isJoin(user.id, this.eventId);
      if (response.success) {
        const state: number = parseInt(response.obj.toString());
        this.item.state = state === 1 || state === 2 ? state : 0;
      } else {
        this.item.state = 0;
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load join status. Code: ${businessError.code}, message: ${businessError.message}`);
      this.item.state = 0;
    } finally {
      this.joinStatusLoading = false;
    }
  }

  private joinEvent(): void {
    loginUserAction((user: User) => {
      this.updateJoinStatus(user);
    }, () => {
      showText('请先登录');
    });
  }

  private async updateJoinStatus(user: User): Promise<void> {
    if (this.joining || this.item.state === 2) {
      return;
    }

    this.joining = true;
    try {
      const response = await Join(user.id, this.eventId);
      if (!response.success) {
        showText('操作异常');
        return;
      }

      const joined: boolean = response.obj.toString() === 'true';
      this.item.state = joined ? 1 : 0;
      showText(joined ? '加入成功' : '退出成功');
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to update join status. Code: ${businessError.code}, message: ${businessError.message}`);
      showText('操作异常');
    } finally {
      this.joining = false;
    }
  }

  private openNavigation(): void {
    if (this.item.lat === 0 && this.item.lon === 0) {
      showText('该活动暂无可导航的位置');
      return;
    }

    const location: Location = {
      lat: this.item.lat,
      lng: this.item.lon
    };
    router.pushUrl({
      url: 'pages/NavigationPage',
      params: {
        data: location
      }
    });
  }

  @Builder
  PageHeader() {
    Row() {
      PageBackButton({ icon: $r('app.media.ic_return_white') })

      Text('活动详情')
        .fontSize(21)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Blank()
        .width(44)
    }
    .width('100%')
    .height(82)
    .padding({ top: 24, left: 14, right: 14 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.loading || this.loadFailed ? '#FF3551' : '#00000000')
  }

  @Builder
  CommentSheet() {
    Column() {
      Text('热门评论')
        .width('90%')
        .height(44)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .textAlign(TextAlign.Start)

      if (this.commentsLoading) {
        Column() {
          LoadingProgress()
            .width(34)
            .height(34)
            .color('#FF3551')

          Text('正在加载评论')
            .fontSize(14)
            .fontColor('#888888')
            .margin({ top: 10 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.commentsFailed) {
        Column() {
          Text('评论加载失败')
            .fontSize(15)
            .fontColor('#888888')

          Button('重新加载')
            .height(36)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#FF3551')
            .borderRadius(18)
            .margin({ top: 12 })
            .onClick(() => {
              this.loadComments();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.commentList.length === 0) {
        Column() {
          Text('暂无评论')
            .fontSize(15)
            .fontColor('#999999')

          Text('来发表第一条评论吧')
            .fontSize(13)
            .fontColor('#BBBBBB')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.commentList, (item: EventComment) => {
            ListItem() {
              Row() {
                if (item.headImg !== undefined && item.headImg.length > 0) {
                  Image(`${BaseUrl}${item.headImg}`)
                    .width(46)
                    .height(46)
                    .borderRadius(23)
                    .objectFit(ImageFit.Cover)
                } else {
                  Image($r('app.media.ic_user_icon_default'))
                    .width(46)
                    .height(46)
                    .borderRadius(23)
                    .objectFit(ImageFit.Cover)
                }

                Column() {
                  Text(item.name === undefined || item.name.length === 0 ? '兴趣队友' : item.name)
                    .width('100%')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.content)
                    .width('100%')
                    .fontSize(13)
                    .fontColor('#555555')
                    .lineHeight(19)
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .padding({ top: 9, bottom: 9 })
            }
          })
        }
        .layoutWeight(1)
        .width('90%')
        .scrollBar(BarState.Off)
      }

      Row() {
        TextInput({ placeholder: '评论...', text: this.comment })
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .backgroundColor('#F0F0F0')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.comment = value;
          })

        Button(this.submittingComment ? '发布中' : '发布')
          .width(86)
          .height(42)
          .fontSize(15)
          .fontColor(Color.White)
          .backgroundColor('#FF3551')
          .borderRadius(22)
          .margin({ left: 8 })
          .enabled(!this.submittingComment)
          .onClick(() => {
            this.addComment();
          })
      }
      .width('90%')
      .height(58)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
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
      .onClick(() => {
        this.commentListShow = true;
        this.loadComments();
      })
      .bindSheet($$this.commentListShow, this.CommentSheet(), {
        height: 500,
        backgroundColor: '#F8F8F8'
      })

      if (this.joinStatusLoading) {
        Button('状态加载中')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#999999')
          .borderRadius(24)
          .margin({ left: 12, right: 14 })
          .enabled(false)
      } else if (this.item.state === 1) {
        Button(this.joining ? '处理中' : '已加入')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#777777')
          .borderRadius(24)
          .margin({ left: 12, right: 14 })
          .enabled(!this.joining)
          .onClick(() => {
            this.joinEvent();
          })
      } else if (this.item.state === 2) {
        Button('编辑活动')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#1769FF')
          .borderRadius(24)
          .margin({ left: 12, right: 14 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/EventEditPage',
              params: {
                message: 'edit',
                data: this.item
              }
            });
          })
      } else {
        Button(this.joining ? '处理中' : '+加入')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF3551')
          .borderRadius(24)
          .margin({ left: 12, right: 14 })
          .enabled(!this.joining)
          .onClick(() => {
            this.joinEvent();
          })
      }
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
      .onClick(() => {
        this.openNavigation();
      })

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
                  this.getUIContext().getRouter().back();
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
