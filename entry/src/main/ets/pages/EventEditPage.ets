import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { addEvent as requestAddEvent, editEvent as requestEditEvent } from '../api/EventApi';
import { BaseUrl } from '../common/Constant';
import { PageBackButton } from '../component/PageBackButton';
import { getCurrentLocationInfo, reqLocationPermissions } from '../utils/LocationUtil';
import { showText } from '../utils/ShowUtil';
import { selectImage } from '../utils/UploadUtil';
import { loginUserAction } from '../utils/UserUtil';
import { Event } from '../viewmodel/Event';
import { RouterParam } from '../viewmodel/RouterParam';
import { User } from '../viewmodel/User';

@Entry
@Component
struct EventEditPage {
  @State event: Event = new Event(0, 0, '', '', '', '', '', 120.39, 36.30, 0);
  @State showImage: boolean = false;
  @State type: string = 'add';
  @State locating: boolean = false;
  @State uploading: boolean = false;
  @State publishing: boolean = false;

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<Event>;
    if (param !== undefined && param.message !== undefined && param.message.length > 0) {
      this.type = param.message;
    }
    if (this.type === 'edit') {
      if (param === undefined || param.data === undefined || param.data.id <= 0) {
        showText('活动信息无效', () => {
          this.getUIContext().getRouter().back();
        });
        return;
      }

      const source = param.data;
      this.event = new Event(source.id, source.userId, source.name, source.intro, source.addr, source.headImg,
        source.startTime, source.lon, source.lat, source.state);
    }

    loginUserAction((user: User) => {
      this.event.userId = user.id;
      if (this.type === 'add') {
        this.loadCurrentLocation();
      }
    }, () => {
      showText('请先登录', () => {
        this.getUIContext().getRouter().back();
      });
    });
  }

  private async loadCurrentLocation(): Promise<void> {
    if (this.locating) {
      return;
    }

    this.locating = true;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      const granted = await reqLocationPermissions(context);
      if (!granted) {
        showText('获取位置信息失败，请手动填写活动位置');
        return;
      }

      const location = await getCurrentLocationInfo();
      this.event.lat = location.latitude;
      this.event.lon = location.longitude;
      if (location.address.length > 0) {
        this.event.addr = location.address;
      }
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to get current location. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      showText('获取位置信息失败，请确认已打开位置开关，或手动填写活动位置');
    } finally {
      this.locating = false;
    }
  }

  private async selectEventImage(): Promise<void> {
    if (this.uploading) {
      return;
    }

    this.uploading = true;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const imageUrl = await selectImage(context);
    this.uploading = false;
    if (imageUrl.length > 0) {
      this.event.headImg = imageUrl;
    }
  }

  private async submitEvent(): Promise<void> {
    const name = this.event.name.trim();
    const intro = this.event.intro.trim();
    const addr = this.event.addr.trim();
    if (name.length === 0 || intro.length === 0 || addr.length === 0 || this.event.headImg.length === 0) {
      showText('请填写完整活动信息');
      return;
    }
    if (this.event.userId <= 0) {
      showText('请先登录');
      return;
    }
    if (this.publishing || this.uploading) {
      return;
    }

    const event = new Event(this.event.id, this.event.userId, name, intro, addr, this.event.headImg,
      this.event.startTime, this.event.lon, this.event.lat, this.event.state);
    this.publishing = true;
    try {
      const result = this.type === 'edit' ? await requestEditEvent(event) : await requestAddEvent(event);
      if (!result.success) {
        showText(result.info.length > 0 ? result.info : (this.type === 'edit' ? '修改失败' : '发布失败'));
        return;
      }

      showText(result.info.length > 0 ? result.info : (this.type === 'edit' ? '修改成功' : '添加成功'), () => {
        this.getUIContext().getRouter().back();
      });
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to save event. Code: ${businessError.code}, message: ${businessError.message}`);
      showText(businessError.message.length > 0 ? businessError.message :
        (this.type === 'edit' ? '修改失败' : '发布失败'));
    } finally {
      this.publishing = false;
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          PageBackButton()

          Blank()

          Button(this.publishing ? (this.type === 'edit' ? '保存中' : '发布中') :
            (this.type === 'edit' ? '保存' : '发布'))
            .height(38)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FF3551')
            .borderRadius(20)
            .enabled(!this.publishing && !this.uploading)
            .onClick(() => {
              this.submitEvent();
            })
        }
        .width('100%')
        .height(70)
        .padding({ top: 20, left: 12, right: 12 })
        .backgroundColor(Color.White)

        TextInput({
          text: this.event.name,
          placeholder: '请填写活动标题'
        })
          .width('100%')
          .height(58)
          .padding({ left: 14, right: 14 })
          .fontSize(20)
          .fontColor('#333333')
          .placeholderColor('#777777')
          .placeholderFont({ size: 20, weight: FontWeight.Medium })
          .borderRadius(0)
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.event.name = value;
          })

        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')

        TextArea({
          text: this.event.intro,
          placeholder: '请填写活动描述'
        })
          .width('100%')
          .height(230)
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#777777')
          .borderRadius(0)
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.event.intro = value;
          })

        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')

        Row() {
          Image($r('app.media.event_position'))
            .width(22)
            .height(22)
            .objectFit(ImageFit.Contain)

          Text('活动地点')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 8 })

          TextInput({
            text: this.event.addr,
            placeholder: this.locating ? '正在获取当前位置' : '请填写活动地点'
          })
            .layoutWeight(1)
            .height(52)
            .fontSize(15)
            .fontColor('#555555')
            .placeholderColor('#888888')
            .textAlign(TextAlign.End)
            .borderRadius(0)
            .backgroundColor(Color.White)
            .onChange((value: string) => {
              this.event.addr = value;
            })
        }
        .width('100%')
        .height(62)
        .padding({ left: 14, right: 14 })
        .backgroundColor(Color.White)

        Divider()
          .strokeWidth(1)
          .color('#EEEEEE')

        Text('活动图片')
          .width('100%')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .padding({ left: 14, right: 14, top: 14, bottom: 12 })
          .backgroundColor(Color.White)

        Row() {
          if (this.event.headImg.length > 0) {
            Image(`${BaseUrl}${this.event.headImg}`)
              .width(80)
              .height(80)
              .borderRadius(5)
              .objectFit(ImageFit.Cover)
              .margin({ right: 16 })
              .onClick(() => {
                this.showImage = true;
              })
          }

          Stack({ alignContent: Alignment.Center }) {
            Image($r('app.media.ic_img_add'))
              .width(80)
              .height(80)
              .objectFit(ImageFit.Cover)

            if (this.uploading) {
              Text('上传中')
                .width(80)
                .height(80)
                .fontSize(13)
                .fontColor('#777777')
                .textAlign(TextAlign.Center)
                .backgroundColor('#CCFFFFFF')
            }
          }
          .onClick(() => {
            this.selectEventImage();
          })
        }
        .width('100%')
        .padding({ left: 8, right: 8, bottom: 16 })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)

      if (this.showImage) {
        Column() {
          Image(`${BaseUrl}${this.event.headImg}`)
            .width('100%')
            .objectFit(ImageFit.Contain)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Black)
        .onClick(() => {
          this.showImage = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
