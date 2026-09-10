import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BaseUrl, ServerPath } from '../common/Constant';
import { ResultData } from './HttpRequest';

interface UploadHeader {
  body?: string;
}

export async function selectImage(context: common.UIAbilityContext): Promise<string> {
  try {
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = 1;

    const picker = new photoAccessHelper.PhotoViewPicker();
    const result = await picker.select(options);
    if (result.photoUris.length === 0) {
      return '';
    }

    const cacheFileName = `avatar-${Date.now()}.jpg`;
    const sourceFile = fileIo.openSync(result.photoUris[0], fileIo.OpenMode.READ_ONLY);
    try {
      fileIo.copyFileSync(sourceFile.fd, `${context.cacheDir}/${cacheFileName}`);
    } finally {
      fileIo.closeSync(sourceFile);
    }
    return uploadImage(context, cacheFileName);
  } catch (error) {
    const businessError = error as BusinessError;
    console.error(`Failed to select image. Code: ${businessError.code}, message: ${businessError.message}`);
    return '';
  }
}

function uploadImage(context: common.UIAbilityContext, cacheFileName: string): Promise<string> {
  const config: request.UploadConfig = {
    url: `${BaseUrl}${ServerPath.uploadImg}`,
    header: {
      'Accept': 'application/json'
    },
    method: 'POST',
    files: [
      {
        filename: cacheFileName,
        name: 'file',
        uri: `internal://cache/${cacheFileName}`,
        type: 'image/jpeg'
      }
    ],
    data: []
  };

  return new Promise<string>((resolve, reject) => {
    request.uploadFile(context, config)
      .then((uploadTask: request.UploadTask) => {
        uploadTask.on('headerReceive', (header: object) => {
          try {
            const bodyText = (header as UploadHeader).body;
            if (bodyText === undefined || bodyText.length === 0) {
              reject(new Error('Upload response is empty'));
              return;
            }

            const body = JSON.parse(bodyText) as ResultData;
            if (!body.success) {
              reject(new Error(body.info));
              return;
            }
            resolve(body.obj.toString());
          } catch (error) {
            reject(error);
          }
        });
        uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
          const message = taskStates.length > 0 ? taskStates[0].message : 'Upload failed';
          reject(new Error(message));
        });
      })
      .catch((error: BusinessError) => {
        console.error(`Failed to upload image. Code: ${error.code}, message: ${error.message}`);
        reject(error);
      });
  });
}
