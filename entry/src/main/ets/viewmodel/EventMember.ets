@Observed
export class EventMember {
  userId: number;
  name: string;
  addr: string;
  headImg: string;
  apply: number;

  constructor(userId: number, name: string, addr: string, headImg: string, apply: number) {
    this.userId = userId;
    this.name = name;
    this.addr = addr;
    this.headImg = headImg;
    this.apply = apply;
  }
}
