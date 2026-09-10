import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';
import { Event } from '../viewmodel/Event';

export function getEventList(userId: number, kw: string = ''): Promise<ResultData> {
  const url: string = `${ServerPath.eventList}?userId=${userId}&kw=${encodeURIComponent(kw)}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function addEvent(event: Event): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: event
  };
  return httpRequest(ServerPath.addEvent, option);
}

export function getMyEventList(userId: number): Promise<ResultData> {
  const url: string = `${ServerPath.myEventList}?userId=${userId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function editEvent(event: Event): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.PUT,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: event
  };
  return httpRequest(ServerPath.editEvent, option);
}

export function deleteEvent(eventId: number): Promise<ResultData> {
  const url: string = `${ServerPath.deleteEvent}?eventId=${eventId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.DELETE
  };
  return httpRequest(url, option);
}
