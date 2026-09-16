import { BusinessError } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';
import { BaseUrl, HTTP_CODE_200, HTTP_READ_TIMEOUT } from '../common/Constant';
import { showText } from './ShowUtil';

export interface ResultData {
  success: boolean;
  obj: object;
  info: string;
}

export function httpRequest(url: string, option: http.HttpRequestOptions): Promise<ResultData> {
  const request: http.HttpRequest = http.createHttp();
  const serverData: ResultData = {
    success: false,
    obj: new Object(),
    info: ''
  };

  if (option.readTimeout === undefined) {
    option.readTimeout = HTTP_READ_TIMEOUT;
  }

  return request.request(`${BaseUrl}${url}`, option)
    .then((response: http.HttpResponse) => {
      if (response.responseCode !== HTTP_CODE_200) {
        showText('\u7CFB\u7EDF\u9519\u8BEF');
        serverData.info = `HTTP ${response.responseCode}`;
        return serverData;
      }

      const resultJson = JSON.parse(`${response.result}`) as ResultData;
      serverData.success = resultJson.success;
      serverData.obj = resultJson.obj === undefined || resultJson.obj === null ? new Object() : resultJson.obj;
      serverData.info = resultJson.info === undefined || resultJson.info === null ? '' : resultJson.info;
      return serverData;
    })
    .catch((error: BusinessError) => {
      showText('\u7CFB\u7EDF\u9519\u8BEF');
      serverData.info = error.message;
      return serverData;
    })
    .finally(() => {
      request.destroy();
    });
}
