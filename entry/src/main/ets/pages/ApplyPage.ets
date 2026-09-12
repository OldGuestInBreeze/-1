import { BusinessError } from '@kit.BasicServicesKit';
import { getApplyList, processApply } from '../api/FriendApi';
import { PageBackButton } from '../component/PageBackButton';
import { BaseUrl } from '../common/Constant';
import { showText } from '../utils/ShowUtil';
import { loginUserAction } from '../utils/UserUtil';
import { User } from '../viewmodel/User';

@Entry
@Component
struct ApplyPage {
  @State applyList: User[] = [];
  @State loading: boolean = false;
  @State loadFailed: boolean = false;

  onPageShow(): void {
    this.loadApplications();
  }

  private loadApplications(): void {
    loginUserAction((user: User) => {
      this.loadUserApplications(user.id);
    }, () => {
      this.applyList = [];
      this.loading = false;
      this.loadFailed = true;
      showText('请先登录');
    });
  }

  private async loadUserApplications(userId: number): Promise<void> {
    this.loading = true;
    this.loadFailed = false;
    try {
      const response = await getApplyList(userId);
      if (!response.success || !Array.isArray(response.obj)) {
        this.applyList = [];
        this.loadFailed = true;
        return;
      }

      const result = response.obj as User[];
      const applications: User[] = [];
      result.forEach((item: User) => {
        applications.push(new User(
          item.id === undefined || item.id === null ? 0 : item.id,
          item.username === undefined || item.username === null ? '' : item.username,
          item.name === undefined || item.name === null ? '' : item.name,
          item.headImg === undefined || item.headImg === null ? '' : item.headImg,
          item.addr === undefined || item.addr === null ? '' : item.addr,
          item.gender === undefined || item.gender === null ? '' : item.gender,
          item.lon === undefined || item.lon === null ? 0 : item.lon,
          item.lat === undefined || item.lat === null ? 0 : item.lat
        ));
      });
      this.applyList = applications;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load friend applications. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      this.applyList = [];
      this.loadFailed = true;
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Row() {
        PageBackButton()

        Text('申请列表')
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
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .shadow(ShadowStyle.OUTER_DEFAULT_XS)

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(34)
            .height(34)
            .color('#FF3551')

          Text('正在加载申请')
            .fontSize(14)
            .fontColor('#777777')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.loadFailed) {
        Column() {
          Text('申请列表加载失败')
            .fontSize(17)
            .fontColor('#333333')

          Button('重新加载')
            .height(40)
            .fontSize(15)
            .backgroundColor('#FF3551')
            .margin({ top: 15 })
            .onClick(() => {
              this.loadApplications();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.applyList.length === 0) {
        Column() {
          Image($r('app.media.ic_bell_normal'))
            .width(58)
            .height(58)
            .opacity(0.55)

          Text('暂无好友申请')
            .fontSize(17)
            .fontColor('#777777')
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({
          space: 10
        }) {
          ForEach(this.applyList, (item: User) => {
            ListItem() {
              ApplyItem({
                item: item
              });
            }
          }, (item: User) => item.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}

@Component
struct ApplyItem {
  @ObjectLink item: User;
  @State applyStatus: number = 2;
  @State processing: boolean = false;

  private process(status: number): void {
    if (this.processing || this.applyStatus !== 2) {
      return;
    }

    loginUserAction((user: User) => {
      this.submit(user.id, status);
    }, () => {
      showText('请先登录');
    });
  }

  private async submit(userId: number, status: number): Promise<void> {
    this.processing = true;
    try {
      const response = await processApply(userId, this.item.id, status);
      if (!response.success) {
        showText(response.info.length > 0 ? `操作失败：${response.info}` : '操作失败');
        return;
      }

      this.applyStatus = status;
      showText(status === 1 ? '已同意好友申请' : '已拒绝好友申请');
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to process friend application. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      showText('操作失败');
    } finally {
      this.processing = false;
    }
  }

  build() {
    Row() {
      Image(`${BaseUrl}${this.item.headImg}`)
        .alt($r('app.media.ic_user_icon_default'))
        .width(54)
        .height(54)
        .borderRadius(27)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(this.item.name.length > 0 ? this.item.name : this.item.username)
          .width('100%')
          .fontSize(17)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`你好，我是${this.item.name.length > 0 ? this.item.name : this.item.username}`)
          .width('100%')
          .fontSize(13)
          .fontColor('#777777')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 7 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12, right: 10 })

      if (this.applyStatus === 2) {
        Row() {
          Button('同意')
            .width(54)
            .height(34)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#2ECC71')
            .borderRadius(7)
            .enabled(!this.processing)
            .onClick(() => {
              this.process(1);
            })

          Button('拒绝')
            .width(54)
            .height(34)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#8A8A8A')
            .borderRadius(7)
            .enabled(!this.processing)
            .margin({ left: 6 })
            .onClick(() => {
              this.process(0);
            })
        }
      } else if (this.applyStatus === 1) {
        Text('已同意')
          .width(114)
          .fontSize(16)
          .fontColor('#2ECC71')
          .textAlign(TextAlign.Center)
      } else {
        Text('已拒绝')
          .width(114)
          .fontSize(16)
          .fontColor('#888888')
          .textAlign(TextAlign.Center)
      }
    }
    .width('94%')
    .height(94)
    .padding({ left: 14, right: 14 })
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
