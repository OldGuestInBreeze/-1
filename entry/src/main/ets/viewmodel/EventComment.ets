export class EventComment {
  eventId: number;
  userId: number;
  content: string;
  name?: string;
  headImg?: string;
  createTime?: string;

  constructor(eventId: number, userId: number, content: string) {
    this.eventId = eventId;
    this.userId = userId;
    this.content = content;
  }
}
