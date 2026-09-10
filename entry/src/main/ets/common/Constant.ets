export const BaseUrl: string = 'http://192.168.5.75:8081';

export const ServerPath: Record<string, string> = {
  'login': '/user/login',
  'eventList': '/event/list',
  'register': '/user/reg',
  'isJoin': '/event/isJoin',
  'teamList': '/eventMember/teamList',
  'getComment': '/eventComment/listByEventId',
  'addComment': '/eventComment/insert',
  'join': '/eventMember/join',
  'eventMemberList': '/eventMember/list',
  'sendApply': '/friend/sendApply',
  'applyList': '/friend/applyList',
  'friendList': '/friend/getFriendList',
  'processApply': '/friend/processApply',
  'friendStatus': '/friend/status',
  'userInfo': '/user/info',
  'updatePassword': '/user/updatePassword',
  'RecommendEvent': '/event/recommend',
  'UpdateUserInfo': '/user/update',
  'searchList': '/event/searchEventInfoList',
  'addEvent': '/event/insert',
  'editEvent': '/event/edit',
  'myEventList': '/event/myEventList',
  'deleteEvent': '/event/delete',
  'uploadImg': '/upload/uploadFile',
  'eventInfo': '/event/info',
  'chatList': '/chat/byUserIdFromAndTo',
  'chatAdd': '/chat/insert'
};

export const PREFERENCES_NAME: string = 'hobby.db';
export const HTTP_CODE_200: number = 200;
export const HTTP_READ_TIMEOUT: number = 10000;
