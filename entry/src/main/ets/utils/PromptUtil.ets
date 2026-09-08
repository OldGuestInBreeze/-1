import { promptAction } from '@kit.ArkUI';

export function showText(message: string): void {
  promptAction.showToast({ message });
}
