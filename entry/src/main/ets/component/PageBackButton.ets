@Component
export struct PageBackButton {
  @Prop icon: Resource = $r('app.media.ic_back');

  private returnToPreviousPage(): void {
    const pageRouter = this.getUIContext().getRouter();
    const pageCount = parseInt(pageRouter.getLength());
    if (pageCount > 1) {
      pageRouter.back();
      return;
    }

    pageRouter.replaceUrl({
      url: 'pages/Index'
    });
  }

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
      this.returnToPreviousPage();
    })
  }
}
