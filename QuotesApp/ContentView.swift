//
//  ContentView.swift
//  QuotesApp
//
//  Created by CDMI on 27/03/26.
//

import SwiftUI

struct ContentView: View {
    @State var data: [[String: Any]] = []
    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .cyan, .indigo, .yellow]
    @State var a = 0
    var body: some View {
        Image("BackGround")
            .resizable()
            .ignoresSafeArea()
            .overlay {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 20) {
                            ForEach(Array(data.prefix(10).indices), id: \.self) { i in
                                Rectangle()
                                    .fill(colors.randomElement() ?? .blue)
                                    .frame(width: 350, height: 200)
                                    .cornerRadius(20)
                                
                                    .overlay {
                                        Text("\(data[i]["quote"] ?? "")")
                                            .bold()
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                    }
                                    .shadow(radius: 5)
                                    .containerRelativeFrame(.vertical)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.5)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                    }
                            }
                            HStack {
                                Button {
                                    if a >= 10 {
                                        a -= 10
                                        withAnimation {
                                            proxy.scrollTo(0, anchor: .top)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .frame(width: 50, height: 50)
                                        .background(.yellow)
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                Button {
                                    a += 10
                                    withAnimation {
                                        proxy.scrollTo(0, anchor: .top)
                                    }
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 50, height: 50)
                                        .background(.yellow)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                }
                .task(id: a) {
                    await fetchData()
                }
            }
    }
    
    func fetchData() async {
        print("=========")
        guard let url = URL(string: "https://dummyjson.com/quotes?skip=\(a)") else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                
                let dataDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                self.data = dataDict?["quotes"] as? [[String: Any]] ?? []
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
