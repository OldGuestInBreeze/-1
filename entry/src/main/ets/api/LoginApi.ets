import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';

export function login(username: string, password: string): Promise<ResultData> {
  const url: string = ServerPath.login;
  const param: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: {
      username: username,
      password: password
    }
  };
  return httpRequest(url, param);
}
