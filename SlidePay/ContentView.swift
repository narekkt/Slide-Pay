//  Created by Tutundzhian Narek on 11/04/2025.
//  LinkedIn: @narek1t
//  GitHub: @narek1t

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            KeypadSwipeView()
        }
    }
}

#Preview {
    ContentView()
}

struct KeypadSwipeView: View {
    @State private var sliderOffsetPosition: CGFloat = 0
    @State private var unlocked = false
    @State private var enteredText: String = ""
    @State private var showDone = false
    
    let keypad: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "←"]
    ]
    
    var body: some View {
        ZStack {
            VStack {
                if unlocked {
                    AnimationView(valueofMoney: enteredText, unlocked: $unlocked, enteredText: $enteredText, sliderOffset: $sliderOffsetPosition, showDone: $showDone)
                }
                
                if !unlocked {
                    VStack {
                        VStack {
                            HStack {
                                Text(NSLocalizedString("Enter Amount", comment: ""))
                                    .font(.system(size: 20))
                                    .background(.black)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            
                            TextField("0", text: $enteredText)
                                .font(.system(size: 45))
                                .background(.black)
                                .foregroundStyle(.white)
                        }.padding(10)
                        
                        Spacer().frame(height: 50)
                        
                        VStack(spacing: 20) {
                            ForEach(keypad, id: \.self) { row in
                                HStack(spacing: 20) {
                                    ForEach(row, id: \.self) { key in
                                        Button(action: {
                                            handleKeypadButton(key: key)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 100, height: 100)
                                                    .foregroundStyle(.white.opacity(0.08))
                                                
                                                Text(key)
                                                    .font(.system(size: 45))
                                                    .foregroundStyle(.white)
                                            }
                                        }.simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.7)
                                                .onEnded { _ in
                                                    if key == "←" {
                                                        vibrate()
                                                        withAnimation(.easeOut(duration: 0.2)) {
                                                            enteredText = ""
                                                        }
                                                    }
                                                }
                                            )
                                        .accessibilityLabel(key == "←" ? "Delete" : key == "." ? "Decimal point" : "Number \(key)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                
                Spacer()
                
                ZStack {
                    Spacer()
                    
                    if !showDone {
                        ZStack {
                            Text(unlocked ? "Sending..." : "> > >")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .opacity(0.5)
                                .padding()
                            
                            ZStack(alignment: unlocked ? .trailing : .leading) {
                                RoundedRectangle(cornerRadius: 60)
                                    .frame(width: 340, height: 75)
                                    .foregroundStyle(unlocked ? .gray.opacity(0.3) : .gray.opacity(0.3))
                                
                                Image(systemName: "eurosign.circle")
                                    .resizable()
                                    .frame(width: 65, height: 65)
                                    .foregroundStyle(.white)
                                    .offset(x: sliderOffsetPosition)
                                    .gesture(enteredText.isEmpty ? nil : DragGesture()
                                        .onChanged { value in
                                            sliderOffsetPosition = max(min(value.translation.width, 280), 0)
                                        }
                                        .onEnded { value in
                                            if sliderOffsetPosition > 200 && !enteredText.isEmpty {
                                                unlocked = true
                                            } else {
                                                withAnimation {
                                                    sliderOffsetPosition = 0
                                                }
                                            }
                                        }
                                    )
                            }
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 60)
                                .frame(width: 340, height: 75)
                                .foregroundStyle(.white)
                            
                            Text(NSLocalizedString("Done", comment: ""))
                                .font(.title2)
                                .foregroundStyle(.black)
                        }
                        .onTapGesture {
                            unlocked = false
                            enteredText = ""
                            sliderOffsetPosition = 0
                            showDone = false
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func handleKeypadButton(key: String) {
        switch key {
        case "←":
            enteredText = String(enteredText.dropLast())
        case ".":
            if !enteredText.contains(".") && !enteredText.isEmpty {
                enteredText += key
            }
        case "0":
            if enteredText == "0" {
                return
            } else if enteredText.isEmpty {
                enteredText = "0"
            } else {
                if let dotIndex = enteredText.firstIndex(of: "."), enteredText.distance(from: dotIndex, to: enteredText.endIndex) <= 2 {
                    enteredText += "0"
                }
            }
        default:
            if enteredText == "0" {
                enteredText = "0." + key
            } else if enteredText.contains(".") {
                if let dotIndex = enteredText.firstIndex(of: "."), enteredText.distance(from: dotIndex, to: enteredText.endIndex) <= 2 {
                    enteredText += key
                }
            } else if enteredText.count < 10 {
                enteredText += key
            }
        }
    }
}

// Loader Animation
struct AnimationView: View {
    @State private var dollarOffset = false
    @State private var dollarOpacity = false
    @State private var showLoader = false
    @State var valueofMoney = "0"
    @Binding var unlocked: Bool
    @Binding var enteredText: String
    @Binding var sliderOffset: CGFloat
    @Binding var showDone: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: "eurosign.circle")
                .resizable()
                .foregroundStyle(.green)
                .frame(width: dollarOffset ? 200 : 60, height: dollarOffset ? 200 : 60)
                .offset(x: dollarOffset ? 0 : 130, y: dollarOffset ? 200 : 665)
                .opacity(dollarOpacity ? 0 : 1)
                .animation(.easeInOut, value: dollarOffset)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            dollarOffset.toggle()
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            dollarOpacity.toggle()
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showLoader.toggle()
                        }
                    }
                }
            
            ZStack {
                HStack {
                    Text(valueofMoney)
                        .font(.system(size: 72))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                        .offset(y: 12)
                    
                    Text("€")
                        .font(.system(size: 30))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                        .offset(y: 30)
                }
                if showLoader {
                    CircularLoaderView(unlocked: $unlocked, enteredText: $enteredText, sliderOffset: $sliderOffset, showDone: $showDone)
                }
            }
        }
    }
}

struct CircularLoaderView: View {
    @State private var border: CGFloat = 0.0
    @State private var isLoading: Bool = true
    @State private var showTick = false
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Binding var unlocked: Bool
    @Binding var enteredText: String
    @Binding var sliderOffset: CGFloat
    @Binding var showDone: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundStyle(Color.green)
            
            Circle()
                .trim(from: 0, to: border)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 360))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            showTick.toggle()
                            showDone = true
                        }
                    }
                }
                .onReceive(timer) { _ in
                    withAnimation {
                        border += 0.02
                        if border >= 1 {
                            isLoading = false
                            timer.upstream.connect().cancel()
                        }
                    }
                }
            
            if showTick {
                TickShape()
                    .trim(from: 0, to: 1)
                    .stroke(Color.green, lineWidth: 4)
                    .offset(x: -10)
            }
        }
        .offset(x: 0, y: 215)
        .frame(width: 150, height: 150)
        .padding()
    }
}

// Tick Shape
struct TickShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 20))
        path.addLine(to: CGPoint(x: rect.midX + 40, y: rect.midY - 20))
        return path
    }
}

struct ShowSent: View {
    @Binding var unlocked: Bool
    @Binding var enteredText: String
    @Binding var sliderOffset: CGFloat
    @Binding var showDone: Bool
    
    var body: some View {
        EmptyView()
    }
}
