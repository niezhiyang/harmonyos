import { hilog } from '@kit.PerformanceAnalysisKit';

export class LogUtil {
  static getCurrentLocation(): string {
    const error = new Error();
    const stack = error.stack?.split("\n");
    if (stack && stack.length > 3) {
      const location = stack[4].match(/(\(.*\)|\s*at\s+(.*))/);
      if (location) {
        // const locationInfo = location[0].trim().split('/').pop() as string;
        const locationInfo = location[0].trim();
        const regex = /([^/]+\.(ts|js|ets):\d+:\d+)/;
        const match = locationInfo.match(regex);
        if (match) {
          // 在控制台输出文件名和行号
          return match[1]; // 输出: NetPage.ets:15
        }
        return ``
      }
    }
    return ''
  }
}