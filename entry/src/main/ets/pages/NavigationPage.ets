import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseUrl } from '../common/Constant';
import { PageBackButton } from '../component/PageBackButton';
import { getCurrentLocationInfo, reqLocationPermissions } from '../utils/LocationUtil';
import { showText } from '../utils/ShowUtil';
import { Location } from '../viewmodel/Location';
import { RouterParam } from '../viewmodel/RouterParam';

@Entry
@Component
struct NavigationPage {
  @State myLocation: Location = {
    lat: 36,
    lng: 120
  };
  @State eventLocation: Location = {
    lat: 36,
    lng: 120
  };
  @State locating: boolean = false;
  @State navigationFailed: boolean = false;
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const param = router.getParams() as RouterParam<Location>;
    if (param === undefined || param.data === undefined || param.data === null ||
      param.data.lat === undefined || param.data.lat === null ||
      param.data.lng === undefined || param.data.lng === null ||
      (param.data.lat === 0 && param.data.lng === 0)) {
      this.navigationFailed = true;
      showText('活动位置信息无效', () => {
        router.back();
      });
      return;
    }

    this.eventLocation = {
      lat: param.data.lat,
      lng: param.data.lng
    };
    this.loadNavigation();
  }

  private async loadNavigation(): Promise<void> {
    if (this.locating) {
      return;
    }

    this.locating = true;
    this.navigationFailed = false;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      const granted = await reqLocationPermissions(context);
      if (!granted) {
        this.navigationFailed = true;
        showText('获取位置信息失败，请授予定位权限后重试');
        return;
      }

      const locationInfo = await getCurrentLocationInfo();
      this.myLocation = {
        lat: locationInfo.latitude,
        lng: locationInfo.longitude
      };
      const navigationUrl: string = `${BaseUrl}/static/navigationMap.html` +
        `?olat=${this.myLocation.lat}&olng=${this.myLocation.lng}` +
        `&dlat=${this.eventLocation.lat}&dlng=${this.eventLocation.lng}`;
      this.controller.loadUrl(navigationUrl);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load activity navigation. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      this.navigationFailed = true;
      showText('导航加载失败，请确认已开启定位服务后重试');
    } finally {
      this.locating = false;
    }
  }

  build() {
    Column() {
      Row() {
        PageBackButton()

        Text('活动导航')
          .layoutWeight(1)
          .fontSize(22)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

        Blank()
          .width(44)
      }
      .width('100%')
      .height(54)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .shadow(ShadowStyle.OUTER_DEFAULT_XS)

      Stack() {
        Web({
          src: $rawfile('loading.html'),
          controller: this.controller
        })
          .width('100%')
          .height('100%')

        if (this.navigationFailed) {
          Column() {
            Image($r('app.media.ic_loadfaild'))
              .width(70)
              .height(70)
              .objectFit(ImageFit.Contain)

            Text('活动导航加载失败')
              .fontSize(17)
              .fontColor('#333333')
              .margin({ top: 14 })

            Button('重新获取位置')
              .height(42)
              .fontSize(15)
              .backgroundColor('#FF3551')
              .borderRadius(21)
              .margin({ top: 18 })
              .onClick(() => {
                this.loadNavigation();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F8F8F8')
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
