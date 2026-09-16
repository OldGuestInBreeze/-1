import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';

export function getChatList(userIdFrom: number, userIdTo: number): Promise<ResultData> {
  const url: string =
    `${ServerPath.chatList}?userIdFrom=${userIdFrom}&userIdTo=${userIdTo}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function addChatList(userIdFrom: number, userIdTo: number, content: string): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: {
      userIdFrom: userIdFrom,
      userIdTo: userIdTo,
      content: content
    }
  };
  return httpRequest(ServerPath.chatAdd, option);
}
