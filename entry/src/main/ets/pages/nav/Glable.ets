import { FindPage } from './FindPage'
import { MinePage } from './MinePage'
import { SecondPage } from './SecondPage/SecondPage'

@Builder
export function PageMap(name: string) {
  if (name === "SecondPage") {
    SecondPage()
  } else if (name === "NavDestinationTitle2") {
    FindPage()
  } else if (name === "NavDestinationTitle3") {
    MinePage()
  }
}