import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';

export const BaseUrl: string = 'http://127.0.0.1:8081';

const HTTP_CODE_200: number = 200;

export interface ResultData {
  success: boolean;
  obj: object;
  info: string;
}

function showText(message: string): void {
  promptAction.showToast({ message });
}

export function httpRequest(url: string, option: http.HttpRequestOptions): Promise<ResultData> {
  const request: http.HttpRequest = http.createHttp();
  const serverData: ResultData = {
    success: false,
    obj: new Object(),
    info: ''
  };

  return request.request(`${BaseUrl}${url}`, option)
    .then((response: http.HttpResponse) => {
      if (response.responseCode !== HTTP_CODE_200) {
        showText('系统错误');
        serverData.info = `HTTP ${response.responseCode}`;
        return serverData;
      }

      const resultJson = JSON.parse(`${response.result}`) as ResultData;
      serverData.success = resultJson.success;
      serverData.obj = resultJson.obj;
      serverData.info = resultJson.info;
      return serverData;
    })
    .catch((error: BusinessError) => {
      showText('系统错误');
      serverData.info = error.message;
      return serverData;
    })
    .finally(() => {
      request.destroy();
    });
}
