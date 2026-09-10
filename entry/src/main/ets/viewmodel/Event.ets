@Observed
export class Event {
  id: number;
  userId: number;
  name: string;
  intro: string;
  addr: string;
  headImg: string;
  startTime: string;
  lon: number;
  lat: number;
  state: number;

  constructor(id: number, userId: number, name: string, intro: string, addr: string, headImg: string,
    startTime: string, lon: number, lat: number, state: number) {
    this.id = id;
    this.userId = userId;
    this.name = name;
    this.intro = intro;
    this.addr = addr;
    this.headImg = headImg;
    this.startTime = startTime;
    this.lon = lon;
    this.lat = lat;
    this.state = state;
  }
}
