import SwiftUI

struct LEDDisplayEffectRenderer: View {
    let context: LEDDisplayEffectContext

    var body: some View {
        ZStack {
            switch context.draft.selectedStyle.type {
            case .marquee:
                MarqueeLEDDisplayEffectView(context: context)
            case .neonBlink:
                NeonBlinkLEDDisplayEffectView(context: context)
            case .breathing:
                BreathingLEDDisplayEffectView(context: context)
            case .typewriter:
                TypewriterLEDDisplayEffectView(context: context)
            case .meteorShower:
                MeteorShowerLEDDisplayEffectView(context: context)
            case .laserSweep:
                LaserSweepLEDDisplayEffectView(context: context)
            case .fireworkBurst:
                FireworkBurstLEDDisplayEffectView(context: context)
            case .heartBeat:
                HeartBeatLEDDisplayEffectView(context: context)
            case .heartRain:
                HeartRainLEDDisplayEffectView(context: context)
            case .rainbow:
                RainbowGradientLEDDisplayEffectView(context: context)
            case .starFlash:
                StarFlashLEDDisplayEffectView(context: context)
            case .bulletFlyIn:
                BulletFlyInLEDDisplayEffectView(context: context)
            case .auroraWave:
                AuroraWaveLEDDisplayEffectView(context: context)
            case .bubblePop:
                BubblePopLEDDisplayEffectView(context: context)
            case .spotlight:
                SpotlightLEDDisplayEffectView(context: context)
            case .glitchPulse:
                GlitchPulseLEDDisplayEffectView(context: context)
            }
        }
    }
}
