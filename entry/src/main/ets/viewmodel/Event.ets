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
    this.id = id === undefined || id === null ? 0 : id;
    this.userId = userId === undefined || userId === null ? 0 : userId;
    this.name = name === undefined || name === null ? '' : name;
    this.intro = intro === undefined || intro === null ? '' : intro;
    this.addr = addr === undefined || addr === null ? '' : addr;
    this.headImg = headImg === undefined || headImg === null ? '' : headImg;
    this.startTime = startTime === undefined || startTime === null ? '' : startTime;
    this.lon = lon === undefined || lon === null ? 0 : lon;
    this.lat = lat === undefined || lat === null ? 0 : lat;
    this.state = state === undefined || state === null ? 0 : state;
  }
}
