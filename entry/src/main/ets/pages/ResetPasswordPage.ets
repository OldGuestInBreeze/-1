import { updatePassword } from '../api/UserApi';
import { PageBackButton } from '../component/PageBackButton';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { User } from '../viewmodel/User';

function checkPassword(password: string): boolean {
  const pattern: RegExp = new RegExp('^[a-zA-Z][a-zA-Z0-9_]{5,17}$');
  return pattern.test(password);
}

@Entry
@Component
struct ResetPasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State reNewPassword: string = '';
  @State saving: boolean = false;

  private savePassword(): void {
    if (this.oldPassword.length === 0) {
      showText('请输入原始密码');
      return;
    }
    if (this.newPassword !== this.reNewPassword) {
      showText('两次密码不一致');
      return;
    }
    if (!checkPassword(this.newPassword)) {
      showText('密码必须以字母开头，长度在6-18之间，只能包含英文字符、数字和下划线');
      return;
    }
    if (this.saving) {
      return;
    }

    loginUserAction((user: User) => {
      this.submitPassword(user);
    }, () => {
      showText('请先登录');
    });
  }

  private async submitPassword(user: User): Promise<void> {
    this.saving = true;
    try {
      const result = await updatePassword(user.id, this.newPassword);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : '更新失败');
        return;
      }

      this.oldPassword = '';
      this.newPassword = '';
      this.reNewPassword = '';
      showText(result.info.length > 0 ? result.info : '更新成功');
    } catch (error) {
      console.error(`Failed to update password: ${JSON.stringify(error)}`);
      showText('更新失败');
    } finally {
      this.saving = false;
    }
  }

  @Builder
  private passwordItem(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Row() {
      Text(label)
        .width(100)
        .fontSize(16)
        .fontColor('#222222')

      TextInput({
        text: value,
        placeholder: placeholder
      })
        .layoutWeight(1)
        .type(InputType.Password)
        .showPasswordIcon(true)
        .fontSize(15)
        .fontColor('#333333')
        .placeholderColor('#AAAAAA')
        .borderWidth(0)
        .backgroundColor(Color.Transparent)
        .onChange(onChange)
    }
    .width('100%')
    .height(58)
    .padding({ left: 20, right: 15 })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          PageBackButton({ icon: $r('app.media.ic_return') })

          Blank()
        }
        .width('100%')

        Text('修改密码')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#222222')
      }
      .width('100%')
      .height(82)
      .padding({ top: 26, left: 15, right: 15 })
      .backgroundColor(Color.White)

      Column() {
        List() {
          ListItem() {
            this.passwordItem('原始密码', '请输入原始密码', this.oldPassword, (value: string) => {
              this.oldPassword = value;
            })
          }

          ListItem() {
            this.passwordItem('新密码', '请输入新密码', this.newPassword, (value: string) => {
              this.newPassword = value;
            })
          }

          ListItem() {
            this.passwordItem('确认新密码', '请再次输入新密码', this.reNewPassword, (value: string) => {
              this.reNewPassword = value;
            })
          }
        }
        .divider({
          strokeWidth: 1,
          color: '#F1F1F1',
          startMargin: 20,
          endMargin: 20
        })
        .width('100%')
        .backgroundColor(Color.White)

        Text('密码须以字母开头，长度为6-18位，仅支持字母、数字和下划线')
          .width('100%')
          .fontSize(12)
          .fontColor('#999999')
          .padding({ left: 20, right: 20, top: 12 })
      }
      .width('100%')

      Blank()

      Row() {
        Button(this.saving ? '保存中' : '保存')
          .width('100%')
          .height(44)
          .fontColor(Color.White)
          .fontSize(16)
          .backgroundColor('#FF3551')
          .type(ButtonType.Normal)
          .borderRadius(22)
          .enabled(!this.saving)
          .onClick(() => {
            this.savePassword();
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 18 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
