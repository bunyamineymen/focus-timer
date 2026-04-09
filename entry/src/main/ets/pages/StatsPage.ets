import StatsChart from '../components/StatsChart'
import CalendarHeatmap from '../components/CalendarHeatmap'
import GoalRingView from '../components/GoalRingView'
import { DailyGoal } from '../model/GoalModel'
import { DbService } from '../service/DbService'
import { StreakTracker } from '../service/StreakTracker'
import { SizeConstants } from '../constants/SizeConstants'

@Component
export struct StatsPage {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State weeklyData: number[] = [0, 0, 0, 0, 0, 0, 0]
  @State tagData: string[] = []
  @State heatmapData: string[] = []
  @State totalSessions: number = 0
  @State totalMinutes: number = 0
  @State currentStreak: number = 0
  @State maxStreak: number = 0
  @State goal: DailyGoal = new DailyGoal()

  async aboutToAppear() {
    await this.loadStats()
  }

  build() {
    NavDestination() {
      Column() {
        // Header
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontColor([Color.White])
              .fontSize(16)
          }
          .width(SizeConstants.HEADER_BUTTON_SIZE)
          .height(SizeConstants.HEADER_BUTTON_SIZE)
          .borderRadius(SizeConstants.HEADER_BUTTON_RADIUS)
          .backgroundColor('#333333')
          .onClick(() => this.pageInfos.pop())

          Text($r('app.string.statistics'))
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Blank().width(SizeConstants.HEADER_BUTTON_SIZE)
        }
        .width(SizeConstants.FULL_WIDTH_PERCENT)
        .padding({
          left: SizeConstants.PAGE_SIDE_PADDING,
          right: SizeConstants.PAGE_SIDE_PADDING,
          top: SizeConstants.PAGE_HEADER_TOP_PADDING,
          bottom: 6
        })

        Scroll() {
          Column({ space: 12 }) {
            // Goal ring
            GoalRingView({ goal: this.goal })

            Divider().color('#333333')

            // Summary cards
            Row({ space: 8 }) {
              this.statCard($r('app.string.sessions'), `${this.totalSessions}`, '#552586')
              this.statCard($r('app.string.minutes_label'), `${this.totalMinutes}`, '#2196F3')
            }
            .justifyContent(FlexAlign.Center)

            Row({ space: 8 }) {
              this.statCard($r('app.string.streak'), `${this.currentStreak}d`, '#FF9800')
              this.statCard($r('app.string.best_streak'), `${this.maxStreak}d`, '#4CAF50')
            }
            .justifyContent(FlexAlign.Center)

            Divider().color('#333333')

            // Weekly chart
            StatsChart({ weeklyData: this.weeklyData, tagData: this.tagData })

            Divider().color('#333333')

            // Calendar heatmap
            CalendarHeatmap({ dailyData: this.heatmapData })
          }
          .padding({
            left: SizeConstants.PAGE_SIDE_PADDING,
            right: SizeConstants.PAGE_SIDE_PADDING,
            bottom: SizeConstants.PAGE_CONTENT_BOTTOM_PADDING
          })
        }
        .width(SizeConstants.FULL_WIDTH_PERCENT)
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(SizeConstants.FULL_WIDTH_PERCENT)
      .height(SizeConstants.FULL_HEIGHT_PERCENT)
      .backgroundColor('#0D0D0D')
    }
    .hideTitleBar(true)
  }

  @Builder
  statCard(label: Resource, value: string, color: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(18)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
      Text(label)
        .fontSize(9)
        .fontColor('#888888')
    }
    .width(72)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#1A1A1A')
    .borderRadius(12)
  }

  private async loadStats() {
    const db = DbService.getInstance()
    const streak = StreakTracker.getInstance()

    this.totalSessions = await db.getTotalSessionCount()
    this.totalMinutes = await db.getTotalFocusMinutes()
    this.weeklyData = await db.getWeeklyStats()

    await streak.refresh()
    this.currentStreak = streak.currentStreak
    this.maxStreak = streak.maxStreak

    // Load tag distribution
    const tagDist = await db.getTagDistribution()
    const tagArr: string[] = []
    tagDist.forEach((minutes: number, tag: string) => {
      tagArr.push(`${tag}:${minutes}`)
    })
    this.tagData = tagArr

    // Load heatmap data (last 3 months)
    const endDate = DailyGoal.todayString()
    const start = new Date()
    start.setDate(start.getDate() - 98)
    const startDate = `${start.getFullYear()}-${(start.getMonth() + 1).toString().padStart(2, '0')}-${start.getDate().toString().padStart(2, '0')}`
    const dailyStats = await db.getDailyStatsForRange(startDate, endDate)
    const heatArr: string[] = []
    dailyStats.forEach((minutes: number, date: string) => {
      heatArr.push(`${date}:${minutes}`)
    })
    this.heatmapData = heatArr

    // Load goal
    const savedTarget: number = AppStorage.get('dailyGoalTarget') ?? 120
    const savedCompleted: number = AppStorage.get('dailyGoalCompleted') ?? 0
    const savedDate: string = AppStorage.get('dailyGoalDate') ?? ''
    this.goal.targetMinutes = savedTarget
    if (savedDate === DailyGoal.todayString()) {
      this.goal.completedMinutes = savedCompleted
    }
  }
}
