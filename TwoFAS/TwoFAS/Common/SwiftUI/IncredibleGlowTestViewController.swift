import SwiftUI
import UIKit
import CommonUI

// MARK: - View

struct IncredibleGlowTestView: View {
    @State private var showSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 8) {
                IntroLogoBadgeView(image: Image("TwoFASLogo"))
                Text("Just know you're")
                    .font(.body)
                    .foregroundStyle(.white)
                IntroWelcomeView(text: "Incredible!")
                Button("Learn more about backup") { showSheet = true }
                    .foregroundStyle(.white)
                    .padding(.top, 24)
            }
            .multilineTextAlignment(.center)
        }
//        .inspectorSheet(
//            isPresented: $showSheet,
//            systemImage: "arrow.triangle.2.circlepath",
//            title: "Secure sync and backup",
//            description: "2FAS uses iCloud to securely create backups and synchronize 2FA tokens. Encrypted backup data is stored in iCloud, accessible exclusively through the 2FAS app.",
//            footnote: "It is enabled by default and can be turned off at any time in the backup settings in the app.",
//            actionTitle: "Understood"
//        )
    }
}

// MARK: - Hosting controller

final class IncredibleGlowTestViewController: UIHostingController<IntroductionView> {
    init() {
        super.init(rootView: IntroductionView(close: {}))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 16-bit float preserves EDR headroom during Core Animation compositing
        // on iPhone 12 Pro+ and iPad Pro with ProMotion displays.
        view.layer.contentsFormat = .RGBA16Float
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
