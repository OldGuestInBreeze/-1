import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';

export function getEventList(userId: number, kw: string = ''): Promise<ResultData> {
  const url: string = `${ServerPath.eventList}?userId=${userId}&kw=${encodeURIComponent(kw)}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}
