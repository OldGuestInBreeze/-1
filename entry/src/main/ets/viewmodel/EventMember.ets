@Observed
export class EventMember {
  userId: number;
  name: string;
  addr: string;
  headImg: string;
  apply: number;

  constructor(userId: number, name: string, addr: string, headImg: string, apply: number) {
    this.userId = userId === undefined || userId === null ? 0 : userId;
    this.name = name === undefined || name === null ? '' : name;
    this.addr = addr === undefined || addr === null ? '' : addr;
    this.headImg = headImg === undefined || headImg === null ? '' : headImg;
    this.apply = apply === undefined || apply === null ? 0 : apply;
  }
}
