import SwiftUI
import MapKit

enum MapAction {
    case add(CLLocationCoordinate2D)
    case remove(CLLocationCoordinate2D)
    case clear([CLLocationCoordinate2D])
}

struct SetAreaCoverageView: View {
    @AppStorage(AppStorageKeys.mapType) private var persistedMapType: String = "Default"
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var region: MKCoordinateRegion
    @Binding var points: [CLLocationCoordinate2D]      // dữ liệu thật
    @Binding var mapType: MKMapType
    @Binding var focusUser: Bool
    
    @State private var localPoints: [CLLocationCoordinate2D] = [] // dữ liệu tạm
    @State private var undoStack: [MapAction] = []
    @State private var redoStack: [MapAction] = []
    @State private var areaHa: String = "0.00"
    @State private var touchHelp: Bool = false
    
    init(initialRegion: MKCoordinateRegion,
         points: Binding<[CLLocationCoordinate2D]>,
         mapType: Binding<MKMapType>,
         focusUser: Binding<Bool>) {
        _region = State(initialValue: initialRegion)
        _points = points
        _mapType = mapType
        _focusUser = focusUser
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(AppFonts.regular(size: 17))
                    .foregroundColor(AppTheme.primary)
                }
                Spacer()
                Text("Set Area Coverage")
                    .font(AppFonts.semiBold(size: 17))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }
            .padding()
            
            // Map
            ZStack(alignment: .topTrailing) {
                MapRepresentable(region: $region,
                                 points: $localPoints,   // 👈 dùng localPoints thay vì points
                                 mapType: $mapType,
                                 focusUser: focusUser,
                                 onAddPoint: { coord in
                    touchHelp = true
                    localPoints.append(coord)
                    undoStack.append(.add(coord))
                    redoStack.removeAll()
                    recalcArea()
                })
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Button {
                        mapType = (mapType == .standard) ? .satellite : .standard
                    } label: {
                        Image("icMap")
                    }
                    Button {
                        focusUser.toggle()
                    } label: {
                        Image("icCompass")
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                
                if !touchHelp && localPoints.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Tap the screen to add points and create polygon")
                                .font(AppFonts.regular(size: 15))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 5)
                                .background(AppTheme.surfaceSecondary.opacity(0.9))
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            
            // Bottom bar
            HStack {
                VStack(alignment: .leading) {
                    Text("Area")
                        .font(AppFonts.regular(size: 15))
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text("\(areaHa) Ha")
                        .font(AppFonts.bold(size: 22))
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 10) {
                    // Clear all
                    Button {
                        if !localPoints.isEmpty {
                            undoStack.append(.clear(localPoints))
                            localPoints.removeAll()
                            redoStack.removeAll()
                            recalcArea()
                        }
                    } label: {
                        Image("icClose")
                    }
                    
                    // Undo
                    Button {
                        if let last = undoStack.popLast() {
                            switch last {
                            case .add(let coord):
                                if let idx = localPoints.lastIndex(where: { $0.latitude == coord.latitude && $0.longitude == coord.longitude }) {
                                    localPoints.remove(at: idx)
                                }
                                redoStack.append(last)
                            case .remove(let coord):
                                localPoints.append(coord)
                                redoStack.append(last)
                            case .clear(let coords):
                                localPoints = coords
                                redoStack.append(last)
                            }
                            recalcArea()
                        }
                    } label: {
                        Image("back_tap") // undo
                    }
                    
                    // Redo
                    Button {
                        if let last = redoStack.popLast() {
                            switch last {
                            case .add(let coord):
                                localPoints.append(coord)
                                undoStack.append(last)
                            case .remove(let coord):
                                if let idx = localPoints.lastIndex(where: { $0.latitude == coord.latitude && $0.longitude == coord.longitude }) {
                                    localPoints.remove(at: idx)
                                }
                                undoStack.append(last)
                            case .clear:
                                localPoints.removeAll()
                                undoStack.append(last)
                            }
                            recalcArea()
                        }
                    } label: {
                        Image("next_tap") // redo
                    }
                    
                    // Done
                    Button {
                        points = localPoints   // 👈 chỉ khi bấm Done mới cập nhật ra ngoài
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(AppFonts.medium(size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.primary)
                            .clipShape(Capsule())
                            .frame(width: 65, height: 34, alignment: .center)
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding(.vertical, 10)
            .background(AppTheme.background)
            //.cornerRadius(12)
        }
        .onAppear {
            localPoints = points   // 👈 copy dữ liệu gốc vào local khi mở
            recalcArea()
        }
        .onChange(of: mapType) { newValue in
            persistedMapType = newValue == .standard ? "Standard" : "Satellite"
        }
        .onChange(of: localPoints.count) { _ in
            recalcArea()
        }
        .themeAware()
    }
    
    private func recalcArea() {
        areaHa = calculateAreaHa()
        print("Recalculated areaHa = \(areaHa)")
    }
    
    private func calculateAreaHa() -> String {
        guard localPoints.count > 2 else { return "0.00" }
        let area = polygonArea(points: localPoints)
        return String(format: "%.2f", area / 10000) // m² → ha
    }
    
    /// Tính diện tích polygon trên mặt đất (m²)
    private func polygonArea(points: [CLLocationCoordinate2D]) -> Double {
        guard points.count > 2 else { return 0 }
        
        let radius: Double = 6_378_137 // bán kính Trái Đất (m)
        var area: Double = 0
        
        for i in 0..<points.count {
            let p1 = points[i]
            let p2 = points[(i + 1) % points.count]
            
            let lon1 = p1.longitude.toRadians()
            let lat1 = p1.latitude.toRadians()
            let lon2 = p2.longitude.toRadians()
            let lat2 = p2.latitude.toRadians()
            
            area += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2))
        }
        
        area = -(area * radius * radius / 2.0)
        return abs(area) // diện tích dương
    }
}

private extension Double {
    func toRadians() -> Double { self * .pi / 180 }
}
