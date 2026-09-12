import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { updateUserInfo } from '../api/UserApi';
import { BaseUrl } from '../common/Constant';
import { PageBackButton } from '../component/PageBackButton';
import { showText } from '../utils/ShowUtil';
import { selectImage } from '../utils/UploadUtil';
import { User } from '../viewmodel/User';

@Entry
@Component
struct UserEditPage {
  @StorageProp('user') user: User = new User(0, '', '', '', '', '', 0, 0);
  @State name: string = '';
  @State addr: string = '';
  @State headImg: string = '';
  @State uploading: boolean = false;
  @State saving: boolean = false;

  aboutToAppear(): void {
    this.name = this.user.name;
    this.addr = this.user.addr;
    this.headImg = this.user.headImg;
  }

  private async selectAvatar(): Promise<void> {
    if (this.uploading) {
      return;
    }

    this.uploading = true;
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const imageUrl = await selectImage(context);
      if (imageUrl.length > 0) {
        this.headImg = imageUrl;
      }
    } finally {
      this.uploading = false;
    }
  }

  private async saveUserInfo(): Promise<void> {
    const name = this.name.trim();
    if (name.length === 0) {
      showText('请输入昵称');
      return;
    }
    if (this.user.id <= 0) {
      showText('请先登录');
      return;
    }
    if (this.saving || this.uploading) {
      return;
    }

    const updatedUser = new User(this.user.id, this.user.username, name, this.headImg, this.addr.trim(),
      this.user.gender, this.user.lon, this.user.lat);
    this.saving = true;
    try {
      const result = await updateUserInfo(updatedUser);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : '更新失败');
        return;
      }

      AppStorage.setOrCreate('user', updatedUser);
      showText(result.info.length > 0 ? result.info : '更新成功', () => {
        router.back();
      });
    } catch (error) {
      console.error(`Failed to update user information: ${JSON.stringify(error)}`);
      showText('更新失败');
    } finally {
      this.saving = false;
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          PageBackButton({ icon: $r('app.media.ic_return') })

          Blank()

          Button(this.saving ? '保存中' : '保存')
            .height(34)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#FF3551')
            .borderRadius(18)
            .enabled(!this.saving && !this.uploading)
            .onClick(() => {
              this.saveUserInfo();
            })
        }
        .width('100%')

        Text('用户设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#222222')
      }
      .width('100%')
      .height(82)
      .padding({ top: 26, left: 15, right: 15 })
      .backgroundColor(Color.White)

      Row() {
        Image(`${BaseUrl}${this.headImg}`)
          .alt($r('app.media.ic_user_icon_default'))
          .width(58)
          .height(58)
          .borderRadius(29)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            this.selectAvatar();
          })

        Column() {
          Text(this.uploading ? '头像上传中' : '点击修改头像')
            .fontColor('#777777')
            .fontSize(16)

          Text('支持从系统图库选择图片')
            .fontColor('#AAAAAA')
            .fontSize(12)
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .width('100%')
      .height(92)
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)

      Column() {
        Text('个人信息')
          .width('100%')
          .fontColor('#999999')
          .fontSize(14)
          .padding({ left: 15, top: 12, bottom: 8 })

        Column() {
          Row() {
            Text('昵称')
              .width(72)
              .fontSize(16)
              .fontColor('#222222')

            TextInput({
              text: this.name,
              placeholder: '请输入昵称'
            })
              .layoutWeight(1)
              .height(50)
              .fontSize(15)
              .fontColor('#333333')
              .placeholderColor('#AAAAAA')
              .backgroundColor(Color.Transparent)
              .borderRadius(0)
              .onChange((value: string) => {
                this.name = value;
              })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })

          Divider()
            .strokeWidth(1)
            .color('#F0F0F0')
            .margin({ left: 15 })

          Row() {
            Text('地区')
              .width(72)
              .fontSize(16)
              .fontColor('#222222')

            TextInput({
              text: this.addr,
              placeholder: '请填写地区'
            })
              .layoutWeight(1)
              .height(50)
              .fontSize(15)
              .fontColor('#333333')
              .placeholderColor('#AAAAAA')
              .backgroundColor(Color.Transparent)
              .borderRadius(0)
              .onChange((value: string) => {
                this.addr = value;
              })
          }
          .width('100%')
          .padding({ left: 15, right: 15 })
        }
        .width('100%')
        .backgroundColor(Color.White)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
