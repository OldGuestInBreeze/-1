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
    this.eventId = eventId;
    this.eventName = eventName;
    this.createUserId = createUserId;
    this.userInfoName = userInfoName;
    this.memberCount = memberCount;
    this.headImg = headImg;
    this.addr = addr;
  }
}
