import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { createNWeb } from '../component/common';
import { Logger } from '../util/log/Logger';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info("EntryAbility", '我是一个info类型日志 我的----')
    for (let index = 0; index++; index < 1000) {
      console.log(`----${index}-----`)
    }
    windowStage.loadContent('pages/Index', (err) => {
      createNWeb("https://www.example.com", windowStage.getMainWindowSync().getUIContext());
    });
  }
}

