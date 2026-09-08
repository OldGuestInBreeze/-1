export function showText(text: string, action: () => void = () => {}): void {
  AlertDialog.show({
    message: text,
    alignment: DialogAlignment.Center,
    primaryButton: {
      value: '确定',
      action
    }
  });
}
