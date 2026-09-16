import { common } from '@kit.AbilityKit';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BaseUrl, ServerPath } from '../common/Constant';
import { ResultData } from './HttpRequest';
import { showText } from './ShowUtil';

interface UploadHeader {
  body?: string | ResultData;
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
    showText('图片上传失败，请检查后端服务和网络');
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
    let settled: boolean = false;
    request.uploadFile(context, config)
      .then((uploadTask: request.UploadTask) => {
        uploadTask.on('headerReceive', (header: object) => {
          if (settled) {
            return;
          }

          try {
            const responseBody = (header as UploadHeader).body;
            if (responseBody === undefined) {
              return;
            }

            let body: ResultData;
            if (typeof responseBody === 'string') {
              if (responseBody.length === 0) {
                return;
              }
              body = JSON.parse(responseBody) as ResultData;
            } else {
              body = responseBody;
            }
            if (!body.success) {
              settled = true;
              reject(new Error(body.info));
              return;
            }

            if (body.obj === undefined || body.obj === null) {
              settled = true;
              reject(new Error('Upload response is empty'));
              return;
            }

            const imageUrl = body.obj.toString();
            if (imageUrl.length === 0) {
              settled = true;
              reject(new Error('Upload response is empty'));
              return;
            }

            settled = true;
            resolve(imageUrl);
          } catch (error) {
            settled = true;
            reject(error);
          }
        });
        uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
          if (settled) {
            return;
          }

          if (taskStates.length === 0 || taskStates[0].responseCode !== 0) {
            const message = taskStates.length > 0 ? taskStates[0].message : 'Upload failed';
            settled = true;
            reject(new Error(message));
            return;
          }

          settled = true;
          reject(new Error('Upload response is empty'));
        });
        uploadTask.on('fail', (taskStates: Array<request.TaskState>) => {
          if (settled) {
            return;
          }

          const message = taskStates.length > 0 ? taskStates[0].message : 'Upload failed';
          settled = true;
          reject(new Error(message));
        });
      })
      .catch((error: BusinessError) => {
        console.error(`Failed to upload image. Code: ${error.code}, message: ${error.message}`);
        settled = true;
        reject(error);
      });
  });
}
