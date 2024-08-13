import { LogUtil } from './LoggerUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface Printer {
  debug(tag: string, content: string): void;

  info(tag: string, content: string): void;

  warn(tag: string, content: string): void;

  error(tag: string, content: string): void;

  json(tag: string, content: string | object | null): void;
}

export class LoggerPrinter implements Printer {
  private _topLeft = '┌';
  private _bottomLeft = '└';
  private _topRight = '┐';
  private _bottomRight = '┘';
  private _verticalLine = '│';
  private _divider = "────────────────────────────────────────────────────────";
  /// 当需要点击调转到某个文件的时候添加
  private _singleDivider = "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄";
  //  暂时发现 在 macOs 上 ，应用内，上面的几个都 识别不了
  private _verticalLineMacOs = '| ';
  private _dividerMacOs = "——————————————————————————————————————————————————————";
  //  暂时发现 在 ios 上 ，应用内 _verticalLine 有空格，所以替换成这个
  private _verticalLineIos = '｜';
  private _topBorder = `${this._topLeft}${this._divider}${this._divider}${this._topRight}`
  private _bottomBorder = `${this._bottomLeft}${this._divider}${this._divider}${this._bottomRight}`

  json(tag: string, content: string | object | null): void {
    // console.print()
    if (content) {
      if (typeof content === 'string') {
        this.print(LogLevel.DEBUG, content, tag);
      } else {
        const prettyJsonString = JSON.stringify(content, null, 2); // 4 是缩进的空格数
        this.print(LogLevel.DEBUG, tag, prettyJsonString, true);
      }

    } else {
      this.print(LogLevel.DEBUG, 'json的内容是null', tag)
    }
  }

  debug(tag: string, content: string): void {
    this.print(LogLevel.DEBUG, tag, content)
  }


  info(tag: string, content: string): void {
    this.print(LogLevel.INFO, tag, content)
  }

  warn(tag: string, content: string): void {
    this.print(LogLevel.WARN, tag, content)
  }

  error(tag: string, content: string): void {
    this.print(LogLevel.ERROR, tag, content)
  }

  print(level: LogLevel, tag: string, content: string, isJson: boolean = false) {
    let prefix: string = `${this._verticalLine}`
    // 获取当前 拿到当前文件名字 和 行号
    let fileLocation = LogUtil.getCurrentLocation()
    // 最上面的线
    this.logPrint(level, tag, this._topBorder)
    // 文件名
    this.logPrint(level, tag, `${prefix} ${fileLocation}`)
    // 文件名的线
    this.logPrint(level, tag, `${prefix}${this._singleDivider}`)
    if (isJson) {
      // 日志过于频繁 发现日志不打印，bug
      content.split('\n').forEach((value,index,array) => {
        this.logPrint(level, tag, ` ${index}--${array.length} ${prefix} ${value}`)
      })
    } else {
      this.logPrint(level, tag, `${prefix} ${content}`)
    }
    // 最下面的线
    this.logPrint(level, tag, `${this._bottomBorder}`)


  }

  private logPrint(level: LogLevel, tag: string, content: string) {
    switch (level) {
      case LogLevel.INFO:
        hilog.info(0x0000, tag, content)
        break
      case LogLevel.DEBUG:
        hilog.debug(0x0000, tag, content)
        break
      case LogLevel.WARN:
        hilog.warn(0x0000, tag, content)
        break
      case LogLevel.ERROR:
        hilog.error(0x0000, tag, content)
        break
    }

  }
}

export enum LogLevel {
  INFO,
  DEBUG,
  WARN,
  ERROR,
}