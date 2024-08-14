import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, picker } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Logger } from '@nzy/logger';

@Entry
@Component
struct PhotoPage {
  @State message: string = 'Hello World';
  url = "https://static.jiduapp.cn/v1/a9994116e83f428fbcecbc63c18b3f5d.mp4"

  aboutToAppear() {
  }

  build() {
    Column() {
      SaveButton().onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
        if (result == SaveButtonOnClickResult.SUCCESS) {
          try {
            const context = getContext(this);
            let helper = photoAccessHelper.getPhotoAccessHelper(context);
            // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回。
            let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
            // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
            let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            // 写入文件
            await fileIo.write(file.fd, context.resourceManager.getRawFileContentSync('img1.webp').buffer);
            // 关闭文件
            await fileIo.close(file.fd);
            Logger.info(TAG, "保存成功")
            promptAction.showToast({ message: '保存成功' })

          } catch (error) {
            Logger.error("error is " + JSON.stringify(error));
          }
        }
      })
      Button('选择').onClick(() => {
        fileSelect().then((result: Array<string>) => {
          if (result[0]) {
            let file = fs.openSync(result[0], fs.OpenMode.READ_ONLY) // 打开文件为只读模式
            let fileFD = file.fd
            let destPath = getContext().cacheDir // 获取缓存目录路径
            let fileName = Date.now().toString() + '.mp4' // 生成新的文件名
            let fullPath = destPath + '/' + fileName
            AlertDialog.show({ message: '完整路径' + fullPath })
            fs.copyFileSync(fileFD, fullPath) // 拷贝文件
          }

        })
      })
    }
    .height('100%')
    .width('100%')
  }
}

let TAG = "download"

function download(url: string, callback: Callback<ArrayBuffer>) {
  http.createHttp().request(url,
    {
      method: http.RequestMethod.GET,
      connectTimeout: 60000,
      readTimeout: 60000
    },
    async (error: BusinessError, data: http.HttpResponse) => {
      if (error) {
        console.error(`http reqeust failed with. Code: ${error.code}, message: ${error.message}`);
      } else {
        if (http.ResponseCode.OK === data.responseCode) {
          let imageBuffer: ArrayBuffer = data.result as ArrayBuffer;
          callback(imageBuffer)
        } else {
          console.error("error occurred when image downloaded!")
        }
      }
    })
}

export async function fileSelect(): Promise<Array<string>> {
  let photoSelectOptions = new picker.PhotoSelectOptions();
  photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
  photoSelectOptions.maxSelectNumber = 2;
  let photoPicker = new picker.PhotoViewPicker();
  try {
    let photoSelectResult = await photoPicker.select(photoSelectOptions);
    if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
      let imgUri = photoSelectResult.photoUris;
      return imgUri;
    } else {
      return [];
    }
  } catch (err) {
    console.error('SelectedImage failed', JSON.stringify(err));
    return [];
  }
}

