import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';

  private openHome(): void {
    router.replaceUrl({
      url: 'pages/Index'
    });
  }

  private login(): void {
    if (this.username.trim().length === 0) {
      promptAction.showToast({ message: '请输入用户名' });
      return;
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }
    this.openHome();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.ic_bg_login'))
        .width('100%')
        .height(145)
        .objectFit(ImageFit.Fill)

      Column() {
        Text('随便看看')
          .fontSize(12)
          .fontColor('#777777')
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            this.openHome();
          })

        Text('欢迎来到兴趣小队')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#171717')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 27, left: 14 })

        TextInput({
          placeholder: '用户名',
          text: this.username
        })
          .type(InputType.Normal)
          .height(36)
          .fontSize(13)
          .placeholderFont({ size: 13 })
          .fontColor('#222222')
          .placeholderColor('#777777')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .padding({ left: 14, right: 14 })
          .shadow({
            radius: 8,
            color: '#22000000',
            offsetX: 0,
            offsetY: 3
          })
          .margin({ top: 13 })
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({
          placeholder: '密码',
          text: this.password
        })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .height(36)
          .fontSize(13)
          .placeholderFont({ size: 13 })
          .fontColor('#222222')
          .placeholderColor('#777777')
          .backgroundColor(Color.White)
          .borderRadius(20)
          .padding({ left: 14, right: 10 })
          .shadow({
            radius: 8,
            color: '#22000000',
            offsetX: 0,
            offsetY: 3
          })
          .margin({ top: 20 })
          .onChange((value: string) => {
            this.password = value;
          })

        Button('登录', { type: ButtonType.Capsule })
          .width('88%')
          .height(31)
          .fontSize(13)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Normal)
          .backgroundColor('#FF3B5C')
          .margin({ top: 15 })
          .onClick(() => {
            this.login();
          })

        Row() {
          Text('去注册→')
            .fontSize(12)
            .fontColor('#555555')
            .onClick(() => {
              promptAction.showToast({ message: '注册功能即将开放' });
            })

          Text('忘记密码')
            .fontSize(12)
            .fontColor('#555555')
            .onClick(() => {
              promptAction.showToast({ message: '请联系管理员重置密码' });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 14 })
      }
      .width('100%')
      .padding({ top: 30, left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}