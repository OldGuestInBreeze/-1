import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';
import { User } from '../viewmodel/User';

export function updateUserInfo(userInfo: User): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.PUT,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: userInfo
  };
  return httpRequest(ServerPath.UpdateUserInfo, option);
}

export function updatePassword(id: number, password: string): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.PUT,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: {
      id: id.toString(),
      password: password
    }
  };
  return httpRequest(ServerPath.updatePassword, option);
}
