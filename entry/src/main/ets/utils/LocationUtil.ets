import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

const LOCATION_PERMISSIONS: Permissions[] = [
  'ohos.permission.APPROXIMATELY_LOCATION',
  'ohos.permission.LOCATION'
];

export class LocationInfo {
  latitude: number;
  longitude: number;
  address: string;

  constructor(latitude: number, longitude: number, address: string = '') {
    this.latitude = latitude;
    this.longitude = longitude;
    this.address = address;
  }
}

export async function reqLocationPermissions(context: common.UIAbilityContext): Promise<boolean> {
  const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  try {
    const result = await atManager.requestPermissionsFromUser(context, LOCATION_PERMISSIONS);
    return result.authResults.length > 1 && result.authResults[1] === 0;
  } catch (error) {
    const businessError = error as BusinessError;
    console.error(`Failed to request location permissions. Code: ${businessError.code}, ` +
      `message: ${businessError.message}`);
    return false;
  }
}

export async function getCurrentLocationInfo(): Promise<LocationInfo> {
  const request: geoLocationManager.CurrentLocationRequest = {
    priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
    timeoutMs: 10000
  };
  const location = await geoLocationManager.getCurrentLocation(request);
  const locationInfo = new LocationInfo(location.latitude, location.longitude);
  if (!geoLocationManager.isGeocoderAvailable()) {
    return locationInfo;
  }

  try {
    const reverseRequest: geoLocationManager.ReverseGeoCodeRequest = {
      latitude: location.latitude,
      longitude: location.longitude,
      locale: 'zh',
      country: 'CN',
      maxItems: 1
    };
    const addresses = await geoLocationManager.getAddressesFromLocation(reverseRequest);
    if (addresses.length > 0) {
      const placeName = addresses[0].placeName;
      if (placeName !== undefined) {
        locationInfo.address = placeName;
      }
    }
  } catch (error) {
    const businessError = error as BusinessError;
    console.error(`Failed to reverse geocode location. Code: ${businessError.code}, ` +
      `message: ${businessError.message}`);
  }
  return locationInfo;
}
