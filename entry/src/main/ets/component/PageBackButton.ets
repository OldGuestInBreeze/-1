import { router } from '@kit.ArkUI';

function returnToPreviousPage(): void {
  const pageCount = parseInt(router.getLength());
  if (pageCount > 1) {
    router.back();
    return;
  }

  router.replaceUrl({
    url: 'pages/Index'
  });
}

@Component
export struct PageBackButton {
  @Prop icon: Resource = $r('app.media.ic_back');

  build() {
    Button({ type: ButtonType.Circle }) {
      Image(this.icon)
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
    }
    .width(44)
    .height(44)
    .padding(0)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      returnToPreviousPage();
    })
  }
}
