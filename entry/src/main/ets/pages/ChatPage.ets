import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { addChatList, getChatList } from '../api/ChatApi';
import { PageBackButton } from '../component/PageBackButton';
import { BaseUrl } from '../common/Constant';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { Chat } from '../viewmodel/Chat';
import { RouterParam } from '../viewmodel/RouterParam';
import { User } from '../viewmodel/User';

interface ChatPayload {
  id?: number;
  userIdFrom?: number;
  userIdTo?: number;
  content?: string;
  createTime?: string;
}

@Entry
@Component
struct ChatPage {
  @State chatList: Chat[] = [];
  @State content: string = '';
  @State loading: boolean = false;
  @State loadFailed: boolean = false;
  @State sending: boolean = false;
  @State currentUser: User = new User(0, '', '', '', '', '', 0, 0);
  @State targetUser: User = new User(0, '', '', '', '', '', 0, 0);
  private timerId: number = -1;
  private requesting: boolean = false;
  private refreshAfterRequest: boolean = false;

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<User>;
    if (param === undefined || param.data === undefined || param.data === null ||
      param.data.id === undefined || param.data.id === null || param.data.id <= 0) {
      this.loadFailed = true;
      showText('聊天对象信息无效', () => {
        this.getUIContext().getRouter().back();
      });
      return;
    }

    const target = param.data;
    this.targetUser = new User(
      target.id,
      target.username === undefined || target.username === null ? '' : target.username,
      target.name === undefined || target.name === null ? '' : target.name,
      target.headImg === undefined || target.headImg === null ? '' : target.headImg,
      target.addr === undefined || target.addr === null ? '' : target.addr,
      target.gender === undefined || target.gender === null ? '' : target.gender,
      target.lon === undefined || target.lon === null ? 0 : target.lon,
      target.lat === undefined || target.lat === null ? 0 : target.lat
    );

    loginUserAction((user: User) => {
      this.currentUser = user;
      this.loadMessages(true);
      this.startPolling();
    }, () => {
      showText('请先登录', () => {
        this.getUIContext().getRouter().back();
      });
    });
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private startPolling(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(() => {
      this.loadMessages(false);
    }, 15000);
  }

