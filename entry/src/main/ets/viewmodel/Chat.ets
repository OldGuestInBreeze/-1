export class Chat {
  id: number;
  userIdFrom: number;
  userIdTo: number;
  content: string;
  createTime: string;

  constructor(id: number, userIdFrom: number, userIdTo: number, content: string, createTime: string) {
    this.id = id === undefined || id === null ? 0 : id;
    this.userIdFrom = userIdFrom === undefined || userIdFrom === null ? 0 : userIdFrom;
    this.userIdTo = userIdTo === undefined || userIdTo === null ? 0 : userIdTo;
    this.content = content === undefined || content === null ? '' : content;
    this.createTime = createTime === undefined || createTime === null ? '' : createTime;
  }
}
