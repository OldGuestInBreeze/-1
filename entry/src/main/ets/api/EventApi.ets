import { http } from '@kit.NetworkKit';
import { ServerPath } from '../common/Constant';
import { httpRequest, ResultData } from '../utils/HttpRequest';
import { Event } from '../viewmodel/Event';
import { EventComment } from '../viewmodel/EventComment';

export function getEventList(userId: number, kw: string = ''): Promise<ResultData> {
  const url: string = `${ServerPath.eventList}?userId=${userId}&kw=${encodeURIComponent(kw)}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function getEventInfo(eventId: number): Promise<ResultData> {
  const url: string = `${ServerPath.eventInfo}?eventId=${eventId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function getCommentList(eventId: number): Promise<ResultData> {
  const url: string = `${ServerPath.getComment}?eventId=${eventId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.GET
  };
  return httpRequest(url, option);
}

export function addComment(comment: EventComment): Promise<ResultData> {
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: comment
  };
  return httpRequest(ServerPath.addComment, option);
}

export function Join(userId: number, eventId: number): Promise<ResultData> {
  const url: string = `${ServerPath.join}?userId=${userId}&eventId=${eventId}`;
  const option: http.HttpRequestOptions = {
    method: http.RequestMethod.POST
  };
  return httpRequest(url, option);
}

export function isJoin(userId: number, eventId: number): Promise<ResultData> {
  const url: string = `${ServerPath.isJoin}?userId=${userId}&eventId=${eventId}`;
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
