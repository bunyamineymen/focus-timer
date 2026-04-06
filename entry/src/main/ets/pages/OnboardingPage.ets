import { router } from '@kit.ArkUI'
import { SizeConstants } from '../constants/SizeConstants'
import ThemePickerView from '../components/ThemePickerView'

@Entry
@Component
struct OnboardingPage {
  @State private currentStep: number = 0
  @State private selectedTheme: string = 'purple'
  @State private dailyGoal: number = 120
  @State private fadeIn: number = 0

  aboutToAppear() {
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.fadeIn = 1
    })
  }

  build() {
    Column() {
      Stepper({ index: this.currentStep }) {
        // Step 1: Welcome
        StepperItem() {
          Column({ space: 12 }) {
            SymbolGlyph($r('sys.symbol.timer'))
              .fontSize(40)
              .fontColor(['#552586'])

            Text($r('app.string.onboarding_welcome'))
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)

            Text($r('app.string.onboarding_welcome_desc'))
              .fontSize(11)
              .fontColor('#AAAAAA')
              .textAlign(TextAlign.Center)
              .padding({ left: 16, right: 16 })
          }
          .width(SizeConstants.FULL_WIDTH_PERCENT)
          .justifyContent(FlexAlign.Center)
          .opacity(this.fadeIn)
        }
        .nextLabel($r('app.string.next'))

        // Step 2: How it works
        StepperItem() {
          Scroll() {
            Column({ space: 8 }) {
              Text($r('app.string.onboarding_how_title'))
                .fontSize(14)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)

              this.stepItem('1', $r('app.string.onboarding_step1'), '#552586')
              this.stepItem('2', $r('app.string.onboarding_step2'), '#4CAF50')
              this.stepItem('3', $r('app.string.onboarding_step3'), '#2196F3')
              this.stepItem('4', $r('app.string.onboarding_step4'), '#FF9800')
            }
            .width(SizeConstants.FULL_WIDTH_PERCENT)
            .padding(8)
          }
          .scrollBar(BarState.Off)
        }
        .nextLabel($r('app.string.next'))

        // Step 3: Set daily goal
        StepperItem() {
          Column({ space: 12 }) {
            SymbolGlyph($r('sys.symbol.target'))
              .fontSize(32)
              .fontColor(['#FF9800'])

            Text($r('app.string.onboarding_goal_title'))
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            Text(`${this.dailyGoal} min`)
              .fontSize(28)
              .fontColor('#FF9800')
              .fontWeight(FontWeight.Bold)

            Slider({
              value: this.dailyGoal,
              min: 30,
              max: 300,
              step: 15,
              style: SliderStyle.InSet
            })
              .width('80%')
              .trackColor('#333333')
              .selectedColor('#552586')
              .blockColor('#FFFFFF')
              .onChange((value: number) => {
                this.dailyGoal = value
              })

            Row({ space: 20 }) {
              Text('30m').fontSize(9).fontColor('#888888')
              Text('5h').fontSize(9).fontColor('#888888')
            }
            .width('80%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width(SizeConstants.FULL_WIDTH_PERCENT)
          .justifyContent(FlexAlign.Center)
        }
        .nextLabel($r('app.string.next'))

        // Step 4: Theme selection
        StepperItem() {
          Column({ space: 12 }) {
            Text($r('app.string.onboarding_theme_title'))
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            ThemePickerView({ selectedThemeId: this.selectedTheme })
          }
          .width(SizeConstants.FULL_WIDTH_PERCENT)
          .justifyContent(FlexAlign.Center)
          .padding(8)
        }
        .nextLabel($r('app.string.get_started'))
      }
      .onChange((prevIndex: number, index: number) => {
        animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
          this.currentStep = index
        })
      })
      .onFinish(() => {
        this.completeOnboarding()
      })
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .height(SizeConstants.FULL_HEIGHT_PERCENT)
    .backgroundColor('#0D0D0D')
  }

  @Builder
  stepItem(num: string, text: Resource, color: string) {
    Row({ space: 8 }) {
      Stack() {
        Circle().width(24).height(24).fill(color)
        Text(num)
          .fontSize(12)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }

      Text(text)
        .fontSize(10)
        .fontColor('#CCCCCC')
        .layoutWeight(1)
    }
    .width('100%')
    .padding(4)
  }

  private completeOnboarding() {
    AppStorage.setOrCreate('onboardingComplete', true)
    AppStorage.setOrCreate('dailyGoalTarget', this.dailyGoal)
    AppStorage.setOrCreate('selectedTheme', this.selectedTheme)
    router.replaceUrl({ url: 'pages/Index' })
  }
}
