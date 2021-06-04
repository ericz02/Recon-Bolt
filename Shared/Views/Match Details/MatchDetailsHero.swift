import SwiftUI
import VisualEffects
import ValorantAPI

struct MatchDetailsHero: View {
	let data: MatchViewData
	
	var body: some View {
		ZStack {
			let mapID = data.details.matchInfo.mapID
			MapImage.splash(mapID)
				.aspectRatio(contentMode: .fill)
				.frame(height: 150)
				.clipped()
				.overlay(MapImage.Label(mapID: mapID).padding(6))
			
			#if os(macOS)
			let blur = VisualEffectBlur(material: .toolTip, blendingMode: .withinWindow, state: .followsWindowActiveState)
			#else
			let blur = VisualEffectBlur(blurStyle: .systemThinMaterialDark)
			#endif
			
			VStack {
				scoreSummary(for: data.details.teams)
					.font(.largeTitle.weight(.heavy))
				
				Text(data.details.matchInfo.queueID.name)
					.font(.largeTitle.weight(.semibold).smallCaps())
					.opacity(0.8)
					.blendMode(.overlay)
			}
			.padding(.horizontal, 6)
			.background(
				blur.roundedAndStroked(cornerRadius: 8)
			)
			.shadow(radius: 10)
			.colorScheme(.dark)
		}
	}
	
	@ViewBuilder
	private func scoreSummary(for teams: [Team]) -> some View {
		let _ = assert(!teams.isEmpty)
		let sorted = teams.sorted(on: \.pointCount)
			.movingToFront { $0.id == data.myself?.teamID }
		
		if sorted.count >= 2 {
			HStack {
				Text(verbatim: "\(sorted[0].pointCount)")
					.foregroundColor(.valorantBlue)
				Text("–")
					.opacity(0.5)
				Text(verbatim: "\(sorted[1].pointCount)")
					.foregroundColor(.valorantRed)
				
				if sorted.count > 2 {
					Text("–")
						.opacity(0.5)
					Text(verbatim: "…")
						.foregroundColor(.valorantRed)
				}
			}
		} else {
			Text(verbatim: "\(sorted[0].pointCount) points")
		}
	}
}

#if DEBUG
struct MatchDetailsHero_Previews: PreviewProvider {
	static var previews: some View {
		MatchDetailsHero(data: PreviewData.singleMatchData)
			.previewLayout(.sizeThatFits)
			.environmentObject(AssetManager.forPreviews)
	}
}
#endif