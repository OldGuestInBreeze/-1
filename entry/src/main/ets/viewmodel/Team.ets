export class Team {
  eventId: number;
  eventName: string;
  createUserId: number;
  userInfoName: string;
  memberCount: number;
  headImg: string;
  addr: string;

  constructor(eventId: number, eventName: string, createUserId: number, userInfoName: string, memberCount: number,
    headImg: string, addr: string) {
    this.eventId = eventId === undefined || eventId === null ? 0 : eventId;
    this.eventName = eventName === undefined || eventName === null ? '' : eventName;
    this.createUserId = createUserId === undefined || createUserId === null ? 0 : createUserId;
    this.userInfoName = userInfoName === undefined || userInfoName === null ? '' : userInfoName;
    this.memberCount = memberCount === undefined || memberCount === null ? 0 : memberCount;
    this.headImg = headImg === undefined || headImg === null ? '' : headImg;
    this.addr = addr === undefined || addr === null ? '' : addr;
  }
}
