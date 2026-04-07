import { SizeConstants } from '../constants/SizeConstants'

enum BreathPhase {
  inhale,
  hold,
  exhale,
  rest
}

@Component
export default struct BreathingExercise {
  @State private circleScale: number = 0.5
  @State private phase: BreathPhase = BreathPhase.inhale
  @State private phaseText: string = 'Breathe In'
  @State private secondsLeft: number = 4
  @State private isRunning: boolean = false
  @State private circleColor: string = '#552586'
  @State private cyclesCompleted: number = 0
  @State private glowOpacity: number = 0.6
  private intervalId: number = -1
  // 4-7-8 technique: inhale 4s, hold 7s, exhale 8s
  private pattern: number[] = [4, 7, 8, 2]
  private phaseIndex: number = 0

  aboutToDisappear() {
    this.stopBreathing()
  }

  build() {
    Column() {
      Stack() {
        // Outer glow ring
        Circle()
          .width(140)
          .height(140)
          .fill(Color.Transparent)
          .stroke(this.circleColor)
          .strokeWidth(2)
          .opacity(this.glowOpacity)

        // Breathing circle
        Circle()
          .width(100)
          .height(100)
          .fill(this.circleColor)
          .opacity(0.3)
          .scale({ x: this.circleScale, y: this.circleScale })

        // Inner circle
        Circle()
          .width(60)
          .height(60)
          .fill(this.circleColor)
          .opacity(0.6)
          .scale({ x: this.circleScale, y: this.circleScale })

        Column({ space: 4 }) {
          Text(this.phaseText)
            .fontSize(11)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
          Text(`${this.secondsLeft}`)
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
      }
      .width(150)
      .height(150)

      Row({ space: 12 }) {
        Button() {
          SymbolGlyph(this.isRunning ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
            .fontColor([Color.White])
            .fontSize(16)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#552586')
        .onClick(() => {
          if (this.isRunning) {
            this.stopBreathing()
          } else {
            this.startBreathing()
          }
        })

        Column() {
          Text($r('app.string.cycles'))
            .fontSize(9)
            .fontColor('#888888')
          Text(`${this.cyclesCompleted}`)
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .margin({ top: 8 })
    }
    .width(SizeConstants.FULL_WIDTH_PERCENT)
    .height(SizeConstants.FULL_HEIGHT_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  private startBreathing() {
    this.isRunning = true
    this.phaseIndex = 0
    this.enterPhase(0)

    this.intervalId = setInterval(() => {
      this.secondsLeft--
      if (this.secondsLeft <= 0) {
        this.phaseIndex = (this.phaseIndex + 1) % 4
        if (this.phaseIndex === 0) {
          this.cyclesCompleted++
        }
        this.enterPhase(this.phaseIndex)
      }
    }, 1000)
  }

  private stopBreathing() {
    this.isRunning = false
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId)
      this.intervalId = -1
    }
  }

  private enterPhase(index: number) {
    this.secondsLeft = this.pattern[index]
    switch (index) {
      case 0: // Inhale
        this.phase = BreathPhase.inhale
        this.phaseText = 'Breathe In'
        this.circleColor = '#4CAF50'
        this.getUIContext()?.animateTo({ duration: this.pattern[0] * 1000, curve: Curve.EaseInOut }, () => {
          this.circleScale = 1.0
          this.glowOpacity = 1.0
        })
        break
      case 1: // Hold
        this.phase = BreathPhase.hold
        this.phaseText = 'Hold'
        this.circleColor = '#2196F3'
        break
      case 2: // Exhale
        this.phase = BreathPhase.exhale
        this.phaseText = 'Breathe Out'
        this.circleColor = '#9C27B0'
        this.getUIContext()?.animateTo({ duration: this.pattern[2] * 1000, curve: Curve.EaseInOut }, () => {
          this.circleScale = 0.5
          this.glowOpacity = 0.6
        })
        break
      case 3: // Rest
        this.phase = BreathPhase.rest
        this.phaseText = 'Rest'
        this.circleColor = '#552586'
        break
    }
  }
}
