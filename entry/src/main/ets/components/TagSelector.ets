import { DEFAULT_TAGS, Tag } from '../model/TagModel'
import { SizeConstants } from '../constants/SizeConstants'

@Component
export default struct TagSelector {
  @Link selectedTagId: string
  private tags: Tag[] = DEFAULT_TAGS

  build() {
    Column({ space: 8 }) {
      Text($r('app.string.select_tag'))
        .fontSize(12)
        .fontColor('#CCCCCC')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, space: { main: LengthMetrics.vp(6), cross: LengthMetrics.vp(6) } }) {
        ForEach(this.tags, (tag: Tag) => {
          Row({ space: 4 }) {
            SymbolGlyph(tag.icon)
              .fontSize(12)
              .fontColor([this.selectedTagId === tag.id ? Color.White : tag.color])

            Text(tag.name)
              .fontSize(10)
              .fontColor(this.selectedTagId === tag.id ? Color.White : '#CCCCCC')
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(16)
          .backgroundColor(this.selectedTagId === tag.id ? tag.color : '#2A2A2A')
          .border({
            width: 1,
            color: this.selectedTagId === tag.id ? tag.color : '#444444'
          })
          .onClick(() => {
            this.selectedTagId = this.selectedTagId === tag.id ? '' : tag.id
          })
        }, (tag: Tag) => tag.id)
      }
      .width(SizeConstants.FULL_WIDTH_PERCENT)
    }
  }
}
