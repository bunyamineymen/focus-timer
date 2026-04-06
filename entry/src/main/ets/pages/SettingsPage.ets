import { router } from '@kit.ArkUI'
import ThemePickerView from '../components/ThemePickerView'
import IntensitySelector from '../components/IntensitySelector'
import { IntensityLevel } from '../model/IntensityModel'
import { SizeConstants } from '../constants/SizeConstants'

@Entry
@Component
struct SettingsPage {
  @State selectedTheme: string = (AppStorage.get('selectedTheme') as string) ?? 'purple'
  @State selectedIntensity: IntensityLevel = (AppStorage.get('selectedIntensity') as IntensityLevel) ?? IntensityLevel.normal
  @State dailyGoalTarget: number = (AppStorage.get('dailyGoalTarget') as number) ?? 120
  @State autoSkip: boolean = (AppStorage.get('autoSkip') as boolean) ?? false
  @State showQuotes: boolean = (AppStorage.get('showQuotes') as boolean) ?? true

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

        Text($r('app.string.settings'))
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(28)
      }
      .width(SizeConstants.FULL_WIDTH_PERCENT)
      .padding({ left: 8, right: 8, top: 4 })

      Scroll() {
        Column({ space: 4 }) {
          // Timer Settings Group
          this.sectionHeader($r('app.string.settings_timer'))

          ListItemGroup() {
            ListItem() {
              Row() {
                Text($r('app.string.daily_goal'))
                  .fontSize(11)
                  .fontColor(Color.White)
                  .layoutWeight(1)
                Text(`${this.dailyGoalTarget} min`)
                  .fontSize(11)
                  .fontColor('#AAAAAA')
              }
              .width(SizeConstants.FULL_WIDTH_PERCENT)
              .padding(10)
            }

            ListItem() {
              Column({ space: 8 }) {
                Slider({
                  value: this.dailyGoalTarget,
                  min: 30,
                  max: 300,
                  step: 15,
                  style: SliderStyle.InSet
                })
                  .trackColor('#333333')
                  .selectedColor('#552586')
                  .blockColor('#FFFFFF')
                  .onChange((value: number) => {
                    this.dailyGoalTarget = value
                    AppStorage.setOrCreate('dailyGoalTarget', value)
                  })
              }
              .width(SizeConstants.FULL_WIDTH_PERCENT)
              .padding({ left: 10, right: 10, bottom: 8 })
            }

            ListItem() {
              Row() {
                Text($r('app.string.auto_skip'))
                  .fontSize(11)
                  .fontColor(Color.White)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.autoSkip })
                  .selectedColor('#552586')
                  .onChange((isOn: boolean) => {
                    this.autoSkip = isOn
                    AppStorage.setOrCreate('autoSkip', isOn)
                  })
              }
              .width(SizeConstants.FULL_WIDTH_PERCENT)
              .padding(10)
            }

            ListItem() {
              Row() {
                Text($r('app.string.show_quotes'))
                  .fontSize(11)
                  .fontColor(Color.White)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.showQuotes })
                  .selectedColor('#552586')
                  .onChange((isOn: boolean) => {
                    this.showQuotes = isOn
                    AppStorage.setOrCreate('showQuotes', isOn)
                  })
              }
              .width(SizeConstants.FULL_WIDTH_PERCENT)
              .padding(10)
            }
          }
          .divider({ strokeWidth: 0.5, color: '#333333' })
          .borderRadius(12)
          .backgroundColor('#1A1A1A')

          // Intensity
          this.sectionHeader($r('app.string.intensity'))
          Column() {
            IntensitySelector({ selectedIntensity: this.selectedIntensity })
          }
          .backgroundColor('#1A1A1A')
          .borderRadius(12)
          .padding(10)

          // Appearance Group
          this.sectionHeader($r('app.string.settings_appearance'))
          Column() {
            ThemePickerView({ selectedThemeId: this.selectedTheme })
          }
          .backgroundColor('#1A1A1A')
          .borderRadius(12)
          .padding(10)

          // Navigation links
          this.sectionHeader($r('app.string.settings_more'))

          Column() {
            this.navItem($r('sys.symbol.chart_bar_fill'), $r('app.string.statistics'), '#2196F3', () => {
              router.pushUrl({ url: 'pages/StatsPage' })
            })
            Divider().color('#333333')
            this.navItem($r('sys.symbol.trophy_fill'), $r('app.string.achievements'), '#FFD700', () => {
              router.pushUrl({ url: 'pages/AchievementsPage' })
            })
            Divider().color('#333333')
            this.navItem($r('sys.symbol.list_bullet'), $r('app.string.programs'), '#4CAF50', () => {
              router.pushUrl({ url: 'pages/ProgramListPage' })
            })
          }
          .backgroundColor('#1A1A1A')
          .borderRadius(12)

          // About
          this.sectionHeader($r('app.string.about'))
          Column() {
            Row() {
              Text($r('app.string.version'))
                .fontSize(11)
                .fontColor(Color.White)
                .layoutWeight(1)
              Text('1.0.0')
                .fontSize(11)
                .fontColor('#888888')
            }
            .padding(10)
          }
          .backgroundColor('#1A1A1A')
          .borderRadius(12)

          Blank().height(20)
        }
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

  @Builder
  sectionHeader(title: Resource) {
    Text(title)
      .fontSize(10)
      .fontColor('#888888')
      .fontWeight(FontWeight.Medium)
      .padding({ left: 4, top: 8, bottom: 4 })
  }

  @Builder
  navItem(icon: Resource, label: Resource, color: string, action: () => void) {
    Row({ space: 8 }) {
      SymbolGlyph(icon)
        .fontSize(16)
        .fontColor([color])

      Text(label)
        .fontSize(11)
        .fontColor(Color.White)
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(12)
        .fontColor(['#666666'])
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .padding(10)
    .onClick(action)
  }
}
