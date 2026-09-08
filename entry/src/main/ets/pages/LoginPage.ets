import { promptAction, router } from '@kit.ArkUI';
import { login } from '../api/LoginApi';
import { showText } from '../utils/ShowUtil';
import { User } from '../viewmodel/User';

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

  private async clickLogin(): Promise<void> {
    const username: string = this.username.trim();
    if (username.length === 0) {
      showText('\u8BF7\u8F93\u5165\u7528\u6237\u540D');
      return;
    }
    if (this.password.length === 0) {
      showText('\u8BF7\u8F93\u5165\u5BC6\u7801');
      return;
    }

    try {
      const result = await login(username, this.password);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : '\u767B\u5F55\u5931\u8D25');
        return;
      }

      const data = result.obj as User;
      const user = new User(data.id, data.username, data.name, data.headImg, data.addr,
        data.gender, data.lon, data.lat);
      AppStorage.setOrCreate('user', user);
      AppStorage.setOrCreate('isLogin', true);
      showText('\u767B\u5F55\u6210\u529F', () => {
        this.openHome();
      });
    } catch (error) {
      console.error(`Failed to save login data: ${JSON.stringify(error)}`);
      showText('\u767B\u5F55\u5931\u8D25');
    }
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
            this.clickLogin();
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