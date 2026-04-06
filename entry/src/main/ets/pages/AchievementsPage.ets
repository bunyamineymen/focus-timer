import { router } from '@kit.ArkUI'
import { ACHIEVEMENTS, Achievement, AchievementProgress } from '../model/Achievement'
import { AchievementService } from '../service/AchievementService'
import BadgeCard from '../components/BadgeCard'
import { SizeConstants } from '../constants/SizeConstants'

@Entry
@Component
struct AchievementsPage {
  @State progressList: AchievementProgress[] = []
  @State unlockedCount: number = 0

  aboutToAppear() {
    const service = AchievementService.getInstance()
    this.progressList = service.getAllProgress()
    this.unlockedCount = service.getUnlockedCount()
  }

  build() {
    Column() {
      // Header
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontColor([Color.White])
            .fontSize(16)
        }
        .width(28)
        .height(28)
        .borderRadius(14)
        .backgroundColor('#333333')
        .onClick(() => router.back())

        Text($r('app.string.achievements'))
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(28)
      }
      .width(SizeConstants.FULL_WIDTH_PERCENT)
      .padding({ left: 8, right: 8, top: 4 })

      // Progress summary
      Row({ space: 8 }) {
        Text(`${this.unlockedCount}`)
          .fontSize(22)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
        Text('/')
          .fontSize(16)
          .fontColor('#666666')
        Text(`${ACHIEVEMENTS.length}`)
          .fontSize(16)
          .fontColor('#888888')
      }
      .margin({ top: 4, bottom: 4 })
      .justifyContent(FlexAlign.Center)
      .width(SizeConstants.FULL_WIDTH_PERCENT)

      Progress({ value: this.unlockedCount, total: ACHIEVEMENTS.length })
        .width('80%')
        .height(4)
        .color('#FFD700')
        .backgroundColor('#333333')
        .margin({ bottom: 8 })

      // Badge grid
      Scroll() {
        Grid() {
          ForEach(ACHIEVEMENTS, (achievement: Achievement, index: number) => {
            GridItem() {
              BadgeCard({
                achievement: achievement,
                progress: this.progressList[index] ?? {
                  achievementId: achievement.id,
                  currentValue: 0,
                  unlocked: false
                }
              })
            }
          }, (achievement: Achievement) => achievement.id)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(4)
        .padding(8)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .height(SizeConstants.FULL_HEIGHT_PERCENT)
    .backgroundColor('#0D0D0D')
  }
}