  private async loadMessages(showLoading: boolean): Promise<void> {
    if (this.requesting || this.currentUser.id <= 0 || this.targetUser.id <= 0) {
      if (this.requesting && !showLoading) {
        this.refreshAfterRequest = true;
      }
      return;
    }

    this.requesting = true;
    if (showLoading) {
      this.loading = true;
    }
    this.loadFailed = false;
    try {
      const response = await getChatList(this.currentUser.id, this.targetUser.id);
      if (!response.success || !Array.isArray(response.obj)) {
        if (showLoading) {
          this.chatList = [];
          this.loadFailed = true;
        }
        return;
      }

      const result = response.obj as ChatPayload[];
      const messages: Chat[] = [];
      result.forEach((item: ChatPayload) => {
        if (item !== undefined && item !== null) {
          messages.push(new Chat(
            item.id === undefined ? 0 : item.id,
            item.userIdFrom === undefined ? 0 : item.userIdFrom,
            item.userIdTo === undefined ? 0 : item.userIdTo,
            item.content === undefined ? '' : item.content,
            item.createTime === undefined ? '' : item.createTime
          ));
        }
      });
      this.chatList = messages;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load chat messages. Code: ${businessError.code}, message: ${businessError.message}`);
      if (showLoading) {
        this.chatList = [];
        this.loadFailed = true;
      }
    } finally {
      if (showLoading) {
        this.loading = false;
      }
      this.requesting = false;
      if (this.refreshAfterRequest) {
        this.refreshAfterRequest = false;
        this.loadMessages(false);
      }
    }
  }

  private async sendMessage(): Promise<void> {
    if (this.sending) {
      return;
    }
    if (this.currentUser.id <= 0 || this.targetUser.id <= 0) {
      showText('聊天用户信息无效');
      return;
    }

    const message = this.content.trim();
    if (message.length === 0) {
      showText('请输入聊天内容');
      return;
    }

    this.sending = true;
    try {
      const response = await addChatList(this.currentUser.id, this.targetUser.id, message);
      if (!response.success) {
        const info = response.info === undefined || response.info === null ? '' : response.info;
        showText(info.length > 0 ? `发送失败：${info}` : '信息发送失败');
        return;
      }

      this.content = '';
      await this.loadMessages(false);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to send chat message. Code: ${businessError.code}, message: ${businessError.message}`);
      showText('信息发送失败');
    } finally {
      this.sending = false;
    }
  }

  @Builder
  IncomingMessage(item: Chat) {
    Row() {
      Image(`${BaseUrl}${this.targetUser.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(42)
        .height(42)
        .borderRadius(21)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.content)
          .fontSize(16)
          .fontColor('#222222')
          .padding({ left: 11, right: 11, top: 8, bottom: 8 })
          .backgroundColor('#DFE4EA')
          .borderRadius(7)

        if (item.createTime.length > 0) {
          Text(item.createTime)
            .fontSize(10)
            .fontColor('#999999')
            .margin({ top: 3 })
        }
      }
      .constraintSize({ maxWidth: '70%' })
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 7 })

      Blank()
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  OutgoingMessage(item: Chat) {
    Row() {
      Blank()

      Column() {
        Text(item.content)
          .fontSize(16)
          .fontColor('#14320A')
          .padding({ left: 11, right: 11, top: 8, bottom: 8 })
          .backgroundColor('#95EC69')
          .borderRadius(7)

        if (item.createTime.length > 0) {
          Text(item.createTime)
            .fontSize(10)
            .fontColor('#999999')
            .margin({ top: 3 })
        }
      }
      .constraintSize({ maxWidth: '70%' })
      .alignItems(HorizontalAlign.End)
      .margin({ right: 7 })

      Image(`${BaseUrl}${this.currentUser.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(42)
        .height(42)
        .borderRadius(21)
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Column() {
      Row() {
        PageBackButton({ icon: $r('app.media.ic_return_white') })

        Text(this.targetUser.name.length > 0 ? this.targetUser.name : this.targetUser.username)
          .layoutWeight(1)
          .fontSize(22)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .height(54)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#FF3551')

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(34)
            .height(34)
            .color('#FF3551')

          Text('正在加载聊天记录')
            .fontSize(14)
            .fontColor('#777777')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.loadFailed) {
        Column() {
          Text('聊天记录加载失败')
            .fontSize(17)
            .fontColor('#333333')

          Button('重新加载')
            .height(40)
            .fontSize(15)
            .backgroundColor('#FF3551')
            .margin({ top: 15 })
            .onClick(() => {
              this.loadMessages(true);
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.chatList.length === 0) {
        Column() {
          Text('暂无聊天记录，发条消息吧')
            .fontSize(15)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({
          space: 2
        }) {
          ForEach(this.chatList, (item: Chat) => {
            ListItem() {
              if (item.userIdTo === this.currentUser.id) {
                this.IncomingMessage(item);
              } else {
                this.OutgoingMessage(item);
              }
            }
          }, (item: Chat, index: number) => `${item.id}-${item.userIdFrom}-${item.createTime}-${index}`)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ top: 6, bottom: 6 })
        .scrollBar(BarState.Off)
      }

      Row() {
        TextInput({
          text: this.content,
          placeholder: '输入聊天内容'
        })
          .layoutWeight(1)
          .height(42)
          .fontSize(16)
          .fontColor('#222222')
          .placeholderColor('#999999')
          .backgroundColor(Color.White)
          .borderRadius(21)
          .onChange((value: string) => {
            this.content = value;
          })

        Button(this.sending ? '发送中' : '发送')
          .width(74)
          .height(42)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#1677FF')
          .borderRadius(5)
          .enabled(!this.sending)
          .margin({ left: 9 })
          .onClick(() => {
            this.sendMessage();
          })
      }
      .width('100%')
      .height(58)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#E5E4E4')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
