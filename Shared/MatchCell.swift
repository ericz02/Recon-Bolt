import SwiftUI
import SwiftUIMissingPieces
import HandyOperators

struct MatchCell: View {
	static let dateFormatter = DateFormatter() <- {
		$0.dateStyle = .short
	}
	static let timeFormatter = DateFormatter() <- {
		$0.timeStyle = .short
	}
	
	private let visualsHeight: CGFloat = 64
	
	let match: Match
	
	var body: some View {
		if match.isRanked {
			rankedBody
		} else {
			unrankedBody
		}
	}
	
	var unrankedBody: some View {
		HStack {
			mapIcon { $0
				.opacity(0.8)
				.aspectRatio(contentMode: .fill)
				.frame(height: visualsHeight / 2, alignment: .top)
			}
			
			Text(Self.dateFormatter.string(from: match.startTime))
			Text(Self.timeFormatter.string(from: match.startTime))
				.foregroundColor(.secondary)
			Spacer()
			Text("N/A")
				.foregroundColor(.secondary)
		}
		.opacity(0.6)
	}
	
	var rankedBody: some View {
		HStack {
			mapIcon { $0 }
			
			VStack(alignment: .leading) {
				Text(Self.dateFormatter.string(from: match.startTime))
				Text(Self.timeFormatter.string(from: match.startTime))
					.foregroundColor(.secondary)
				if match.performanceBonus != 0 {
					Text("Performance Bonus: \(match.performanceBonus)")
						.foregroundColor(.green)
				}
				if match.afkPenalty != 0 {
					Text("AFK Penalty: \(match.afkPenalty)")
						.foregroundColor(.red)
				}
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				let eloChange = match.eloChange
				Text(eloChange > 0 ? "+\(eloChange)" : eloChange < 0 ? "\(eloChange)" : "=")
					.foregroundColor(changeColor)
				Text("\(match.tierProgressAfterUpdate)")
					.foregroundColor(.gray)
			}
			
			changeRing
		}
	}
	
	private func mapIcon<V: View>(additionalModifiers: (AnyView) -> V) -> some View {
		additionalModifiers(
			AnyView(
				match.mapImage
					.aspectRatio(contentMode: .fit)
					.frame(height: visualsHeight)
			)
		)
		.overlay(mapLabel)
		.mask(RoundedRectangle(cornerRadius: 4, style: .continuous))
	}
	
	private var mapLabel: some View {
		Text(match.mapName ?? "unknown")
			.font(Font.callout.smallCaps())
			.bold()
			.foregroundColor(.white)
			.shadow(radius: 1)
			.padding(.leading, 4) // visual alignment
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.blendMode(.overlay)
	}
	
	private var changeColor: Color {
		match.eloChange > 0 ? .green : match.eloChange < 0 ? .red : .gray
	}
	
	@ViewBuilder
	private var changeRing: some View {
		let lineWidth: CGFloat = 4
		
		ZStack {
			let before = CGFloat(match.eloBeforeUpdate) / 100
			let after = CGFloat(match.eloAfterUpdate) / 100
			
			let ring = Circle().rotation(Angle(degrees: -90))
			let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
			
			ring
				.stroke(Color.gray.opacity(0.2), style: stroke)
			
			ZStack {
				ring
					.trim(from: 0, to: after.truncatingRemainder(dividingBy: 1))
					.stroke(Color.gray, style: stroke)
				
				let changeRing = ring
					.trim(from: 0, to: abs(after - before))
					.rotation(Angle(degrees: Double(360 * min(before, after))))
				
				changeRing
					.stroke(Color.black, style: stroke <- { $0.lineWidth += 2 })
					.blendMode(.destinationOut)
				
				changeRing
					.stroke(changeColor, style: stroke)
				
				Image("tier_\(match.tierAfterUpdate)")
					.resizable()
					.padding(10)
			}
			.compositingGroup()
			
			movementIndicator
				.background(Circle().fill(Color.white).blendMode(.destinationOut))
				.alignmentGuide(.top) { $0[VerticalAlignment.center] }
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		}
		.compositingGroup()
		.padding(lineWidth / 2)
		.aspectRatio(contentMode: .fit)
		.frame(height: visualsHeight)
	}
	
	@ViewBuilder
	private var movementIndicator: some View {
		if match.tierAfterUpdate > match.tierBeforeUpdate {
			// promotion
			Image(systemName: "chevron.up.circle.fill")
				.foregroundColor(.green)
		} else if match.tierAfterUpdate < match.tierBeforeUpdate {
			// demotion
			Image(systemName: "chevron.down.circle.fill")
				.foregroundColor(.red)
		}
	}
}

struct MatchCell_Previews: PreviewProvider {
	static let promotion = Match.example(tierChange: (21, 22), tierProgressChange: (80, 10), mapIndex: 0)
	static let increase = Match.example(tierChange: (8, 8), tierProgressChange: (40, 60), mapIndex: 1)
	static let unchanged = Match.example(tierChange: (12, 12), tierProgressChange: (50, 50), mapIndex: 2)
	static let decrease = Match.example(tierChange: (8, 8), tierProgressChange: (60, 40), mapIndex: 3)
	static let demotion = Match.example(tierChange: (6, 5), tierProgressChange: (10, 80), mapIndex: 4)
	
	static let jump = Match.example(tierChange: (11, 13), tierProgressChange: (90, 30))
	
	static let unranked = Match.example(tierChange: (0, 0), tierProgressChange: (0, 0))
	
	static let allExamples = [promotion, increase, unchanged, decrease, demotion, jump, unranked]
	
	static var previews: some View {
		ForEach(ColorScheme.allCases, id: \.hashValue) {
			VStack(spacing: 0) {
				Divider()
				ForEach(allExamples) {
					MatchCell(match: $0)
						.padding()
					Divider()
				}
			}
			.preferredColorScheme($0)
		}
	}
}

private let tiers: [String] = ["INVALID", "iron", "silver", "gold", "platinum", "diamond", "immortal"]
	.flatMap { rank in (1...3).map { "\(rank) \($0)" } }
	+ ["radiant"]

extension Match {
	@ViewBuilder
	var mapImage: some View {
		if let name = mapName {
			Image("maps/\(name)")
				.resizable()
		} else {
			Rectangle()
				.size(width: 400, height: 225)
				.fill(Color.gray)
		}
	}
}
