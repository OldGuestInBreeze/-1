import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';

export function getFriendList(userId: number): Promise<ResultData> {
  const url: string = `${ServerPath.friendList}?userId=${userId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function getApplyList(userId: number): Promise<ResultData> {
  const url: string = `${ServerPath.applyList}?userId=${userId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function sendApply(userId: number, friendId: number): Promise<ResultData> {
  const url: string = `${ServerPath.sendApply}?userId=${userId}&friendId=${friendId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST
  };
  return httpRequest(url, option);
}

export function getFriendStatus(userId: number, memberId: number): Promise<ResultData> {
  const url: string = `${ServerPath.friendStatus}?userId=${userId}&memberId=${memberId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function processApply(userId: number, friendId: number, apply: number): Promise<ResultData> {
  const url: string =
    `${ServerPath.processApply}?userId=${userId}&friendId=${friendId}&apply=${apply}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST
  };
  return httpRequest(url, option);
}
