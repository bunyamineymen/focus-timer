import {
  ArcDirection,
  ArcDotIndicator,
  ArcSwiper,
  ArcSwiperAttribute,
  router
} from '@kit.ArkUI'

import ProgressController from '../components/ProgressController'
import ProgressRing from '../components/ProgressRing'
import ProgressTimes from '../components/ProgressTimes'
import BreathingExercise from '../components/BreathingExercise'
import BreakSuggestions from '../components/BreakSuggestions'
import CycleVisualizer from '../components/CycleVisualizer'
import QuotesProvider from '../components/QuotesProvider'
import TagSelector from '../components/TagSelector'
import Program from '../model/Program'
import Timer from '../model/Timer'
import { FocusType } from '../model/FocusType'
import { DbService } from '../service/DbService'
import { AchievementService } from '../service/AchievementService'
import { DailyGoal } from '../model/GoalModel'
import SessionRecord from '../model/SessionRecord'
import { SessionCompleteDialog, AchievementUnlockDialog } from '../components/FocusDialog'
import { ACHIEVEMENTS } from '../model/Achievement'
import { SizeConstants } from '../constants/SizeConstants'

@Entry
@Component
struct Index {
  private arcDotIndicator: ArcDotIndicator = new ArcDotIndicator();

  @State @Watch('updateFocus') program: Program = new Program()
  @State currentFocusType: FocusType = this.program.currentFocus.type;
  @State timer: Timer = new Timer(this.program.currentFocus.value * 60, () => {
    this.onSessionComplete()
  })
  @State selectedTag: string = ''
  @State showQuotes: boolean = (AppStorage.get('showQuotes') as boolean) ?? true
  private sessionStartTime: number = 0

  // Session complete dialog
  private sessionCompleteDialogController: CustomDialogController = new CustomDialogController({
    builder: SessionCompleteDialog({
      focusType: this.currentFocusType,
      duration: 0,
      onDismiss: () => {}
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  // Achievement unlock dialog
  private achievementDialogController: CustomDialogController = new CustomDialogController({
    builder: AchievementUnlockDialog({
      achievementName: '',
      achievementIcon: $r('sys.symbol.star_fill')
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  updateFocus() {
    const currentFocus = this.program.currentFocus;
    if (currentFocus.type !== this.currentFocusType) {
      this.currentFocusType = currentFocus.type
      this.timer.refresh(currentFocus.value * 60)
    }
  }

  build() {
    Stack() {
      ArcSwiper() {
        // Page 0: Controller with tag selector
        Column() {
          ProgressController({
            timer: this.timer,
            progressType: this.currentFocusType,
            program: this.program
          })
            .layoutWeight(1)

          // Tag selector at bottom (compact)
          if (this.currentFocusType === FocusType.focus) {
            TagSelector({ selectedTagId: this.selectedTag })
              .height(60)
              .padding({ bottom: 4 })
          }
        }
        .width(SizeConstants.FULL_WIDTH_PERCENT)
        .height(SizeConstants.FULL_HEIGHT_PERCENT)

        // Page 1: Ring with quotes
        Column() {
          ProgressRing({
            timer: this.timer,
            progressType: this.currentFocusType
          })
            .layoutWeight(1)

          if (this.showQuotes && !this.timer.running) {
            QuotesProvider()
              .height(36)
          }
        }
        .width(SizeConstants.FULL_WIDTH_PERCENT)
        .height(SizeConstants.FULL_HEIGHT_PERCENT)

        // Page 2: Time settings
        ProgressTimes({
          program: this.program
        })

        // Page 3: Cycle Visualizer
        CycleVisualizer({
          programCycle: this.program.program.map((t: FocusType) => t as number),
          currentIndex: this.program.getProgramIndex(),
          progress: this.timer.goal > 0 ? this.timer.progress / this.timer.goal : 0
        })

        // Page 4: Breathing Exercise (shown during breaks)
        BreathingExercise()

        // Page 5: Break Suggestions
        BreakSuggestions()
      }
      .indicator(
        this.arcDotIndicator
          .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
          .maskColor(new LinearGradient([{
            color: Color.Transparent,
            offset: $r('app.float.offset_zero')
          }]))
      )
      .effectMode(EdgeEffect.None)
      .index(1)

      // Settings button (top-right)
      Button() {
        SymbolGlyph($r('sys.symbol.gearshape'))
          .fontColor([Color.White])
          .fontSize(14)
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor('#33333380')
      .position({ x: '75%', y: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/SettingsPage' })
      })

      // Stats button (top-left)
      Button() {
        SymbolGlyph($r('sys.symbol.chart_bar_fill'))
          .fontColor([Color.White])
          .fontSize(14)
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor('#33333380')
      .position({ x: '10%', y: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/StatsPage' })
      })
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .height(SizeConstants.FULL_HEIGHT_PERCENT)
  }

  private async onSessionComplete() {
    const endTime = Date.now()
    const duration = this.timer.goal

    // Record session in database
    if (this.currentFocusType === FocusType.focus) {
      const record: SessionRecord = {
        startTime: this.sessionStartTime > 0 ? this.sessionStartTime : endTime - duration * 1000,
        endTime: endTime,
        duration: duration,
        focusType: this.currentFocusType,
        tag: this.selectedTag,
        completed: true
      }

      const db = DbService.getInstance()
      await db.insertSession(record)

      // Update daily goal
      const minutes = Math.floor(duration / 60)
      const goalTarget: number = AppStorage.get('dailyGoalTarget') ?? 120
      const goalCompleted: number = AppStorage.get('dailyGoalCompleted') ?? 0
      const goalDate: string = AppStorage.get('dailyGoalDate') ?? ''
      const today = DailyGoal.todayString()
      let newCompleted = minutes
      if (goalDate === today) {
        newCompleted = goalCompleted + minutes
      }
      AppStorage.setOrCreate('dailyGoalCompleted', newCompleted)
      AppStorage.setOrCreate('dailyGoalDate', today)

      // Check if goal met
      if (newCompleted >= goalTarget) {
        await db.markGoalMet(today)
      }

      // Check early bird (before 7 AM)
      const hour = new Date().getHours()
      if (hour < 7) {
        const earlyCount: number = AppStorage.get('earlyBirdCount') ?? 0
        AppStorage.setOrCreate('earlyBirdCount', earlyCount + 1)
      }

      // Check achievements
      const achievementService = AchievementService.getInstance()
      const newlyUnlocked = await achievementService.checkAndUpdate()
      if (newlyUnlocked.length > 0) {
        const achId = newlyUnlocked[0]
        const ach = ACHIEVEMENTS.find((a) => a.id === achId)
        if (ach) {
          this.achievementDialogController = new CustomDialogController({
            builder: AchievementUnlockDialog({
              achievementName: ach.name,
              achievementIcon: ach.icon
            }),
            autoCancel: true,
            customStyle: true,
            alignment: DialogAlignment.Center
          })
          this.achievementDialogController.open()
        }
      }
    }

    // Show session complete dialog
    this.sessionCompleteDialogController = new CustomDialogController({
      builder: SessionCompleteDialog({
        focusType: this.currentFocusType,
        duration: duration,
        onDismiss: () => {
          this.program.skip()
        }
      }),
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Center
    })
    this.sessionCompleteDialogController.open()
  }
}
