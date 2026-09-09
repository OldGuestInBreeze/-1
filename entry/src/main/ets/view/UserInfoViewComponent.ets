import { router } from '@kit.ArkUI';
import { BaseUrl } from '../common/Constant';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { User } from '../viewmodel/User';

class MenuItem {
  icon: Resource;
  name: string;
  action: () => void;

  constructor(icon: Resource, name: string, action: () => void) {
    this.icon = icon;
    this.name = name;
    this.action = () => {
      loginUserAction(action, () => {
        showText('请先登录');
      });
    };
  }
}

@Preview
@Component
export struct UserInfoViewComponent {
  @StorageProp('user') user: User = new User(0, '', '', '', '', '', 0, 0);
  @StorageProp('isLogin') isLogin: boolean = false;

  private menuList: MenuItem[] = [
    new MenuItem($r('app.media.ic_user_menu_event'), '管理活动', () => {
      router.pushUrl({
        url: 'pages/MyEventPage'
      });
    }),
    new MenuItem($r('app.media.ic_user_menu_setting'), '用户设置', () => {
      router.pushUrl({
        url: 'pages/UserEditPage'
      });
    }),
    new MenuItem($r('app.media.ic_user_menu_security'), '修改密码', () => {
      router.pushUrl({
        url: 'pages/ResetPasswordPage'
      });
    }),
    new MenuItem($r('app.media.ic_user_menu_about'), '关于我们', () => {
      showText('隐私声明：\n\n' +
        '我们非常重视您的隐私权和个人信息保护。我们的兴趣活动APP承诺对用户的个人信息进行合理的收集、使用和保护，严格遵守相关法律法规，绝不会泄露、出售或分享用户的个人信息给第三方。\n\n' +
        '我们会收集用户的姓名、联系方式、兴趣爱好等信息，用于提供个性化推荐和活动安排等服务。我们会采取合理的安全措施保护用户信息，并仅在用户同意的情况下使用。\n\n' +
        '用户使用本APP即表示同意本隐私声明。如有疑问或意见，可随时联系我们。感谢您的信任和支持！');
    })
  ];

  private logout(): void {
    AppStorage.setOrCreate('user', new User(0, '', '', '', '', '', 0, 0));
    AppStorage.setOrCreate('isLogin', false);
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/Index'
      });
    }, 500);
  }

  build() {
    Column() {
      Row() {
        Image(`${BaseUrl}${this.user.headImg}`)
          .alt($r('app.media.ic_user_icon_default'))
          .width(70)
          .height(70)
          .backgroundColor(Color.White)
          .borderRadius(35)
          .objectFit(ImageFit.Cover)

        if (this.isLogin) {
          Column() {
            Text(this.user.name.length > 0 ? this.user.name : this.user.username)
              .fontColor(Color.White)
              .fontSize(26)
              .fontWeight(FontWeight.Medium)

            Text(this.user.username)
              .fontColor(Color.White)
              .fontSize(16)
              .margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 10 })
        } else {
          Text('登录')
            .fontColor(Color.White)
            .fontSize(26)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 20 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/LoginPage'
              });
            })
        }
      }
      .width('100%')
      .padding({ left: 20 })
      .margin({ top: 55 })

      Button('⊕发起活动')
        .width('90%')
        .height(38)
        .type(ButtonType.Normal)
        .borderRadius(10)
        .fontColor('#FF3551')
        .backgroundColor(Color.White)
        .margin({ top: 18 })
        .onClick(() => {
          loginUserAction(() => {
            router.pushUrl({
              url: 'pages/EventEditPage',
              params: {
                message: 'add'
              }
            });
          }, () => {
            showText('请先登录');
          });
        })

      Column() {
        ForEach(this.menuList, (item: MenuItem) => {
          Row() {
            Image(item.icon)
              .width(20)
              .height(20)
              .margin({ left: 20 })

            Text(item.name)
              .fontSize(16)
              .fontColor('#222222')
              .margin({ left: 20 })
          }
          .height(55)
          .width('100%')
          .onClick(() => {
            item.action();
          })
        }, (item: MenuItem) => item.name)
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(15)
      .margin({ top: 18 })
      .shadow(ShadowStyle.OUTER_DEFAULT_SM)

      Text('退出登录')
        .fontSize(18)
        .margin({ top: 18 })
        .fontColor('#999999')
        .onClick(() => {
          this.logout();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.bg_userinfo'))
    .backgroundImageSize({
      height: '40%',
      width: '100%'
    })
    .backgroundColor('#F8F8F8')
  }
}
