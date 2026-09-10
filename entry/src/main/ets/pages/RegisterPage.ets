import { router } from '@kit.ArkUI';
import { register } from '../api/LoginApi';
import { showText } from '../utils/ShowUtil';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  private openLogin(): void {
    router.replaceUrl({
      url: 'pages/LoginPage'
    });
  }

  private async clickRegister(): Promise<void> {
    const username: string = this.username.trim();
    if (username.length === 0) {
      showText('请输入用户名');
      return;
    }
    if (this.password.length === 0) {
      showText('请输入密码');
      return;
    }
    if (this.confirmPassword.length === 0) {
      showText('请再次输入密码');
      return;
    }
    if (this.password !== this.confirmPassword) {
      showText('两次输入的密码不一致');
      return;
    }

    try {
      const result = await register(username, this.password);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : '注册失败');
        return;
      }

      showText(result.info.length > 0 ? result.info : '注册成功', () => {
        this.openLogin();
      });
    } catch (error) {
      console.error(`Failed to register user: ${JSON.stringify(error)}`);
      showText('注册失败');
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.ic_bg_login'))
        .width('100%')
        .height(145)
        .objectFit(ImageFit.Fill)

      Column() {
        Text('返回登录')
          .fontSize(12)
          .fontColor('#777777')
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            this.openLogin();
          })

        Text('注册兴趣小队账号')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#171717')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 27, left: 14 })

        TextInput({
          placeholder: '请输入用户名',
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
          placeholder: '请输入密码',
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

        TextInput({
          placeholder: '请再次输入密码',
          text: this.confirmPassword
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
            this.confirmPassword = value;
          })

        Button('注册', { type: ButtonType.Capsule })
          .width('88%')
          .height(31)
          .fontSize(13)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Normal)
          .backgroundColor('#FF3B5C')
          .margin({ top: 18 })
          .onClick(() => {
            this.clickRegister();
          })
      }
      .width('100%')
      .padding({ top: 30, left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
