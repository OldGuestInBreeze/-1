@Observed
export class User {
  id: number;
  username: string;
  name: string;
  headImg: string;
  addr: string;
  gender: string;
  lon: number;
  lat: number;

  constructor(id: number, username: string, name: string, headImg: string, addr: string,
    gender: string, lon: number, lat: number) {
    this.id = id;
    this.username = username;
    this.name = name;
    this.headImg = headImg;
    this.addr = addr;
    this.gender = gender;
    this.lon = lon;
    this.lat = lat;
  }
}
