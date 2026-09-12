import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseUrl } from '../common/Constant';
import { getCurrentLocationInfo, reqLocationPermissions } from '../utils/LocationUtil';
import { showText } from '../utils/ShowUtil';
import { Location } from '../viewmodel/Location';

@Entry
@Component
struct MapPage {
  @State location: Location = {
    lat: 36,
    lng: 120
  };
  @State locating: boolean = false;
  @State mapFailed: boolean = false;
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    this.loadMap();
  }

  private async loadMap(): Promise<void> {
    if (this.locating) {
      return;
    }

    this.locating = true;
    this.mapFailed = false;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      const granted = await reqLocationPermissions(context);
      if (!granted) {
        this.mapFailed = true;
        showText('获取位置信息失败，请授予定位权限后重试');
        return;
      }

      const locationInfo = await getCurrentLocationInfo();
      this.location = {
        lat: locationInfo.latitude,
        lng: locationInfo.longitude
      };
      const mapUrl: string =
        `${BaseUrl}/static/map.html?lat=${this.location.lat}&lng=${this.location.lng}`;
      this.controller.loadUrl(mapUrl);
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`Failed to load nearby activity map. Code: ${businessError.code}, ` +
        `message: ${businessError.message}`);
      this.mapFailed = true;
      showText('获取位置信息失败，请确认已开启定位服务后重试');
    } finally {
      this.locating = false;
    }
  }

  private openEvent(url: string): boolean {
    if (!url.startsWith('event://')) {
      return false;
    }

    const eventId = parseInt(url.substring(8));
    if (eventId <= 0) {
      showText('活动信息无效');
      return true;
    }

    router.pushUrl({
      url: 'pages/EventInfoPage',
      params: {
        data: eventId
      }
    });
    return true;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back();
          })

        Text('附近活动')
          .layoutWeight(1)
          .fontSize(22)
          .fontColor('#222222')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

        Blank()
          .width(28)
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
          .onLoadIntercept((event) => {
            if (event === undefined || event === null) {
              return false;
            }
            return this.openEvent(event.data.getRequestUrl());
          })

        if (this.mapFailed) {
          Column() {
            Image($r('app.media.ic_loadfaild'))
              .width(70)
              .height(70)
              .objectFit(ImageFit.Contain)

            Text('附近活动加载失败')
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
                this.loadMap();
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
